//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation

extension Comment {

    // MARK: - CodingKeys
    public enum CodingKeys: String, ModelKey {
        case id
        case content
        case createdAt
        case post
    }

    public static let keys = CodingKeys.self

    // MARK: - ModelSchema

    public static let schema = defineSchema { model in
        let comment = Comment.keys

        model.pluralName = "Comments"
        model.attributes(.isSyncable)

        model.fields(
            .id(),
            .field(comment.content, is: .required, ofType: .string),
            .field(comment.createdAt, is: .required, ofType: .dateTime),
            .belongsTo(comment.post,
                       is: .required,
                       ofType: Post.self,
                       targetName: "commentPostId")
        )
    }

}
