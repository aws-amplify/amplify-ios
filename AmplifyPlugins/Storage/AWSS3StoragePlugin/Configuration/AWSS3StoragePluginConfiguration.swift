//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Plugin specific configuration
public struct AWSS3StoragePluginConfiguration {
    public let customPrefixResolver: AWSS3PluginCustomPrefixResolver?

    public init(customPrefixResolver: AWSS3PluginCustomPrefixResolver? = nil) {
        self.customPrefixResolver = customPrefixResolver
    }

    public static func customPrefixResolver(
        _ resolver: AWSS3PluginCustomPrefixResolver) -> AWSS3StoragePluginConfiguration {
        .init(customPrefixResolver: resolver)
    }

    public static var passThroughPrefixResolver: AWSS3StoragePluginConfiguration {
        .init(customPrefixResolver: PassThroughPrefixResolver())
    }
}

extension AWSS3StoragePluginConfiguration {

    /// Returns the plugin option's resolver over the configuration's resolver.
    func getPrefixResolver(options: AWSS3PluginOptions?) -> AWSS3PluginCustomPrefixResolver? {
        if let options = options, let prefixResolver = options.customPrefixResolver {
            return prefixResolver
        } else if let prefixResolver = customPrefixResolver {
            return prefixResolver
        }
        return nil
    }
}
