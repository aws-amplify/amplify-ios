//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest

@testable import Amplify
@testable import AmplifyTestCommon
@testable import AWSDataStoreCategoryPlugin
@testable import AWSPluginsCore

class InitialSyncOrchestratorTests: XCTestCase {

    override class func setUp() {
        Amplify.Logging.logLevel = .info
        ModelRegistry.reset()
        PostCommentModelRegistration().registerModels(registry: ModelRegistry.self)
    }

    /// - Given: An InitialSyncOrchestrator with a model dependency graph
    /// - When:
    ///    - The orchestrator starts up
    /// - Then:
    ///    - It performs a sync query for each registered model
    func testInvokesCompletionCallback() throws {
        let responder = QueryRequestListenerResponder<PaginatedList<AnyModel>> { _, listener in
            let startedAt = Int(Date().timeIntervalSince1970)
            let list = PaginatedList<AnyModel>(items: [], nextToken: nil, startedAt: startedAt)
            let event: GraphQLOperation<PaginatedList<AnyModel>>.Event = .completed(.success(list))
            listener?(event)
            return nil
        }

        let apiPlugin = MockAPICategoryPlugin()
        apiPlugin.responders[.queryRequestListener] = responder

        let storageAdapter = MockSQLiteStorageEngineAdapter()
        storageAdapter.returnOnQueryModelSyncMetadata(nil)

        let reconciliationQueue = MockReconciliationQueue()

        let orchestrator: InitialSyncOrchestrator =
            AWSInitialSyncOrchestrator(api: apiPlugin,
                                       reconciliationQueue: reconciliationQueue,
                                       storageAdapter: storageAdapter)

        let syncCallbackReceived = expectation(description: "Sync callback received, sync operation is complete")
        orchestrator.sync { _ in
            syncCallbackReceived.fulfill()
        }

        wait(for: [syncCallbackReceived], timeout: 1.0)
    }

    /// - Given: An InitialSyncOrchestrator with a model dependency graph
    /// - When:
    ///    - The orchestrator starts up
    /// - Then:
    ///    - It queries models in dependency order, from "parent" to "child"
    func testShouldQueryModelsInDependencyOrder() {
        let postWasQueried = expectation(description: "Post was queried")
        let commentWasQueried = expectation(description: "Comment was queried")
        let responder = QueryRequestListenerResponder<PaginatedList<AnyModel>> { request, listener in
            if request.document.hasPrefix("query SyncPosts") {
                postWasQueried.fulfill()
            }

            if request.document.hasPrefix("query SyncComments") {
                commentWasQueried.fulfill()
            }

            let startedAt = Int(Date().timeIntervalSince1970)
            let list = PaginatedList<AnyModel>(items: [], nextToken: nil, startedAt: startedAt)
            let event: GraphQLOperation<PaginatedList<AnyModel>>.Event = .completed(.success(list))
            listener?(event)
            return nil
        }

        let apiPlugin = MockAPICategoryPlugin()
        apiPlugin.responders[.queryRequestListener] = responder

        let storageAdapter = MockSQLiteStorageEngineAdapter()
        storageAdapter.returnOnQueryModelSyncMetadata(nil)

        let reconciliationQueue = MockReconciliationQueue()

        let orchestrator: InitialSyncOrchestrator =
            AWSInitialSyncOrchestrator(api: apiPlugin,
                                       reconciliationQueue: reconciliationQueue,
                                       storageAdapter: storageAdapter)

        orchestrator.sync { _ in }

        wait(for: [postWasQueried, commentWasQueried], timeout: 1.0, enforceOrder: true)
    }

    /// - Given: An InitialSyncOrchestrator with a model dependency graph
    /// - When:
    ///    - The orchestrator starts up
    /// - Then:
    ///    - It queries models in dependency order, from "parent" to "child", even if parent data is returned in
    ///      multiple pages
    func testShouldQueryModelsInDependencyOrderWithPaginatedResults() {
        let pageCount = 50

        let postWasQueried = expectation(description: "Post was queried")
        postWasQueried.expectedFulfillmentCount = pageCount

        let commentWasQueried = expectation(description: "Comment was queried")

        var nextTokens = Array(repeating: "token", count: pageCount - 1)

        let responder = QueryRequestListenerResponder<PaginatedList<AnyModel>> { request, listener in
            if request.document.hasPrefix("query SyncPosts") {
                postWasQueried.fulfill()
            }

            if request.document.hasPrefix("query SyncComments") {
                commentWasQueried.fulfill()
            }

            let startedAt = Int(Date().timeIntervalSince1970)
            let nextToken = nextTokens.isEmpty ? nil : nextTokens.removeFirst()
            let list = PaginatedList<AnyModel>(items: [], nextToken: nextToken, startedAt: startedAt)
            let event: GraphQLOperation<PaginatedList<AnyModel>>.Event = .completed(.success(list))
            listener?(event)
            return nil
        }

        let apiPlugin = MockAPICategoryPlugin()
        apiPlugin.responders[.queryRequestListener] = responder

        let storageAdapter = MockSQLiteStorageEngineAdapter()
        storageAdapter.returnOnQueryModelSyncMetadata(nil)

        let reconciliationQueue = MockReconciliationQueue()

        let orchestrator: InitialSyncOrchestrator =
            AWSInitialSyncOrchestrator(api: apiPlugin,
                                       reconciliationQueue: reconciliationQueue,
                                       storageAdapter: storageAdapter)

        orchestrator.sync { _ in }

        wait(for: [postWasQueried, commentWasQueried], timeout: 1.0, enforceOrder: true)
    }

}
