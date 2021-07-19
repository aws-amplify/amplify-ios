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

    let customKeyResolver: AWSS3PluginCustomKeyResolver

    public init(customKeyResolver: AWSS3PluginCustomKeyResolver) {
        self.customKeyResolver = customKeyResolver
    }

    public static var passThroughKeyResolver: AWSS3PluginOptions {
        .init(customKeyResolver: PassThroughKeyResolver())
    }
}

/// Resolves the final prefix prepended to the S3 key for a given request.
public protocol AWSS3PluginCustomKeyResolver {
    func resolvePrefix(for accessLevel: StorageAccessLevel, targetIdentityId: String?) -> Result<String, StorageError>
}

/// Convenience resolver. Resolves the provided key as-is, with no manipulation
public struct PassThroughKeyResolver: AWSS3PluginCustomKeyResolver {
    public func resolvePrefix(for accessLevel: StorageAccessLevel,
                              targetIdentityId: String?) -> Result<String, StorageError> {
        return .success("")
    }
}

/// AWSS3StoragePlugin default logic
struct StorageAccessLevelAwareKeyResolver: AWSS3PluginCustomKeyResolver {
    let authService: AWSAuthServiceBehavior

    public init(authService: AWSAuthServiceBehavior) {
        self.authService = authService
    }

    public func resolvePrefix(for accessLevel: StorageAccessLevel,
                              targetIdentityId: String?) -> Result<String, StorageError> {
        let identityIdResult = authService.getIdentityId()
        switch identityIdResult {
        case .success(let identityId):
            let prefix = StorageRequestUtils.getAccessLevelPrefix(accessLevel: accessLevel,
                                                                  identityId: identityId,
                                                                  targetIdentityId: targetIdentityId)
            return .success(prefix)
        case .failure(let error):
            return .failure(StorageError.authError(error.errorDescription, error.recoverySuggestion))
        }
    }
}
