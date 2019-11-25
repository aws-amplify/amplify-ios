//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSPluginsCore
import Foundation
import SQLite

/// [SQLite](https://sqlite.org) `StorageEngineAdapter` implementation. This class provides
/// an integration layer between the AppSyncLocal `StorageEngine` and SQLite for local storage.
final class SQLiteStorageEngineAdapter: StorageEngineAdapter {

    internal var connection: Connection!

    convenience init(databaseName: String = "database") throws {
        guard let documentsPath = getDocumentPath() else {
            preconditionFailure("Could not create the database. The `.documentDirectory` is invalid")
        }
        let path = documentsPath.appendingPathComponent("\(databaseName).db").absoluteString

        do {
            let connection = try Connection(path)
            self.init(connection: connection)
        } catch {
            throw DataStoreError.invalidDatabase(path: path, error)
        }
    }

    internal init(connection: Connection) {
        log.debug("Created database connection at \(connection)")
        self.connection = connection
    }

    func setUp(models: [Model.Type]) throws {
        let createTableStatements = models
            .sortByDependencyOrder()
            .map { CreateTableStatement(modelType: $0).stringValue }
            .joined(separator: "\n")

        // database setup statement
        let statement = """
        pragma auto_vacuum = full;
        pragma encoding = "utf-8";
        pragma foreign_keys = on;
        pragma case_sensitive_like = off;
        \(createTableStatements)
        """

        do {
            try connection.execute(statement)
        } catch {
            throw DataStoreError.invalidOperation(causedBy: error)
        }
    }

    func save<M: Model>(_ model: M, completion: DataStoreCallback<M>) {
        do {
            let modelType = type(of: model)
            let shouldUpdate = try exists(modelType, withId: model.id)

            // TODO serialize result and create a new instance of the model
            // (some columns might be auto-generated after DB insert/update)
            if shouldUpdate {
                let statement = UpdateStatement(model: model)
                _ = try connection.prepare(statement.stringValue).run(statement.variables)
            } else {
                let statement = InsertStatement(model: model)
                _ = try connection.prepare(statement.stringValue).run(statement.variables)
            }

            completion(.result(model))
        } catch {
            completion(.failure(causedBy: error))
        }
    }

    func delete(_ modelType: Model.Type,
                withId id: Model.Identifier,
                completion: (DataStoreResult<Void>) -> Void) {
        do {
            let statement = DeleteStatement(modelType: modelType, withId: id)
            _ = try connection.prepare(statement.stringValue).run(statement.variables)
            completion(.emptyResult)
        } catch {
            completion(.failure(causedBy: error))
        }

    }

    func query<M: Model>(_ modelType: M.Type,
                         predicate: QueryPredicate? = nil,
                         completion: DataStoreCallback<[M]>) {
        do {
            let statement = SelectStatement(from: modelType, predicate: predicate)
            let rows = try connection.prepare(statement.stringValue).run(statement.variables)
            let result: [M] = try rows.convert(to: modelType)
            completion(.result(result))
        } catch {
            completion(.failure(causedBy: error))
        }
    }

    func exists(_ modelType: Model.Type, withId id: Model.Identifier) throws -> Bool {
        let schema = modelType.schema
        let primaryKey = schema.primaryKey.sqlName
        let sql = "select count(\(primaryKey)) from \(schema.name) where \(primaryKey) = ?"

        let result = try connection.scalar(sql, [id])
        guard let count = result as? Int64, count <= 1 else {
            throw DataStoreError.nonUniqueResult(model: schema.name)
        }
        return count == 1
    }

}

// MARK: - Private Helpers

/// Helper function that can be used as a shortcut to access the user's document
/// directory on the underlying OS. This is used to create the SQLite database file.
///
/// - Returns: the path to the user document directory.
private func getDocumentPath() -> URL? {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
}

extension SQLiteStorageEngineAdapter: DefaultLogger { }
