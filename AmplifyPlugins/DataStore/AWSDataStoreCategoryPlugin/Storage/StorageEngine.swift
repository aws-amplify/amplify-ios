//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Combine
import Foundation

final class StorageEngine: StorageEngineBehavior {

    let adapter: StorageEngineAdapter
    let syncEngine: CloudSyncEngineBehavior?

    public init(adapter: StorageEngineAdapter,
                syncEngine: CloudSyncEngineBehavior?) {
        self.adapter = adapter
        self.syncEngine = syncEngine
    }

    convenience init(isSyncEnabled: Bool) throws {
        let key = kCFBundleNameKey as String
        let databaseName = Bundle.main.object(forInfoDictionaryKey: key) as? String
        let adapter = try SQLiteStorageEngineAdapter(databaseName: databaseName ?? "app")

        let syncEngine = isSyncEnabled ? CloudSyncEngine(storageEngine: adapter) : nil
        self.init(adapter: adapter, syncEngine: syncEngine)
    }

    public func setUp(models: [Model.Type]) throws {
        try adapter.setUp(models: models)
        syncEngine?.start(storageEngine: self)
    }

    public func save<M: Model>(_ model: M, completion: @escaping DataStoreCallback<M>) {

        let modelSaveCompletion: DataStoreCallback<M> = { result in
            guard type(of: model).schema.isSyncable, let syncEngine = self.syncEngine else {
                completion(result)
                return
            }

            guard case .result(let savedModel) = result else {
                completion(result)
                return
            }

            do {
                let mutationEvent = try MutationEvent(model: savedModel, mutationType: .create)

                _ = syncEngine
                    .submit(mutationEvent)
                    .sink(
                        receiveCompletion: { futureCompletion in
                            switch futureCompletion {
                            case .failure(let error):
                                completion(.failure(causedBy: error))
                            default:
                                // Success case handled by receiveValue
                                break
                            }

                    }, receiveValue: { mutationEvent in
                        completion(.result(savedModel))
                    })
            } catch let dataStoreError as DataStoreError {
                completion(.error(dataStoreError))
            } catch {
                let dataStoreError = DataStoreError.decodingError(
                    "Could not create MutationEvent from model",
                    """
                    Review the data in the model below and ensure it doesn't contain invalid UTF8 data:

                    \(savedModel)
                    """)
                completion(.error(dataStoreError))
            }
        }

        adapter.save(model, completion: modelSaveCompletion)

    }

    public func delete<M: Model>(_ modelType: M.Type,
                                 withId id: Identifier,
                                 completion: (DataStoreResult<Void>) -> Void) {
        adapter.delete(modelType, withId: id, completion: completion)
    }

    public func query<M: Model>(_ modelType: M.Type,
                                predicate: QueryPredicate? = nil,
                                completion: DataStoreCallback<[M]>) {
        return adapter.query(modelType, predicate: predicate, completion: completion)
    }

}
