//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation
import SQLite

extension String {
    
    /// Utility for wrapping the string in double quotes.
    func quoted() -> String {
        return "\"\(self)\""
    }
}

/// SQLite supportted data types.
enum SQLDataType: String {
    case text
    case integer
    case real
}

/// Protocol that adds SQL-specific behavior to `ModelKey` types.
protocol SQLColumn {

    /// The name of the field as a SQL column.
    var sqlName: String { get }

    /// The underlying SQLite data type.
    var sqlType: SQLDataType { get }

    /// Computed property that indicates if the field is a foreign key or not.
    var isForeignKey: Bool { get }
}

extension ModelField: SQLColumn {

    var sqlName: String {
        return isForeignKey ? name + "Id" : name
    }

    var sqlType: SQLDataType {
        switch typeDefinition {
        case .string, .enum, .date, .dateTime, .model:
            return .text
        case .int, .bool:
            return .integer
        case .double:
            return .real
        default:
            return .text
        }
    }

    var isForeignKey: Bool {
        switch typeDefinition {
        case .model:
            return true
        default:
            return false
        }
    }

    /// If the field represents a relationship (aka connected) returns the `Model.Type` of
    /// the connection. Connected types are represented by `.model(type)` and `.collection(type)`.
    /// - seealso: `ModelFieldType`
    var connectedModel: Model.Type? {
        switch typeDefinition {
        case .model(let type), .collection(let type):
            return type
        default:
            return nil
        }
    }

    /// Get the name of the `ModelField` as a SQL column name. Columns can be optionally namespaced
    /// and are always wrapped in quotes so reserved words are escaped.
    ///
    /// For instance, `columnName(forNamespace: "root")` on a field named "id" returns `"root"."id"`
    ///
    /// - Parameter namespace: the optional column namespace
    /// - Returns: a valid (i.e. escaped) SQL column name
    func columnName(forNamespace namespace: String? = nil) -> String {
        var column = sqlName.quoted()
        if let namespace = namespace {
            column = namespace.quoted() + "." + column
        }
        return column
    }

    /// Get the column alias of a `ModelField`. Aliases are useful for serialization of SQL query
    /// results to `Model` properties. A column alias might also have an optional `namespace` that
    /// allows nested properties to be represented by their full path.
    ///
    /// For instance, if a model named `Comment` has a reference to model named `Post` through the
    /// `post` property, the nested `id` field could be aliased as `post.id`.
    ///
    /// - Parameter namespace: the optional alias namespace
    /// - Returns: the column alias prefixed by `as `. Example: if the `Model` field is named "id"
    /// the call `field.columnAlias(forNamespace: "post")` would return `as "post.id"`.
    func columnAlias(forNamespace namespace: String? = nil) -> String {
        var column = sqlName
        if let namespace = namespace {
            column = "\(namespace).\(column)"
        }
        return "as \(column.quoted())"
    }

    /// Converts a SQLite value type (i.e. `Binding`) to `ModelField` type. Type conversions are done
    /// in order to create a bridge between SQLite restricted support to types and the actual Swift
    /// types defined in the `Model`. For example, `Bool` values are represented as `Int64` in SQLite
    /// and must be converted back to `Bool` for decoding a `Model`.
    ///
    /// - Parameter binding: the SQLite `Binding` value. Can be `nil`
    /// - Returns: the actual `Model` value, can be `nil`
    /// - seealso: `ModelFieldType`
    func value(from binding: Binding?) -> Any? {
        switch typeDefinition {
        case .bool:
            if let value = binding as? Int64 {
                return Bool.fromDatatypeValue(value)
            }
        case .date, .dateTime:
            if let value = binding as? String {
                // The decoder translates Double to Date
                return Date.fromDatatypeValue(value).timeIntervalSince1970
            }
        case .collection:
            return binding ?? []
        default:
            return binding
        }
        return binding
    }
}

/// Array utilities for `ModelField`.
extension Array where Element == ModelField {

    /// Filter the fields that represent actual columns on the `Model` SQL table. The definition of
    /// a column is a field that either represents a scalar value (e.g. string, number, etc) or
    /// the owner of a foreign key to another `Model`. Fields that reference the inverse side of
    /// the relationship (i.e. the "one" side of a "one-to-many" relationship) are excluded.
    func columns() -> [ModelField] {
        return filter { !$0.isConnected || $0.isForeignKey }
    }

    /// Filter the fields that represent foreign keys.
    func foreignKeys() -> [ModelField] {
        return filter { $0.isForeignKey }
    }

}
