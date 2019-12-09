//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import AWSPluginsCore

@testable import Amplify
@testable import AWSDataStoreCategoryPlugin

class MockSQLiteStorageEngineAdapter: StorageEngineAdapter {
    var responders = [ResponderKeys: Any]()

    var resultForQuery: DataStoreResult<[Model]>?
    var resultForSave: DataStoreResult<Model>?

    var resultForQueryMutationSyncMetadata: MutationSyncMetadata?
    var errorToThrowOnMutationSyncMetadata: DataStoreError?

    var shouldReturnErrorOnSaveMetadata: Bool
    var shouldReturnErrorOnDeleteMutation: Bool

    var resultForQueryModelSyncMetadata: ModelSyncMetadata?
    var listenerForModelSyncMetadata: BasicClosure?

    let testCase: XCTestCase

    init(testCase: XCTestCase) {
        self.testCase = testCase
        self.shouldReturnErrorOnSaveMetadata = false
        self.shouldReturnErrorOnDeleteMutation = false
    }

    func setUp(models: [Model.Type]) throws {
        testCase.recordFailure(withDescription: "Not expected to execute",
                               inFile: #file,
                               atLine: #line,
                               expected: true)
    }

    // MARK: - Responses

    func returnOnQuery(dataStoreResult: DataStoreResult<[Model]>?) {
        resultForQuery = dataStoreResult
    }

    func returnOnQueryMutationSyncMetadata(_ mutationSyncMetadata: MutationSyncMetadata?) {
        resultForQueryMutationSyncMetadata = mutationSyncMetadata
    }

    func returnOnSave(dataStoreResult: DataStoreResult<Model>?) {
        resultForSave = dataStoreResult
    }

    func returnOnQueryModelSyncMetadata(_ metadata: ModelSyncMetadata?, listener: BasicClosure? = nil) {
        resultForQueryModelSyncMetadata = metadata
        listenerForModelSyncMetadata = listener
    }

    func throwOnQueryMutationSyncMetadata(error: DataStoreError) {
        errorToThrowOnMutationSyncMetadata = error
    }

    // MARK: - StorageEngineAdapter

    func delete<M: Model>(_ modelType: M.Type,
                          withId id: Model.Identifier,
                          completion: DataStoreCallback<Void>) {
        testCase.recordFailure(withDescription: "Not expected to execute",
        inFile: #file,
        atLine: #line,
        expected: true)
    }

    func delete(untypedModelType modelType: Model.Type,
                withId id: String,
                completion: (Result<Void, DataStoreError>) -> Void) {
        return shouldReturnErrorOnDeleteMutation
            ? completion(.failure(causedBy: DataStoreError.invalidModelName("DelMutate")))
            : completion(.emptyResult)
    }

    func query(untypedModel modelType: Model.Type,
               predicate: QueryPredicate?,
               completion: DataStoreCallback<[Model]>) {
        let result = resultForQuery ?? .failure(DataStoreError.invalidOperation(causedBy: nil))
        completion(result)
    }

    func query<M: Model>(_ modelType: M.Type, predicate: QueryPredicate?, completion: DataStoreCallback<[M]>) {
        testCase.recordFailure(withDescription: "Not expected to execute", inFile: #file, atLine: #line, expected: true)
    }

    func queryMutationSync(for models: [Model]) throws -> [MutationSync<AnyModel>] {
        testCase.recordFailure(withDescription: "Not expected to execute", inFile: #file, atLine: #line, expected: true)
        return []
    }

    func exists(_ modelType: Model.Type, withId id: Model.Identifier) throws -> Bool {
        testCase.recordFailure(withDescription: "Not expected to execute", inFile: #file, atLine: #line, expected: true)
        return true
    }

    func save(untypedModel: Model, completion: @escaping DataStoreCallback<Model>) {
        if let responder = responders[.saveUntypedModel] as? SaveUntypedModelResponder {
            responder.callback((untypedModel, completion))
            return
        }

        completion(resultForSave!)
    }

    func save<M: Model>(_ model: M, completion: @escaping DataStoreCallback<M>) {
        if let responder = responders[.saveModelCompletion] as? SaveModelCompletionResponder<M> {
            responder.callback((model, completion))
            return
        }

        return shouldReturnErrorOnSaveMetadata
            ? completion(.failure(DataStoreError.invalidModelName("forceError")))
            : completion(.success(model))
    }

    func queryMutationSync(forAnyModel anyModel: AnyModel) throws -> MutationSync<AnyModel>? {
        testCase.recordFailure(withDescription: "Not expected to execute", inFile: #file, atLine: #line, expected: true)
        return nil
    }

    func query<M: Model>(_ modelType: M.Type,
                         predicate: QueryPredicate?,
                         additionalStatements: String?,
                         completion: DataStoreCallback<[M]>) {
        if let responder = responders[.queryModelTypePredicateAdditionalStatements]
            as? QueryModelTypePredicateAdditionalStatementsResponder<M> {
            let result = responder.callback((modelType, predicate, additionalStatements))
            completion(result)
            return
        }

        completion(.success([]))
    }

    func queryMutationSyncMetadata(for modelId: String) throws -> MutationSyncMetadata? {
        if let responder = responders[.queryMutationSyncMetadata] as? QueryMutationSyncMetadataResponder {
            return try responder.callback(modelId)
        }

        if let err = errorToThrowOnMutationSyncMetadata {
            errorToThrowOnMutationSyncMetadata = nil
            throw err
        }
        return resultForQueryMutationSyncMetadata
    }

    func queryModelSyncMetadata(for modelType: Model.Type) throws -> ModelSyncMetadata? {
        listenerForModelSyncMetadata?()
        return resultForQueryModelSyncMetadata
    }
}

class MockStorageEngineBehavior: StorageEngineBehavior {
    let testCase: XCTestCase

    init(testCase: XCTestCase) {
        self.testCase = testCase
    }

    func startSync() {
    }

    func setUp(models: [Model.Type]) throws {
    }

    func save<M: Model>(_ model: M, completion: @escaping DataStoreCallback<M>) {
        testCase.recordFailure(withDescription: "Not expected to execute", inFile: #file, atLine: #line, expected: true)
    }

    func delete<M: Model>(_ modelType: M.Type,
                          withId id: Model.Identifier,
                          completion: DataStoreCallback<Void>) {
        testCase.recordFailure(withDescription: "Not expected to execute", inFile: #file, atLine: #line, expected: true)
    }

    func query<M: Model>(_ modelType: M.Type, predicate: QueryPredicate?, completion: DataStoreCallback<[M]>) {
        testCase.recordFailure(withDescription: "Not expected to execute", inFile: #file, atLine: #line, expected: true)
    }
}
