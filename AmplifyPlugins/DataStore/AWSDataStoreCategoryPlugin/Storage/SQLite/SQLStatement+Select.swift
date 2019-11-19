//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation
import SQLite

/// Represents a `select` SQL statement associated with a `Model` instance and
/// optionally composed by a `ConditionStatement`.
struct SelectStatement: SQLStatement {

    let modelType: Model.Type
    let conditionStatement: ConditionStatement?

    init(from modelType: Model.Type, predicate: QueryPredicate? = nil) {
        self.modelType = modelType

        var conditionStatement: ConditionStatement?
        if let predicate = predicate {
            let statement = ConditionStatement(modelType: modelType,
                                               predicate: predicate)
            conditionStatement = statement
        }
        self.conditionStatement = conditionStatement
    }

    var stringValue: String {
        let schema = modelType.schema
        let fields = schema.columns
        let tableName = schema.name
        var columns = fields.map { field -> String in
            return field.columnName(forNamespace: "root") + " " + field.columnAlias()
        }

        // eager load many-to-one relationships (simple inner join)
        var joinStatements: [String] = []
        for foreignKey in schema.foreignKeys {
            let connectedModelType = foreignKey.requiredConnectedModel
            let connectedSchema = connectedModelType.schema
            let connectedTableName = connectedModelType.schema.name

            // columns
            let alias = foreignKey.name
            let connectedColumn = connectedSchema.primaryKey.columnName(forNamespace: alias)
            let foreignKeyName = foreignKey.columnName(forNamespace: "root")

            // append columns from relationships
            columns += connectedSchema.columns.map { field -> String in
                return field.columnName(forNamespace: alias) + " " + field.columnAlias(forNamespace: alias)
            }

            joinStatements.append("""
            inner join \(connectedTableName) as \(alias)
              on \(connectedColumn) = \(foreignKeyName)
            """)
        }

        let sql = """
        select
          \(joinedAsSelectedColumns(columns))
        from \(tableName) as root
        \(joinStatements.joined(separator: "\n"))
        """.trimmingCharacters(in: .whitespacesAndNewlines)

        if let conditionStatement = conditionStatement {
            return """
            \(sql)
            where 1 = 1
            \(conditionStatement.stringValue)
            """
        }

        return sql
    }

    var variables: [Binding?] {
        return conditionStatement?.variables ?? []
    }

}

// MARK: - Helpers

/// Join a list of table columns joined and formatted for readability.
///
/// - Parameter columns the list of column names
/// - Parameter perLine max numbers of columns per line
/// - Returns: a list of columns that can be used in `select` SQL statements
internal func joinedAsSelectedColumns(_ columns: [String], perLine: Int = 3) -> String {
    return columns.enumerated().reduce("") { partial, entry in
        let spacer = entry.offset == 0 || entry.offset % perLine == 0 ? "\n  " : " "
        let isFirstOrLast = entry.offset == 0 || entry.offset >= columns.count
        let separator = isFirstOrLast ? "" : ",\(spacer)"
        return partial + separator + entry.element
    }
}
