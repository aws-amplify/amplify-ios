//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SQLite
import XCTest

@testable import Amplify
@testable import AmplifyTestCommon
@testable import AWSDataStoreCategoryPlugin

class SQLiteStorageEngineAdapterTests: XCTestCase {

    var connection: Connection!
    var storageAdapter: SQLiteStorageEngineAdapter!

    override func setUp() {
        super.setUp()

        Amplify.reset()
        Amplify.Logging.logLevel = .warn

        ModelRegistry.register(modelType: Post.self)
        ModelRegistry.register(modelType: Comment.self)

        let storageEngine: StorageEngine
        do {
            connection = try Connection(.inMemory)
            storageAdapter = SQLiteStorageEngineAdapter(connection: connection)
            storageEngine = StorageEngine(adapter: storageAdapter, syncEngineFactory: nil)
        } catch {
            XCTFail(String(describing: error))
            return
        }

        let dataStorePublisher = DataStorePublisher()
        let dataStorePlugin = AWSDataStoreCategoryPlugin(storageEngine: storageEngine,
                                                         dataStorePublisher: dataStorePublisher)

        let dataStoreConfig = DataStoreCategoryConfiguration(plugins: [
            "AWSDataStoreCategoryPlugin": true
        ])
        let amplifyConfig = AmplifyConfiguration(dataStore: dataStoreConfig)
        do {
            try Amplify.add(plugin: dataStorePlugin)
            try Amplify.configure(amplifyConfig)
        } catch {
            XCTFail(String(describing: error))
            return
        }
    }

    // MARK: - Utilities

    /// - Given: a list of `Model` types
    /// - When:
    ///   - the list is not in the correct order: `[Comment, Post]`
    /// - Then:
    ///   - check if `sortByDependencyOrder()` sorts the list to `[Post, Comment]`
    func testModelDependencySortOrder() {
        let models: [Model.Type] = [Comment.self, Post.self]
        let sorted = models.sortByDependencyOrder()

        XCTAssert(models.count == sorted.count)
        XCTAssert(models[0].schema.name == sorted[1].schema.name)
        XCTAssert(models[1].schema.name == sorted[0].schema.name)
    }

    // MARK: - Operations

    /// - Given: a list a `Post` instance
    /// - When:
    ///   - the `save(post)` is called
    /// - Then:
    ///   - call `query(Post)` to check if the model was correctly inserted
    func testInsertPost() {
        let expectation = self.expectation(
            description: "it should save and select a Post from the database")

        // insert a post
        let post = Post(title: "title", content: "content")
        storageAdapter.save(post) { saveResult in
            switch saveResult {
            case .result:
                storageAdapter.query(Post.self) { queryResult in
                    switch queryResult {
                    case .result(let posts):
                        XCTAssert(posts.count == 1)
                        if let post = posts.first {
                            XCTAssert(post.id == post.id)
                            XCTAssert(post.title == post.title)
                            XCTAssert(post.content == post.content)
                        }
                        expectation.fulfill()
                    case .error(let error):
                        XCTFail(String(describing: error))
                        expectation.fulfill()
                    }
                }
            case .error(let error):
                XCTFail(String(describing: error))
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    /// - Given: a list a `Post` instance
    /// - When:
    ///   - the `save(post)` is called
    /// - Then:
    ///   - call `query(Post, where: title == post.title)` to check
    ///   if the model was correctly inserted using a predicate
    func testInsertPostAndSelectByTitle() {
        let expectation = self.expectation(
            description: "it should save and select a Post from the database")

        // insert a post
        let post = Post(title: "title", content: "content")
        storageAdapter.save(post) { saveResult in
            switch saveResult {
            case .result:
                let predicate = Post.keys.title == post.title
                storageAdapter.query(Post.self, predicate: predicate) { queryResult in
                    switch queryResult {
                    case .result(let posts):
                        XCTAssertEqual(posts.count, 1)
                        if let post = posts.first {
                            XCTAssert(post.id == post.id)
                            XCTAssert(post.title == post.title)
                            XCTAssert(post.content == post.content)
                        }
                        expectation.fulfill()
                    case .error(let error):
                        XCTFail(String(describing: error))
                        expectation.fulfill()
                    }
                }
            case .error(let error):
                XCTFail(String(describing: error))
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    /// - Given: a list a `Post` instance
    /// - When:
    ///   - the `save(post)` is called
    /// - Then:
    ///   - call `save(post)` again with an updated title
    ///   - check if the `query(Post)` returns only 1 post
    ///   - the post has the updated title
    func testInsertPostAndThenUpdateIt() {
        let expectation = self.expectation(
            description: "it should insert and update a Post")

        func checkSavedPost(id: String) {
            storageAdapter.query(Post.self) {
                switch $0 {
                case .result(let posts):
                    XCTAssertEqual(posts.count, 1)
                    if let post = posts.first {
                        XCTAssertEqual(post.id, id)
                        XCTAssertEqual(post.title, "title updated")
                    }
                    expectation.fulfill()
                case .error(let error):
                    XCTFail(String(describing: error))
                    expectation.fulfill()
                }
            }
        }

        var post = Post(title: "title", content: "content")
        storageAdapter.save(post) { insertResult in
            switch insertResult {
            case .result:
                post.title = "title updated"
                storageAdapter.save(post) { updateResult in
                    switch updateResult {
                    case .result:
                        checkSavedPost(id: post.id)
                    case .error(let error):
                        XCTFail(error.errorDescription)
                    }
                }
            case .error(let error):
                XCTFail(String(describing: error))
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    /// - Given: a list a `Post` instance
    /// - When:
    ///   - the `save(post)` is called
    /// - Then:
    ///   - call `delete(Post, id)` and check if `query(Post)` is empty
    ///   - check if `storageAdapter.exists(Post, id)` returns `false`
    func testInsertPostAndThenDeleteIt() {
        let expectation = self.expectation(description: "it should insert and update a Post")

        func checkDeletedPost(id: String) {
            storageAdapter.query(Post.self) {
                switch $0 {
                case .result(let posts):
                    XCTAssertEqual(posts.count, 0)
                    do {
                        let exists = try storageAdapter.exists(Post.self, withId: id)
                        XCTAssertFalse(exists)
                    } catch {
                        XCTFail(String(describing: error))
                    }
                    expectation.fulfill()
                case .error(let error):
                    XCTFail(String(describing: error))
                    expectation.fulfill()
                }
            }
        }

        let post = Post(title: "title", content: "content")
        storageAdapter.save(post) { insertResult in
            switch insertResult {
            case .result:
                storageAdapter.delete(Post.self, withId: post.id) {
                    switch $0 {
                    case .result:
                        checkDeletedPost(id: post.id)
                    case .error(let error):
                        XCTFail(error.errorDescription)
                    }
                }
            case .error(let error):
                XCTFail(String(describing: error))
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    func testInsertPostAndComments() {
        let expectation = self.expectation(
            description: "it should save and select a Post from the database")

        let newPost = Post(title: "title", content: "post")
        prepareData(newPost)
        prepareData(
            Comment(content: "comment 1", post: newPost),
            Comment(content: "comment 2", post: newPost),
            Comment(content: "comment 3", post: newPost)
        )

        // query the post by id

        storageAdapter.query(Post.self, predicate: Post.keys.id == newPost.id) {
            switch $0 {
            case .result(let posts):
                XCTAssertEqual(posts.count, 1)
                if let post = posts.first {
                    let comments = post.comments
                    XCTAssertEqual(comments.count, 3)
                    for comment in comments {
                        XCTAssertEqual(comment.post.id, post.id)
                        XCTAssertEqual(comment.post.title, post.title)
                    }
                    expectation.fulfill()
                }
            case .error(let error):
                XCTFail(String(describing: error))
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    // MARK: - Utilities

    private func prepareData<M: Model>(_ models: M...) {
        let semaphore = DispatchSemaphore(value: 0)

        func save(model: M, index: Int) {
            storageAdapter.save(model) {
                switch $0 {
                case .result:
                    let nextIndex = index + 1
                    if nextIndex < models.endIndex {
                        save(model: models[nextIndex], index: nextIndex)
                    } else {
                        semaphore.signal()
                    }
                case .error(let error):
                    XCTFail(error.errorDescription)
                    semaphore.signal()
                }
            }
        }

        if let model = models.first {
            save(model: model, index: 0)
            semaphore.wait()
        } else {
            semaphore.signal()
        }

    }

}
