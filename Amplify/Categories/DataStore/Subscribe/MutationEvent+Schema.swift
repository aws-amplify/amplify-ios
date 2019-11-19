//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

extension MutationEvent {
    // MARK: - CodingKeys

    public enum CodingKeys: String, ModelKey {
        case id
        case modelName
        case json
        case mutationType
        case createdAt
    }

    public static let keys = CodingKeys.self

    // MARK: - ModelSchema

    public static let schema = defineSchema { definition in
        let mutation = MutationEvent.keys

        definition.attributes(.isSystem)

        definition.fields(
            .id(),
            .field(mutation.modelName, is: .required, ofType: .string),
            .field(mutation.json, is: .required, ofType: .string),
            .field(mutation.mutationType,
                   is: .required,
                   ofType: .enum(type: MutationType.self)),
            .field(mutation.createdAt, is: .required, ofType: .dateTime)
        )
    }
}
