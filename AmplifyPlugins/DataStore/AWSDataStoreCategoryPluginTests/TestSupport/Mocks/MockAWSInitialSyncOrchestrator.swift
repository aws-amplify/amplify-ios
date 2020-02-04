//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import AWSPluginsCore
import Combine

@testable import Amplify
@testable import AmplifyTestCommon
@testable import AWSDataStoreCategoryPlugin

class MockAWSInitialSyncOrchestrator: InitialSyncOrchestrator {
    static let factory: InitialSyncOrchestratorFactory = { api, reconciliationQueue, storageAdapter in
        MockAWSInitialSyncOrchestrator(api: api, reconciliationQueue: reconciliationQueue, storageAdapter: storageAdapter)
    }

    typealias SyncOperationResult = Result<Void, DataStoreError>
    typealias SyncOperationResultHandler = (SyncOperationResult) -> Void

    private static var instance: MockAWSInitialSyncOrchestrator?
    private static var mockedResponse: SyncOperationResult?

    init(api: APICategoryGraphQLBehavior?,
         reconciliationQueue: IncomingEventReconciliationQueue?,
         storageAdapter: StorageEngineAdapter?) {
    }

    static func reset() {
        mockedResponse = nil
    }

    static func setResponseOnSync(result: SyncOperationResult) {
        mockedResponse = result
    }

    func sync(completion: @escaping SyncOperationResultHandler) {
        let response = MockAWSInitialSyncOrchestrator.mockedResponse ?? .successfulVoid
        completion(response)
    }
}
