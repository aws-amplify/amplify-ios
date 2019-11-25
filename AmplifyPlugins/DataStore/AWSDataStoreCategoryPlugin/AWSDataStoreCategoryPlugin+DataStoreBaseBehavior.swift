//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify

extension AWSDataStoreCategoryPlugin: DataStoreBaseBehavior {

    public func save<M: Model>(_ model: M,
                               completion: @escaping DataStoreCallback<M>) {
        log.verbose("save: \(model)")

        // TODO: Refactor this into a proper request/result where the result includes metadata like the derived
        // mutation type
        let modelExists: Bool
        do {
            guard let engine = storageEngine as? StorageEngine else {
                throw DataStoreError.configuration("Unable to get storage adapter",
                                                   "")
            }
            modelExists = try engine.adapter.exists(M.self, withId: model.id)
        } catch {
            if let dataStoreError = error as? DataStoreError {
                completion(.error(dataStoreError))
                return
            }

            let dataStoreError = DataStoreError.invalidOperation(causedBy: error)
            completion(.error(dataStoreError))
            return
        }

        let mutationType = modelExists ? MutationEvent.MutationType.update : .create

        let publishingCompletion: DataStoreCallback<M> = { result in
            switch result {
            case .result(let model):
                // TODO: Differentiate between save & update
                // TODO: Handle errors from mutation event creation
                if let mutationEvent = try? MutationEvent(model: model, mutationType: mutationType) {
                    self.dataStorePublisher.send(input: mutationEvent)
                }
            case .error:
                break
            }

            completion(result)
        }

        storageEngine.save(model, completion: publishingCompletion)
    }

    public func query<M: Model>(_ modelType: M.Type,
                                byId id: String,
                                completion: DataStoreCallback<M?>) {
        let predicate: QueryPredicateFactory = { field("id") == id }
        query(modelType, where: predicate) {
            switch $0 {
            case .result(let models):
                if models.count > 1 {
                    completion(.error(.nonUniqueResult(model: modelType.schema.name)))
                } else {
                    completion(.result(models.first))
                }
            case .error(let error):
                completion(.failure(causedBy: error))
            }
        }
    }

    public func query<M: Model>(_ modelType: M.Type,
                                where predicateFactory: QueryPredicateFactory?,
                                completion: DataStoreCallback<[M]>) {
        storageEngine.query(modelType,
                            predicate: predicateFactory?(),
                            completion: completion)
    }

    public func delete<M: Model>(_ model: M,
                                 completion: DataStoreCallback<Void>) {
        let publishingCompletion: DataStoreCallback<Void> = { result in
            switch result {
            case .result:
                // TODO: Handle errors from mutation event creation
                if let mutationEvent = try? MutationEvent(model: model, mutationType: .delete) {
                    self.dataStorePublisher.send(input: mutationEvent)
                }
            case .error:
                break
            }
            completion(result)
        }

        delete(type(of: model),
               withId: model.id,
               completion: publishingCompletion)
    }

    public func delete<M: Model>(_ modelType: M.Type,
                                 withId id: String,
                                 completion: DataStoreCallback<Void>) {
        storageEngine.delete(modelType,
                             withId: id,
                             completion: completion)
    }

    public func reset(onComplete: @escaping (() -> Void)) {
        //        storageEngine.shutdown()
        onComplete()
    }

}

