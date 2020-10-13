//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSPluginsCore
import Combine

@available(iOS 13.0, *)
protocol InitialSyncOrchestrator {
    var publisher: AnyPublisher<InitialSyncOperationEvent, DataStoreError> { get }
    func sync(completion: @escaping (Result<Void, DataStoreError>) -> Void)
}

// For testing
@available(iOS 13.0, *)
typealias InitialSyncOrchestratorFactory =
    (DataStoreConfiguration,
    APICategoryGraphQLBehavior?,
    IncomingEventReconciliationQueue?,
    StorageEngineAdapter?) -> InitialSyncOrchestrator

@available(iOS 13.0, *)
final class AWSInitialSyncOrchestrator: InitialSyncOrchestrator {
    typealias SyncOperationResult = Result<Void, DataStoreError>
    typealias SyncOperationResultHandler = (SyncOperationResult) -> Void

    private var initialSyncOperationSinks: [String: AnyCancellable]

    private let dataStoreConfiguration: DataStoreConfiguration
    private weak var api: APICategoryGraphQLBehavior?
    private weak var reconciliationQueue: IncomingEventReconciliationQueue?
    private weak var storageAdapter: StorageEngineAdapter?

    private var completion: SyncOperationResultHandler?

    private var syncErrors: [DataStoreError]

    // Future optimization: can perform sync on each root in parallel, since we know they won't have any
    // interdependencies
    private let syncOperationQueue: OperationQueue

    private let initialSyncOrchestratorTopic: PassthroughSubject<InitialSyncOperationEvent, DataStoreError>
    var publisher: AnyPublisher<InitialSyncOperationEvent, DataStoreError> {
        return initialSyncOrchestratorTopic.eraseToAnyPublisher()
    }

    init(dataStoreConfiguration: DataStoreConfiguration,
         api: APICategoryGraphQLBehavior?,
         reconciliationQueue: IncomingEventReconciliationQueue?,
         storageAdapter: StorageEngineAdapter?) {
        self.initialSyncOperationSinks = [:]
        self.dataStoreConfiguration = dataStoreConfiguration
        self.api = api
        self.reconciliationQueue = reconciliationQueue
        self.storageAdapter = storageAdapter

        let syncOperationQueue = OperationQueue()
        syncOperationQueue.name = "com.amazon.InitialSyncOrchestrator"
        syncOperationQueue.maxConcurrentOperationCount = 1
        syncOperationQueue.isSuspended = true
        self.syncOperationQueue = syncOperationQueue

        self.syncErrors = []
        self.initialSyncOrchestratorTopic = PassthroughSubject<InitialSyncOperationEvent, DataStoreError>()
    }

    /// Performs an initial sync on all models
    func sync(completion: @escaping SyncOperationResultHandler) {
        syncOperationQueue.addOperation {
            self.completion = completion

            self.log.info("Beginning initial sync")

            let syncableModels = ModelRegistry.models.filter { $0.schema.isSyncable }
            self.enqueueSyncableModels(syncableModels)

            let modelNames = syncableModels.map { $0.modelName }
            self.dispatchSyncQueriesStarted(for: modelNames)
        }
        syncOperationQueue.isSuspended = false
    }

    private func enqueueSyncableModels(_ syncableModels: [Model.Type]) {
        let sortedModels = syncableModels.sortByDependencyOrder()
        for model in sortedModels {
            enqueueSyncOperation(for: model)
        }
    }

    /// Enqueues sync operations for models and downstream dependencies
    private func enqueueSyncOperation(for modelType: Model.Type) {
        let initialSyncForModel = InitialSyncOperation(modelType: modelType,
                                                       api: api,
                                                       reconciliationQueue: reconciliationQueue,
                                                       storageAdapter: storageAdapter,
                                                       dataStoreConfiguration: dataStoreConfiguration)

        initialSyncOperationSinks[modelType.modelName] = initialSyncForModel
            .publisher
            .receive(on: syncOperationQueue)
            .sink(receiveCompletion: { result in
                if case .failure(let dataStoreError) = result {
                    let syncError = DataStoreError.sync(
                        "An error occurred syncing \(modelType.modelName)",
                        "",
                        dataStoreError)
                    self.syncErrors.append(syncError)
                }
                self.initialSyncOperationSinks.removeValue(forKey: modelType.modelName)
                self.onReceiveCompletion()
            }, receiveValue: onReceiveValue(_:))

        syncOperationQueue.addOperation(initialSyncForModel)
    }

    private func onReceiveValue(_ value: InitialSyncOperationEvent) {
        initialSyncOrchestratorTopic.send(value)
    }

    private func onReceiveCompletion() {
        guard initialSyncOperationSinks.isEmpty else {
            return
        }

        let completionResult = makeCompletionResult()
        if case .success = completionResult {
            initialSyncOrchestratorTopic.send(completion: .finished)
        }
        completion?(completionResult)
    }

    private func makeCompletionResult() -> Result<Void, DataStoreError> {
        guard syncErrors.isEmpty else {
            let allMessages = syncErrors.map { String(describing: $0) }
            let syncError = DataStoreError.sync(
                "One or more errors occurred syncing models. See below for detailed error description.",
                allMessages.joined(separator: "\n")
            )
            return .failure(syncError)
        }
        return .successfulVoid
    }

    private func dispatchSyncQueriesStarted(for modelNames: [String]) {
        let syncQueriesStartedEvent = SyncQueriesStartedEvent(models: modelNames)
        let syncQueriesStartedEventPayload = HubPayload(eventName: HubPayload.EventName.DataStore.syncQueriesStarted,
                                                        data: syncQueriesStartedEvent)
        Amplify.Hub.dispatch(to: .dataStore, payload: syncQueriesStartedEventPayload)
    }
}

@available(iOS 13.0, *)
extension AWSInitialSyncOrchestrator: DefaultLogger { }

@available(iOS 13.0, *)
extension AWSInitialSyncOrchestrator: Resettable {
    func reset(onComplete: @escaping BasicClosure) {
        syncOperationQueue.cancelAllOperations()
        syncOperationQueue.waitUntilAllOperationsAreFinished()
        onComplete()
    }
}
