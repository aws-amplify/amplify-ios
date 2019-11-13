//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import AWSRekognition
import Amplify

class IdentifyLabelsResultUtils: IdentifyResultUtils {
    static func processLabels(_ rekognitionLabels: [AWSRekognitionLabel]) -> [Label] {
        var labels = [Label]()
        for rekognitionLabel in rekognitionLabels {

            guard let name = rekognitionLabel.name else {
                continue
            }

            let parents = processParents(rekognitionLabel.parents)

            let metadata = LabelMetadata(confidence: Double(
                truncating: rekognitionLabel.confidence ?? 0.0), parents: parents)

            let boundingBoxes = processInstances(rekognitionLabel.instances)

            let label = Label(name: name, metadata: metadata, boundingBoxes: boundingBoxes)

            labels.append(label)
        }
        return labels
    }

    static func processParents(_ rekognitionParents: [AWSRekognitionParent]?) -> [Parent] {
        var parents = [Parent]()
        guard let rekognitionParents = rekognitionParents else {
            return parents
        }

        for parent in rekognitionParents {
            if let name = parent.name {
                parents.append(Parent(name: name))
            }
        }
        return parents
    }

    static func processInstances(_ rekognitionInstances: [AWSRekognitionInstance]?) -> [BoundingBox] {
        var boundingBoxes = [BoundingBox]()
        guard let rekognitionInstances = rekognitionInstances else {
            return boundingBoxes
        }
        for rekognitionInstance in rekognitionInstances {
            guard let boundingBox = processBoundingBox(rekognitionInstance.boundingBox) else {
                continue
            }
            boundingBoxes.append(boundingBox)
        }

        return boundingBoxes
    }
}
