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

    // TODO: Make this private once we get a request/response flow with metadata/mutation types figured out
    let adapter: StorageEngineAdapter

    private var syncEngine: CloudSyncEngineBehavior?

    // Internal initializer used for testing, to allow lazy initialization of the SyncEngine
    init(adapter: StorageEngineAdapter,
         syncEngineFactory: CloudSyncEngineBehavior.Factory?) {
        self.adapter = adapter
        let syncEngine = syncEngineFactory?(self)
        self.syncEngine = syncEngine
    }

    convenience init(isSyncEnabled: Bool) throws {
        let key = kCFBundleNameKey as String
        let databaseName = Bundle.main.object(forInfoDictionaryKey: key) as? String
        let adapter = try SQLiteStorageEngineAdapter(databaseName: databaseName ?? "app")

        let syncEngineFactory: CloudSyncEngineBehavior.Factory? =
            isSyncEnabled ? { CloudSyncEngine(storageEngine: $0) } : nil

        self.init(adapter: adapter, syncEngineFactory: syncEngineFactory)
    }

    public func setUp(models: [Model.Type]) throws {
        try adapter.setUp(models: models)
    }

    public func save<M: Model>(_ model: M, completion: @escaping DataStoreCallback<M>) {
        // TODO: Refactor this into a proper request/result where the result includes metadata like the derived
        // mutation type
        let modelExists: Bool
        do {
            modelExists = try adapter.exists(M.self, withId: model.id)
        } catch {
            let dataStoreError = DataStoreError.invalidOperation(causedBy: error)
            completion(.error(dataStoreError))
            return
        }

        let mutationType = modelExists ? MutationEvent.MutationType.update : .create

        let saveMutationEventCompletion: DataStoreCallback<M> = { result in
            guard type(of: model).schema.isSyncable, let syncEngine = self.syncEngine else {
                completion(result)
                return
            }

            guard case .result(let savedModel) = result else {
                completion(result)
                return
            }

            do {
                let mutationEvent = try MutationEvent(model: savedModel, mutationType: mutationType)

                // TODO: Refactor this into something actually readable once we get the final sync implementation done
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

                    }, receiveValue: { _ in
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

        adapter.save(model, completion: saveMutationEventCompletion)

    }

    public func delete<M: Model>(_ modelType: M.Type,
                                 withId id: Model.Identifier,
                                 completion: (DataStoreResult<Void>) -> Void) {
        adapter.delete(modelType, withId: id, completion: completion)
    }

    public func query<M: Model>(_ modelType: M.Type,
                                predicate: QueryPredicate? = nil,
                                completion: DataStoreCallback<[M]>) {
        return adapter.query(modelType, predicate: predicate, completion: completion)
    }

    func startSync() {
        syncEngine?.start()
    }
}
