//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest

@testable import Amplify
@testable import AmplifyTestCommon
@testable import AWSPluginsCore

class GraphQLUpdateMutationTests: XCTestCase {

    override func setUp() {
        ModelRegistry.register(modelType: Comment.self)
        ModelRegistry.register(modelType: Post.self)
    }

    override func tearDown() {
        ModelRegistry.reset()
    }

    /// - Given: a `Model` instance
    /// - When:
    ///   - the model is of type `Post`
    ///   - the model has no required associations
    ///   - the mutation is of type `.update`
    /// - Then:
    ///   - check if the generated GraphQL document is a valid mutation:
    ///     - it is named `updatePost`
    ///     - it contains an `input` of type `UpdatePostInput`
    ///     - it has a list of fields with no nested models
    func testUpdateGraphQLMutationFromSimpleModel() {
        let post = Post(title: "title", content: "content", createdAt: .now())
        var documentBuilder = ModelBasedGraphQLDocumentBuilder(modelType: Post.self, operationType: .mutation)
        documentBuilder.add(decorator: DirectiveNameDecorator(type: .update))
        documentBuilder.add(decorator: ModelDecorator(model: post))
        let document = documentBuilder.build()
        let expectedQueryDocument = """
        mutation UpdatePost($input: UpdatePostInput!) {
          updatePost(input: $input) {
            id
            content
            createdAt
            draft
            rating
            status
            title
            updatedAt
            __typename
          }
        }
        """
        XCTAssertEqual(document.name, "updatePost")
        XCTAssertEqual(document.stringValue, expectedQueryDocument)
        XCTAssertEqual(document.name, "updatePost")
        guard let variables = document.variables else {
            XCTFail("The document doesn't contain variables")
            return
        }
        XCTAssertNotNil(variables["input"])
        guard let input = variables["input"] as? [String: Any] else {
            XCTFail("The document variables property doesn't contain a valid input")
            return
        }
        XCTAssert(input["title"] as? String == post.title)
        XCTAssert(input["content"] as? String == post.content)
        XCTAssertFalse(input.keys.contains("comments"))
    }

    /// - Given: a `Model` instance
    /// - When:
    ///   - the model is of type `Post`
    ///   - the model has no required associations
    ///   - the mutation is of type `.update`
    /// - Then:
    ///   - check if the generated GraphQL document is a valid mutation:
    ///     - it is named `updatePost`
    ///     - it contains an `input` of type `UpdatePostInput`
    ///     - it has a list of fields with no nested models
    func testUpdateGraphQLMutationFromSimpleModelWithVersion() {
        let post = Post(title: "title", content: "content", createdAt: .now())
        var documentBuilder = ModelBasedGraphQLDocumentBuilder(modelType: Post.self, operationType: .mutation)
        documentBuilder.add(decorator: DirectiveNameDecorator(type: .update))
        documentBuilder.add(decorator: ModelDecorator(model: post))
        documentBuilder.add(decorator: ConflictResolutionDecorator(version: 5))
        let document = documentBuilder.build()
        let expectedQueryDocument = """
        mutation UpdatePost($input: UpdatePostInput!) {
          updatePost(input: $input) {
            id
            content
            createdAt
            draft
            rating
            status
            title
            updatedAt
            __typename
            _version
            _deleted
            _lastChangedAt
          }
        }
        """
        XCTAssertEqual(document.name, "updatePost")
        XCTAssertEqual(document.stringValue, expectedQueryDocument)
        XCTAssertEqual(document.name, "updatePost")
        guard let variables = document.variables else {
            XCTFail("The document doesn't contain variables")
            return
        }
        XCTAssertNotNil(variables["input"])
        guard let input = variables["input"] as? [String: Any] else {
            XCTFail("The document variables property doesn't contain a valid input")
            return
        }
        XCTAssert(input["title"] as? String == post.title)
        XCTAssert(input["content"] as? String == post.content)
        XCTAssert(input["_version"] as? Int == 5)
        XCTAssertFalse(input.keys.contains("comments"))
    }
}
