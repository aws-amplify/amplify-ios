//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSMobileClient

/// Auth plugin that uses AWS Cognito UserPool and IdentityPool.
///
/// The implicitly unwrapped optionals in this class are assigned in the `configure` method in `AWSAuthPlugin+Configure`
/// extension. Make sure to call `Amplify.configure` after adding the plugin to `Amplify`.
final public class AWSAuthPlugin: AuthCategoryPlugin {

    /// A queue that regulates the execution of operations.
    var queue: OperationQueue!

    /// Operations related to the authentication provider.
    var authenticationProvider: AuthenticationProviderBehavior!

    /// Operations related to the authorization provider
    var authorizationProvider: AuthorizationProviderBehavior!

    /// The unique key of the plugin within the auth category.
    public var key: PluginKey {
        return "awsCognitoAuthPlugin"
    }

    /// Instantiates an instance of the AWSAuthPlugin.
    public init() {
    }
}
