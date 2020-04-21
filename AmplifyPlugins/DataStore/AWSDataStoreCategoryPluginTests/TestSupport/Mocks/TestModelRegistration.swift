//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AmplifyTestCommon
import Foundation

struct TestModelRegistration: AmplifyModelRegistration {

    func registerModels(registry: ModelRegistry.Type) {
        // Post and Comment
        registry.register(modelType: Post.self)
        registry.register(modelType: Comment.self)

        // Mock Models
        registry.register(modelType: MockSynced.self)
        registry.register(modelType: MockUnsynced.self)

        // Models for data conversion testing
        registry.register(modelType: ExampleWithEveryType.self)
    }

    let version: String = "1"

}
