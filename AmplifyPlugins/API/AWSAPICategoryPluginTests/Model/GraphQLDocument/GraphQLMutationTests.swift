//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest

@testable import Amplify
@testable import AmplifyTestCommon
@testable import AWSAPICategoryPlugin

class GraphQLMutationTests: XCTestCase {

    override func setUp() {
        ModelRegistry.register(modelType: Comment.self)
        ModelRegistry.register(modelType: Post.self)
    }

    /// - Given: a `Model` instance
    /// - When:
    ///   - the model is of type `Post`
    ///   - the model has no required associations
    ///   - the mutation is of type `.create`
    /// - Then:
    ///   - check if the generated GraphQL document is a valid mutation:
    ///     - it is named `createPost`
    ///     - it contains an `input` of type `CreatePostInput`
    ///     - it has a list of fields with no nested models
    func testCreateGraphQLMutationFromSimpleModel() {
        let post = Post(title: "title", content: "content")
        let document = GraphQLMutation(of: post, type: .create)
        let expected = """
        mutation CreatePost($input: CreatePostInput!) {
          createPost(input: $input) {
            id
            content
            createdAt
            draft
            rating
            title
            updatedAt
            __typename
            _version
            _deleted
            _lastChangedAt
          }
        }
        """
        XCTAssertEqual(document.name, "createPost")
        XCTAssertEqual(document.decodePath, "createPost")
        XCTAssertEqual(document.stringValue, expected)
        XCTAssertEqual(document.name, "createPost")
        XCTAssertNotNil(document.variables["input"])
        guard let input = document.variables["input"] as? [String: Any] else {
            XCTFail("The document variables property doesn't contain a valid input")
            return
        }
        XCTAssert(input["title"] as? String == post.title)
        XCTAssert(input["content"] as? String == post.content)
    }

    /// - Given: a `Model` instance
    /// - When:
    ///   - the model is of type `Comment`
    ///   - the model has required associations
    ///   - the mutation is of type `.create`
    /// - Then:
    ///   - check if the generated GraphQL document is a valid mutation:
    ///     - it is named `createComment`
    ///     - it contains an `input` of type `CreateCommentInput`
    ///     - it has a list of fields with a `postId`
    func testCreateGraphQLMutationFromModelWithAssociation() {
        let post = Post(title: "title", content: "content")
        let comment = Comment(content: "comment", post: post)
        let document = GraphQLMutation(of: comment, type: .create)
        let expected = """
        mutation CreateComment($input: CreateCommentInput!) {
          createComment(input: $input) {
            id
            content
            createdAt
            post {
              id
              content
              createdAt
              draft
              rating
              title
              updatedAt
              __typename
              _version
              _deleted
              _lastChangedAt
            }
            __typename
            _version
            _deleted
            _lastChangedAt
          }
        }
        """
        XCTAssertEqual(document.name, "createComment")
        XCTAssertEqual(document.decodePath, "createComment")
        XCTAssertEqual(document.stringValue, expected)
        XCTAssertEqual(document.name, "createComment")
        guard let input = document.variables["input"] as? GraphQLInput else {
            XCTFail("Variables should contain a valid input")
            return
        }
        XCTAssertEqual(input["commentPostId"] as? String, post.id)
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
        let post = Post(title: "title", content: "content")
        let document = GraphQLMutation(of: post, type: .update)
        let expected = """
        mutation UpdatePost($input: UpdatePostInput!) {
          updatePost(input: $input) {
            id
            content
            createdAt
            draft
            rating
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
        XCTAssertEqual(document.decodePath, "updatePost")
        XCTAssertEqual(document.stringValue, expected)
        XCTAssertEqual(document.name, "updatePost")
        XCTAssertNotNil(document.variables["input"])
        guard let input = document.variables["input"] as? [String: Any] else {
            XCTFail("The document variables property doesn't contain a valid input")
            return
        }
        XCTAssert(input["title"] as? String == post.title)
        XCTAssert(input["content"] as? String == post.content)
    }

    /// - Given: a `Model` instance
    /// - When:
    ///   - the model is of type `Post`
    ///   - the model has no required associations
    ///   - the mutation is of type `.delete`
    /// - Then:
    ///   - check if the generated GraphQL document is a valid mutation:
    ///     - it is named `deletePost`
    ///     - it contains an `input` of type `ID!`
    ///     - it has a list of fields with no nested models
    func testDeleteGraphQLMutationFromSimpleModel() {
        let post = Post(title: "title", content: "content")
        let document = GraphQLMutation(of: post, type: .delete)
        let expected = """
        mutation DeletePost($input: DeletePostInput!) {
          deletePost(input: $input) {
            id
            content
            createdAt
            draft
            rating
            title
            updatedAt
            __typename
            _version
            _deleted
            _lastChangedAt
          }
        }
        """
        XCTAssertEqual(document.name, "deletePost")
        XCTAssertEqual(document.decodePath, "deletePost")
        XCTAssertEqual(document.stringValue, expected)
        XCTAssertEqual(document.name, "deletePost")
        XCTAssert(document.variables["input"] != nil)
        guard let input = document.variables["input"] as? [String: String] else {
            XCTFail("Could not get object at `input`")
            return
        }
        XCTAssertEqual(input["id"], post.id)
    }
}
