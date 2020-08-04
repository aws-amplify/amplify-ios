//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import AWSRekognition
import Amplify
import AWSTextract

class IdentifyTextResultTransformers: IdentifyResultTransformers {

    static func processText(_ rekognitionTextBlocks: [AWSRekognitionTextDetection]) -> IdentifyTextResult {
        var words = [IdentifiedWord]()
        var lines = [String]()
        var identifiedLines = [IdentifiedLine]()
        var fullText = ""
        for rekognitionTextBlock in rekognitionTextBlocks {
            guard let detectedText = rekognitionTextBlock.detectedText else {
                continue
            }
            guard let boundingBox = processBoundingBox(rekognitionTextBlock.geometry?.boundingBox) else { continue }
            guard let polygon = processPolygon(rekognitionTextBlock.geometry?.polygon) else {
                continue
            }
            let word = IdentifiedWord(text: detectedText,
                            boundingBox: boundingBox,
                            polygon: polygon)
            let line = IdentifiedLine(text: detectedText,
                                      boundingBox: boundingBox,
                                      polygon: polygon)
            switch rekognitionTextBlock.types {
            case .line:
                lines.append(detectedText)
                identifiedLines.append(line)

            case .word:
                fullText += detectedText + " "
                words.append(word)
            case .unknown:
                break
            @unknown default:
                break
            }
        }

        return IdentifyTextResult(fullText: fullText,
                                  words: words,
                                  rawLineText: lines,
                                  identifiedLines: identifiedLines)
    }

    static func processText(_ textractTextBlocks: [AWSTextractBlock]) -> IdentifyDocumentTextResult {
        var blockMap = [String: AWSTextractBlock]()
        for block in textractTextBlocks {
            guard let identifier = block.identifier else {
                continue
            }
            blockMap[identifier] = block
        }
        return processTextBlocks(blockMap)
    }

    static func processTextBlocks(_ blockMap: [String: AWSTextractBlock]) -> IdentifyDocumentTextResult {
        var fullText = ""
        var words = [IdentifiedWord]()
        var lines = [String]()
        var linesDetailed = [IdentifiedLine]()
        var selections = [Selection]()
        var tables = [Table]()
        var keyValues = [BoundedKeyValue]()
        var tableBlocks = [AWSTextractBlock]()
        var keyValueBlocks = [AWSTextractBlock]()

        for block in blockMap.values {
            switch block.blockType {
            case .line:
                if let line = parseLineBlock(block: block) {
                    lines.append(line.text)
                    linesDetailed.append(line)
                }
            case .word:
                if let word = parseWordBlock(block: block) {
                    fullText += word.text + " "
                    words.append(word)
                }
            case .selectionElement:
                if let selection = parseSelectionElementBlock(block: block) {
                    selections.append(selection)
                }
            case .table:
                tableBlocks.append(block)
            case .keyValueSet:
                keyValueBlocks.append(block)
            default:
                continue
            }
        }
        tables = processTables(tableBlocks: tableBlocks, blockMap: blockMap)
        keyValues = processKeyValues(keyValueBlocks: keyValueBlocks, blockMap: blockMap)

        return IdentifyDocumentTextResult(
            fullText: fullText,
            words: words,
            rawLineText: lines,
            identifiedLines: linesDetailed,
            selections: selections,
            tables: tables,
            keyValues: keyValues)
    }

    static func processTables(tableBlocks: [AWSTextractBlock],
                              blockMap: [String: AWSTextractBlock]) -> [Table] {
        var tables = [Table]()
        for tableBlock in tableBlocks {
            if let table = processTable(tableBlock, blockMap: blockMap) {
                tables.append(table)
            }
        }
        return tables
    }

    static func processKeyValues(keyValueBlocks: [AWSTextractBlock],
                                 blockMap: [String: AWSTextractBlock]) -> [BoundedKeyValue] {
        var keyValues =  [BoundedKeyValue]()
        for keyValueBlock in keyValueBlocks {
            if let keyValue = processKeyValue(keyValueBlock, blockMap: blockMap) {
                keyValues.append(keyValue)
            }
        }
        return keyValues
    }

    static func processTable(_ tableBlock: AWSTextractBlock,
                             blockMap: [String: AWSTextractBlock]) -> Table? {

        guard let relationships = tableBlock.relationships,
            case .table = tableBlock.blockType else {
            return nil
        }
        var table = Table()
        var rows = Set<Int>()
        var cols = Set<Int>()

        for tableRelation in relationships {
            guard let cellIds = tableRelation.ids else {
                continue
            }

            for cellId in cellIds {
                let cellBlock = blockMap[cellId]

                guard let rowIndex = cellBlock?.rowIndex,
                    let colIndex = cellBlock?.columnIndex else {
                    continue
                }
                // textract starts indexing at 1, so subtract it by 1.
                let row = Int(truncating: rowIndex) - 1
                let col = Int(truncating: colIndex) - 1

                if !rows.contains(row),
                    !cols.contains(row),
                    let cell = constructTableCell(cellBlock, blockMap) {
                    table.cells.append(cell)
                    rows.insert(row)
                    cols.insert(col)
                }
            }
        }
        table.rows = rows.count
        table.columns = cols.count
        return table
    }

    static func constructTableCell(_ block: AWSTextractBlock?, _ blockMap: [String: AWSTextractBlock]) -> Table.Cell? {
        guard block?.blockType == .cell,
            let selectionStatus = block?.selectionStatus,
            let relationships = block?.relationships,
            let rowSpan = block?.rowSpan,
            let columnSpan = block?.columnSpan,
            let geometry = block?.geometry,
            let textractBoundingBox = geometry.boundingBox,
            let texttractPolygon = geometry.polygon
            else {
                return nil
        }

        var words = ""
        var isSelected = false

        for cellRelation in relationships {
            guard let wordOrSelectionIds = cellRelation.ids else {
                continue
            }

            for wordOrSelectionId in wordOrSelectionIds {
                let wordOrSelectionBlock = blockMap[wordOrSelectionId]

                switch wordOrSelectionBlock?.blockType {
                case .word:
                    guard let text = wordOrSelectionBlock?.text else {
                        return nil
                    }
                    words += text + " "
                case .selectionElement:
                    isSelected = selectionStatus == .selected ? true : false
                default:
                    break
                }
            }
        }

        guard let boundingBox = processBoundingBox(textractBoundingBox) else {
            return nil
        }

        guard let polygon = processPolygon(texttractPolygon) else {
            return nil
        }

        return Table.Cell(text: words,
                          boundingBox: boundingBox,
                          polygon: polygon,
                          isSelected: isSelected,
                          rowSpan: Int(truncating: rowSpan),
                          columnSpan: Int(truncating: columnSpan))
    }

    static func processKeyValue(_ keyBlock: AWSTextractBlock,
                                blockMap: [String: AWSTextractBlock]) -> BoundedKeyValue? {
        guard keyBlock.blockType == .keyValueSet,
            keyBlock.entityTypes?.contains("KEY") ?? false,
            let relationships = keyBlock.relationships else {
            return nil
        }

        var keyText = ""
        var valueText = ""
        var valueSelected = false

        for keyBlockRelationship in relationships {

            guard let ids = keyBlockRelationship.ids else {
                continue
            }

            switch keyBlockRelationship.types {
            case .child:
                keyText = processChildOfKeyValueSet(ids: ids, blockMap: blockMap)
            case .value:
                let valueResult = processValueOfKeyValueSet(ids: ids, blockMap: blockMap)
                valueText = valueResult.0
                valueSelected = valueResult.1
            default:
                break
            }
        }

        guard let boundingBox = processBoundingBox(keyBlock.geometry?.boundingBox) else {
            return nil
        }

        guard let polygon = processPolygon(keyBlock.geometry?.polygon) else {
            return nil
        }

        return BoundedKeyValue(key: keyText,
                               value: valueText,
                               isSelected: valueSelected,
                               boundingBox: boundingBox,
                               polygon: polygon)
    }
}
