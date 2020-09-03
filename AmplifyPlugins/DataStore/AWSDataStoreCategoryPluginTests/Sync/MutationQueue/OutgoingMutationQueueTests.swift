//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import SQLite

@testable import Amplify
@testable import AmplifyTestCommon
@testable import AWSDataStoreCategoryPlugin

class OutgoingMutationQueueTests: SyncEngineTestBase {

    /// - Given: A sync-configured DataStore
    /// - When:
    ///    - I invoke DataStore.save() for a new model
    /// - Then:
    ///    - The outgoing mutation queue sends a create mutation
    func testMutationQueueCreateSendsSync() throws {

        tryOrFail {
            try setUpStorageAdapter()
            try setUpDataStore(mutationQueue: OutgoingMutationQueue(storageAdapter: storageAdapter,
                                                                    dataStoreConfiguration: .default))
        }

        let post = Post(title: "Post title",
                        content: "Post content",
                        createdAt: .now())

        var outboxStatusReceivedCurrentCount = 0
        let outboxStatusOnStart = expectation(description: "On DataStore start, outboxStatus received")
        let outboxStatusOnMutationEnqueued = expectation(description: "Mutation enqueued, outboxStatus received")

        let hubListener = Amplify.Hub.listen(to: .dataStore) { payload in
            if payload.eventName == HubPayload.EventName.DataStore.outboxStatus {
                outboxStatusReceivedCurrentCount += 1
                XCTAssertNotNil(payload.data)
                guard let outboxStatusEvent = payload.data as? OutboxStatusEvent else {
                    XCTFail("Failed to cast payload data as OutboxStatusEvent")
                    return
                }

                if outboxStatusReceivedCurrentCount == 1 {
                    XCTAssertEqual(outboxStatusEvent.isEmpty, true)
                    outboxStatusOnStart.fulfill()
                } else {
                    XCTAssertEqual(outboxStatusEvent.isEmpty, false)
                    outboxStatusOnMutationEnqueued.fulfill()
                }
            }
        }

        guard try HubListenerTestUtilities.waitForListener(with: hubListener, timeout: 5.0) else {
            XCTFail("Listener not registered for hub")
            return
        }

        let createMutationSent = expectation(description: "Create mutation sent to API category")
        apiPlugin.listeners.append { message in
            if message.contains("createPost") && message.contains(post.id) {
                createMutationSent.fulfill()
            }
        }

        try startAmplifyAndWaitForSync()

        Amplify.DataStore.save(post) { _ in }
        waitForExpectations(timeout: 5.0, handler: nil)
        Amplify.Hub.removeListener(hubListener)
    }

    /// - Given: A sync-configured DataStore
    /// - When:
    ///    - I invoke DataStore.delete()
    /// - Then:
    ///    - The mutation queue writes events
    func testMutationQueueStoresDeleteEvents() {
        XCTFail("Not yet implemented")
    }

    /// - Given: A sync-configured DataStore
    /// - When:
    ///    - I start syncing with mutation events already in the database
    /// - Then:
    ///    - The mutation queue delivers the first previously loaded event
    func testMutationQueueLoadsPendingMutations() throws {

        tryOrFail {
            try setUpStorageAdapter()
        }

        // pre-load the MutationEvent table with mutation data
        let mutationEventSaved = expectation(description: "Preloaded mutation event saved")
        mutationEventSaved.expectedFulfillmentCount = 2
        for id in 1 ... 2 {
            let postId = "pendingPost-\(id)"
            let pendingPost = Post(id: postId,
                                   title: "pendingPost-\(id) title",
                content: "pendingPost-\(id) content",
                createdAt: .now())

            let pendingPostJSON = try pendingPost.toJSON()
            let event = MutationEvent(id: "mutation-\(id)",
                modelId: "pendingPost-\(id)",
                modelName: Post.modelName,
                json: pendingPostJSON,
                mutationType: .create,
                createdAt: .now())

            storageAdapter.save(event) { result in
                switch result {
                case .failure(let dataStoreError):
                    XCTFail(String(describing: dataStoreError))
                case .success:
                    mutationEventSaved.fulfill()
                }
            }

        }

        wait(for: [mutationEventSaved], timeout: 1.0)

        var outboxStatusReceivedCurrentCount = 0
        let outboxStatusOnStart = expectation(description: "On DataStore start, outboxStatus received")
        let outboxStatusOnMutationEnqueued = expectation(description: "Mutation enqueued, outboxStatus received")

        let hubListener = Amplify.Hub.listen(to: .dataStore) { payload in
            if payload.eventName == HubPayload.EventName.DataStore.outboxStatus {
                outboxStatusReceivedCurrentCount += 1
                XCTAssertNotNil(payload.data)
                guard let outboxStatusEvent = payload.data as? OutboxStatusEvent else {
                    XCTFail("Failed to cast payload data as OutboxStatusEvent")
                    return
                }

                if outboxStatusReceivedCurrentCount == 1 {
                    XCTAssertEqual(outboxStatusEvent.isEmpty, false)
                    outboxStatusOnStart.fulfill()
                } else {
                    XCTAssertEqual(outboxStatusEvent.isEmpty, false)
                    outboxStatusOnMutationEnqueued.fulfill()
                }
            }
        }

        guard try HubListenerTestUtilities.waitForListener(with: hubListener, timeout: 5.0) else {
            XCTFail("Listener not registered for hub")
            return
        }

        let mutation1Sent = expectation(description: "Create mutation 1 sent to API category")
        let mutation2Sent = expectation(description: "Create mutation 2 sent to API category")
        mutation2Sent.isInverted = true
        apiPlugin.listeners.append { message in
            if message.contains("createPost") && message.contains("pendingPost-1") {
                mutation1Sent.fulfill()
            } else if message.contains("createPost") && message.contains("pendingPost-2") {
                mutation2Sent.fulfill()
            }
        }

        tryOrFail {
            try setUpDataStore(mutationQueue: OutgoingMutationQueue(storageAdapter: storageAdapter,
                                                                    dataStoreConfiguration: .default))
            try startAmplify()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
        Amplify.Hub.removeListener(hubListener)
    }

    /// - Given: A sync-configured DataStore
    /// - When:
    ///    - I start syncing with mutation events already in the database
    ///    - I add mutations before the pending mutations have been processed
    /// - Then:
    ///    - The mutation queue delivers events in FIFO order
    func testMutationQueueDeliversPendingMutationsFirst() {
        XCTFail("Not yet implemented")
    }

    /// - Given: A sync-configured DataStore
    /// - When:
    ///    - I successfully process a mutation
    /// - Then:
    ///    - The mutation queue deletes the event from its persistent store
    func testMutationQueueDequeuesSavedEvents() {
        XCTFail("Not yet implemented")
    }

    /// - Given: A sync-configured DataStore
    /// - When:
    ///    - I successfully process a mutation
    /// - Then:
    ///    - The mutation listener is unsubscribed from Hub
    func testLocalMutationUnsubcsribesFromCloud() {
        XCTFail("Not yet implemented")
    }

}
