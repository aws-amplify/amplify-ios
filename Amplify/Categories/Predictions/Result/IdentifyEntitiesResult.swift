//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct IdentifyEntitiesResult: IdentifyResult {
    public var entities: [Entity]

    public init(entities: [Entity]) {
        self.entities = entities
    }
}










