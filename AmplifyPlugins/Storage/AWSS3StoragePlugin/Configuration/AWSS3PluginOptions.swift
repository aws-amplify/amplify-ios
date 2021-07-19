//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSPluginsCore

/// Plugin specific options type
public struct AWSS3PluginOptions {

    let customPrefixResolver: AWSS3PluginCustomPrefixResolver?

    public init(customPrefixResolver: AWSS3PluginCustomPrefixResolver? = nil) {
        self.customPrefixResolver = customPrefixResolver
    }

    public static var passThroughKeyResolver: AWSS3PluginOptions {
        .init(customPrefixResolver: PassThroughPrefixResolver())
    }
}
