//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest

import AmplifyPlugins
import AWSPluginsCore

@testable import Amplify
@testable import AmplifyTestCommon
@testable import AWSDataStoreCategoryPlugin

// swiftlint:disable cyclomatic_complexity
// swiftlint:disable type_body_length
// swiftlint:disable file_length
class DataStoreConsecutiveUpdatesTests: SyncEngineIntegrationTestBase {
    /// - Given: API has been setup with `Post` model registered
    /// - When: A Post is saved and then immediately updated
    /// - Then: The post should be updated with new fields immediately and in the eventual consistent state
    func testSaveAndImmediatelyUpdate() throws {
        try startAmplifyAndWaitForSync()

        let newPost = Post(title: "MyPost",
                          content: "This is my post.",
                          createdAt: .now(),
                          rating: 3,
                          status: .published)

        var updatedPost = newPost
        updatedPost.rating = 5
        updatedPost.title = "MyUpdatedPost"
        updatedPost.content = "This is my updated post."

        let saveSyncReceived = expectation(description: "Received create mutation event on subscription for Post")
        let updateSyncReceived = expectation(description: "Received update mutation event on subscription for Post")

        let hubListener = Amplify.Hub.listen(
            to: .dataStore,
            eventName: HubPayload.EventName.DataStore.syncReceived) { payload in
            guard let mutationEvent = payload.data as? MutationEvent else {
                XCTFail("Can't cast payload as mutation event")
                return
            }

            guard let post = try? mutationEvent.decodeModel() as? Post, post.id == newPost.id else {
                return
            }

            if mutationEvent.mutationType == GraphQLMutationType.create.rawValue {
                XCTAssertEqual(post, newPost)
                XCTAssertEqual(mutationEvent.version, 1)
                saveSyncReceived.fulfill()
                return
            }

            if mutationEvent.mutationType == GraphQLMutationType.update.rawValue {
                // this should be removed once the bug is fixed
                // the bug is the update mutation event is being sent to the API with nil version,
                // causing a successful response with the existing post data
                XCTAssertEqual(post, newPost)

                // this is the expected behavior which is currently failing
                // XCTAssertEqual(post, updatedPost)

                XCTAssertEqual(mutationEvent.version, 2)
                updateSyncReceived.fulfill()
                return
            }
        }

        guard try HubListenerTestUtilities.waitForListener(with: hubListener, timeout: 5.0) else {
            XCTFail("Listener not registered for hub")
            return
        }

        let saveAndImmediatelyUpdate = expectation(description: "Post is saved and then immediately updated")
        Amplify.DataStore.save(newPost) { result in
            switch result {
            case .success:
                Amplify.DataStore.save(updatedPost) { result in
                    switch result {
                    case .success:
                        saveAndImmediatelyUpdate.fulfill()
                    case .failure(let error):
                        XCTFail("Error: \(error)")
                    }
                }
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
        }
        wait(for: [saveAndImmediatelyUpdate], timeout: networkTimeout)

        // query the updated post immediately
        guard let queryResult = queryPost(byId: updatedPost.id) else {
            XCTFail("Post should be available after update")
            return
        }
        XCTAssertEqual(queryResult, updatedPost)

        wait(for: [saveSyncReceived, updateSyncReceived], timeout: networkTimeout)

        // query the updated post in eventual consistent state
        guard let queryResultAfterSync = queryPost(byId: updatedPost.id) else {
            XCTFail("Post should be available after update and sync")
            return
        }

        // this should be removed once the bug is fixed
        // the bug is the update mutation event is being sent to the API with nil version,
        // causing a successful response with the existing post data
        XCTAssertEqual(queryResultAfterSync, newPost)

        // this is the expected behavior which is currently failing
        // XCTAssertEqual(queryResultAfterSync, updatedPost)

        let queryRequest =
            GraphQLRequest<MutationSyncResult?>.query(modelName: updatedPost.modelName, byId: updatedPost.id)
        let apiQuerySuccess = expectation(description: "API query is successful")
        Amplify.API.query(request: queryRequest) { result in
            switch result {
            case .success(let mutationSyncResult):
                switch mutationSyncResult {
                case .success(let data):
                    guard let post = data else {
                        XCTFail("Failed to get data")
                        return
                    }

                    // this should be removed once the bug is fixed
                    // the bug is the update mutation event is being sent to the API with nil version,
                    // causing a successful response with the existing post data
                    XCTAssertEqual(post.model["title"] as? String, newPost.title)
                    XCTAssertEqual(post.model["content"] as? String, newPost.content)
                    XCTAssertEqual(post.model["rating"] as? Double, newPost.rating)

                    // this is the expected behavior which is currently failing
                    // XCTAssertEqual(post.title, updatedPost.title)
                    // XCTAssertEqual(post.content, updatedPost.content)
                    // XCTAssertEqual(post.rating, updatedPost.rating)
                    XCTAssertEqual(post.syncMetadata.version, 2)
                    apiQuerySuccess.fulfill()
                case .failure(let error):
                    XCTFail("Error: \(error)")
                }
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
        }
        wait(for: [apiQuerySuccess], timeout: networkTimeout)
    }

    /// - Given: API has been setup with `Post` model registered
    /// - When: A Post is saved and deleted immediately
    /// - Then: The Post should not be returned when queried for immediately and in the eventual consistent state
    func testSaveAndImmediatelyDelete() throws {
        try startAmplifyAndWaitForSync()

        let newPost = Post(title: "MyPost",
                          content: "This is my post.",
                          createdAt: .now(),
                          rating: 3,
                          status: .published)

        let saveSyncReceived = expectation(description: "Received create mutation event on subscription for Post")
        // this can be uncommented out once the bug is fixed
        // currently the API request for delete mutation is sent with nil version, which
        // fails with error message "Conflict resolver rejects mutation."
        // because the request failed, subscription does not receive the delete event, and hub event is never fired
        // let deleteSyncReceived = expectation(description: "Received delete mutation event on subscription for Post")

        let hubListener = Amplify.Hub.listen(
            to: .dataStore,
            eventName: HubPayload.EventName.DataStore.syncReceived) { payload in
            guard let mutationEvent = payload.data as? MutationEvent else {
                XCTFail("Can't cast payload as mutation event")
                return
            }

            guard let post = try? mutationEvent.decodeModel() as? Post, post.id == newPost.id else {
                return
            }

            if mutationEvent.mutationType == GraphQLMutationType.create.rawValue {
                XCTAssertEqual(post, newPost)
                XCTAssertEqual(mutationEvent.version, 1)
                saveSyncReceived.fulfill()
                return
            }

            if mutationEvent.mutationType == GraphQLMutationType.delete.rawValue {
                XCTAssertEqual(post, newPost)
                // can be uncommented once delete mutation response is success
                // deleteSyncReceived.fulfill()
                return
            }
        }

        guard try HubListenerTestUtilities.waitForListener(with: hubListener, timeout: 5.0) else {
            XCTFail("Listener not registered for hub")
            return
        }

        let saveAndImmediatelyDelete = expectation(description: "Post is saved and then immediately deleted")
        Amplify.DataStore.save(newPost) { result in
            switch result {
            case .success:
                Amplify.DataStore.delete(newPost) { result in
                    switch result {
                    case .success:
                        saveAndImmediatelyDelete.fulfill()
                    case .failure(let error):
                        XCTFail("Error: \(error)")
                    }
                }
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
        }
        wait(for: [saveAndImmediatelyDelete], timeout: networkTimeout)

        // query the deleted post immediately
        let queryResult = queryPost(byId: newPost.id)
        XCTAssertNil(queryResult)

        wait(for: [saveSyncReceived], timeout: networkTimeout)
        // can be uncommented once delete mutation response is success
        // wait(for: [deleteSyncReceived], timeout: networkTimeout)

        // query the deleted post in eventual consistent state
        let queryResultAfterSync = queryPost(byId: newPost.id)

        // this should be removed once the bug is fixed, the post should actually be deleted
        XCTAssertNotNil(queryResultAfterSync)
        XCTAssertEqual(queryResultAfterSync, newPost)

        // this is the actual behavior which is currently failing
        // XCTAssertNil(post)

        let queryRequest =
            GraphQLRequest<MutationSyncResult?>.query(modelName: newPost.modelName, byId: newPost.id)
        let apiQuerySuccess = expectation(description: "API query is successful")
        Amplify.API.query(request: queryRequest) { result in
            switch result {
            case .success(let mutationSyncResult):
                switch mutationSyncResult {
                case .success(let data):
                    guard let post = data else {
                        XCTFail("Failed to get data")
                        return
                    }

                    XCTAssertEqual(post.model["title"] as? String, newPost.title)
                    XCTAssertEqual(post.model["content"] as? String, newPost.content)
                    XCTAssertEqual(post.model["rating"] as? Double, newPost.rating)
                    // the post should actually be deleted, but this is currently failing
                    XCTAssertFalse(post.syncMetadata.deleted)

                    // can be uncommented once delete mutation response is success
                    // currently the API request for delete mutation is sent with nil version, which
                    // fails with error message "Conflict resolver rejects mutation."
                    // XCTAssertTrue(post.syncMetadata.deleted)
                    apiQuerySuccess.fulfill()
                case .failure(let error):
                    XCTFail("Error: \(error)")
                }
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
        }
        wait(for: [apiQuerySuccess], timeout: networkTimeout)
    }

    /// - Given: API has been setup with `Post` model registered
    /// - When: A Post is saved with sync complete, updated and deleted immediately
    /// - Then: The Post should not be returned when queried for
    func testSaveThenUpdateAndImmediatelyDelete() throws {
        try startAmplifyAndWaitForSync()

        let newPost = Post(title: "MyPost",
                          content: "This is my post.",
                          createdAt: .now(),
                          rating: 3,
                          status: .published)

        var updatedPost = newPost
        updatedPost.rating = 5
        updatedPost.title = "MyUpdatedPost"
        updatedPost.content = "This is my updated post."

        let saveSyncReceived = expectation(description: "Received create mutation event on subscription for Post")
        let updateSyncReceived = expectation(description: "Received update mutation event on subscription for Post")
        // two update events are triggered
        // 1. update is performed successfully with version 1, and comes back with version 2
        // 2. delete is performed with version 1, response is conflict resolution, and when processing
        //    the error reponse, we apply the remote model to local store, triggering a second update
        updateSyncReceived.expectedFulfillmentCount = 2

        // this can be uncommented once the delete is successfully sent with version 2
        // let deleteSyncReceived = expectation(description: "Received delete mutation event on subscription for Post")

        let hubListener = Amplify.Hub.listen(
            to: .dataStore,
            eventName: HubPayload.EventName.DataStore.syncReceived) { payload in
            guard let mutationEvent = payload.data as? MutationEvent else {
                XCTFail("Can't cast payload as mutation event")
                return
            }

            guard let post = try? mutationEvent.decodeModel() as? Post, post.id == newPost.id else {
                return
            }

            if mutationEvent.mutationType == GraphQLMutationType.create.rawValue {
                XCTAssertEqual(post, newPost)
                XCTAssertEqual(mutationEvent.version, 1)
                saveSyncReceived.fulfill()
                return
            }

            if mutationEvent.mutationType == GraphQLMutationType.update.rawValue {
                XCTAssertEqual(post, updatedPost)
                XCTAssertEqual(mutationEvent.version, 2)
                updateSyncReceived.fulfill()
                return
            }

            if mutationEvent.mutationType == GraphQLMutationType.delete.rawValue {
                XCTAssertEqual(post, updatedPost)
                // this needs to be commented out once the bug is fixed
                // deleteSyncReceived.fulfill()
                return
            }
        }

        guard try HubListenerTestUtilities.waitForListener(with: hubListener, timeout: 5.0) else {
            XCTFail("Listener not registered for hub")
            return
        }

        // save the post, update and delete immediately
        let saveCompleted = expectation(description: "Save is completed")
        Amplify.DataStore.save(newPost) { result in
            switch result {
            case .success:
                saveCompleted.fulfill()
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
        }
        wait(for: [saveCompleted, saveSyncReceived], timeout: networkTimeout)

        let updateAndImmediatelyDelete =
            expectation(description: "Post is updated and deleted immediately")
        Amplify.DataStore.save(updatedPost) { result in
            switch result {
            case .success:
                Amplify.DataStore.delete(updatedPost) { result in
                    switch result {
                    case .success:
                        updateAndImmediatelyDelete.fulfill()
                    case .failure(let error):
                        XCTFail("Error: \(error)")
                    }
                }
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
        }

        wait(for: [updateAndImmediatelyDelete], timeout: networkTimeout)

        // query the deleted post immediately
        let queryResult = queryPost(byId: newPost.id)
        XCTAssertNil(queryResult)

        wait(for: [updateSyncReceived], timeout: networkTimeout)
        // can be uncommented once delete mutation response is success
        // wait(for: [deleteSyncExpectation], timeout: networkTimeout)

        // query the deleted post
        let queryResultAfterSync = queryPost(byId: updatedPost.id)

        // this should be removed once the bug is fixed
        XCTAssertNotNil(queryResultAfterSync)
        XCTAssertEqual(queryResultAfterSync, updatedPost)

        // this is the actual behavior which is currently failing
        // XCTAssertNil(post)

        let queryRequest =
            GraphQLRequest<MutationSyncResult?>.query(modelName: updatedPost.modelName, byId: updatedPost.id)
        let apiQuerySuccess = expectation(description: "API query is successful")
        Amplify.API.query(request: queryRequest) { result in
            switch result {
            case .success(let mutationSyncResult):
                switch mutationSyncResult {
                case .success(let data):
                    guard let post = data else {
                        XCTFail("Failed to get data")
                        return
                    }

                    XCTAssertEqual(post.model["title"] as? String, updatedPost.title)
                    XCTAssertEqual(post.model["content"] as? String, updatedPost.content)
                    XCTAssertEqual(post.model["rating"] as? Double, updatedPost.rating)
                    // the post should actually be deleted, but this is currently failing
                    XCTAssertFalse(post.syncMetadata.deleted)

                    // can be uncommented once delete mutation response is success
                    // currently the API request for delete mutation is sent with version 1, which
                    // fails with error message "Conflict resolver rejects mutation."
                    // XCTAssertTrue(post.syncMetadata.deleted)
                    apiQuerySuccess.fulfill()
                case .failure(let error):
                    XCTFail("Error: \(error)")
                }
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
        }
        wait(for: [apiQuerySuccess], timeout: networkTimeout)
    }

    private func queryPost(byId id: String) -> Post? {
        let queryExpectation = expectation(description: "Query is successful")
        var queryResult: Post?
        Amplify.DataStore.query(Post.self, byId: id) { result in
            switch result {
            case .success(let post):
                queryResult = post
                queryExpectation.fulfill()
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
        }
        wait(for: [queryExpectation], timeout: networkTimeout)
        return queryResult
    }
}

extension Post: Equatable {

    public static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.content == rhs.content
            && lhs.rating == rhs.rating
    }
}
