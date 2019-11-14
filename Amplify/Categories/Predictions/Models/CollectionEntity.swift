//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

///Struct that holds the result for an entity matched from an entity collection created on Rekogniton and detected from Predictions Identify methods.
public struct CollectionEntity {
    public let boundingBox: BoundingBox
    public let metadata: CollectionEntityMetadata

    public init(boundingBox: BoundingBox, metadata: CollectionEntityMetadata) {
        self.boundingBox = boundingBox
        self.metadata = metadata
    }
}

public struct CollectionEntityMetadata {
    public let externalImageId: String?
    public let similarity: Double

    public init(externalImageId: String?, similarity: Double) {
        self.externalImageId = externalImageId
        self.similarity = similarity
    }
}
