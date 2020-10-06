//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct MutationEvent: Model {
    public let id: Identifier
    public let modelId: Identifier
    public var modelName: String
    public var json: String
    public var mutationType: String
    public var createdAt: Temporal.DateTime
    public var version: Int?
    public var inProcess: Bool
    public var graphQLFilterJSON: String?

    public init(id: Identifier = UUID().uuidString,
                modelId: String,
                modelName: String,
                json: String,
                mutationType: MutationType,
                createdAt: Temporal.DateTime = .now(),
                version: Int? = nil,
                inProcess: Bool = false,
                graphQLFilterJSON: String? = nil) {
        self.id = id
        self.modelId = modelId
        self.modelName = modelName
        self.json = json
        self.mutationType = mutationType.rawValue
        self.createdAt = createdAt
        self.version = version
        self.inProcess = inProcess
        self.graphQLFilterJSON = graphQLFilterJSON
    }

    public init<M: Model>(model: M,
                          modelSchema: ModelSchema,
                          mutationType: MutationType,
                          version: Int? = nil,
                          graphQLFilterJSON: String? = nil) throws {
        let json = try model.toJSON()
        self.init(modelId: model.id,
                  modelName: modelSchema.name,
                  json: json,
                  mutationType: mutationType,
                  version: version,
                  graphQLFilterJSON: graphQLFilterJSON)

    }

    @available(*, deprecated, message: """
    Init method without ModelSchema is deprecated, use the other init methods.
    """)
    public init<M: Model>(model: M,
                          mutationType: MutationType,
                          version: Int? = nil,
                          graphQLFilterJSON: String? = nil) throws {
        try self.init(model: model,
                      modelSchema: model.schema,
                      mutationType: mutationType,
                      version: version,
                      graphQLFilterJSON: graphQLFilterJSON)

    }

    public func decodeModel() throws -> Model {
        let model = try ModelRegistry.decode(modelName: modelName, from: json)
        return model
    }

    /// Decodes the model instance from the mutation event.
    public func decodeModel<M: Model>(as modelType: M.Type) throws -> M {
        let model = try ModelRegistry.decode(modelName: modelName, from: json)

        guard let typedModel = model as? M else {
            throw DataStoreError.decodingError(
                "Could not create '\(modelType.modelName)' from model",
                """
                Review the data in the JSON string below and ensure it doesn't contain invalid UTF8 data, and that \
                it is a valid \(modelType.modelName) instance:

                \(json)
                """)
        }

        return typedModel
    }
}
