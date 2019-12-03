//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AmplifyTestCommon

struct TestModelRegistration: DataStoreModelRegistration {

    func registerModels(registry: ModelRegistry.Type) {
        registry.register(modelType: Post.self)
        registry.register(modelType: Comment.self)
    }

    let version: String = "1"

}
