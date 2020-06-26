//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify
import AWSPluginsCore
import AWSMobileClient
import AWSCore

extension AWSCognitoAuthPlugin {

    /// Configures AWSCognitoAuthPlugin with the specified configuration.
    ///
    /// - Parameter configuration: The configuration specified for this plugin
    /// - Throws:
    ///   - PluginError.pluginConfigurationError: If one of the configuration values is invalid or empty
    public func configure(using configuration: Any?) throws {
        guard let jsonValueConfiguration = configuration as? JSONValue else {
            throw PluginError.pluginConfigurationError(
                AuthPluginErrorConstants.decodeConfigurationError.errorDescription,
                AuthPluginErrorConstants.decodeConfigurationError.recoverySuggestion
            )
        }
        do {
            // Convert the JSONValue to [String: Any] dictionary to be used by AWSMobileClient
            let configurationData =  try JSONEncoder().encode(jsonValueConfiguration)
            let authConfig = (try? JSONSerialization.jsonObject(with: configurationData, options: [])
                as? [String: Any]) ?? [:]
            AWSInfo.configureDefaultAWSInfo(authConfig)
            let awsMobileClient = try awsMobileClientAdapter(from: jsonValueConfiguration)
            try awsMobileClient.initialize()
            let authenticationProvider = AuthenticationProviderAdapter(awsMobileClient: awsMobileClient)
            let authorizationProvider = AuthorizationProviderAdapter(awsMobileClient: awsMobileClient)
            let userService = AuthUserServiceAdapter(awsMobileClient: awsMobileClient)
            let deviceService = AuthDeviceServiceAdapter(awsMobileClient: awsMobileClient)
            let hubEventHandler = AuthHubEventHandler()
            configure(authenticationProvider: authenticationProvider,
                      authorizationProvider: authorizationProvider,
                      userService: userService,
                      deviceService: deviceService,
                      hubEventHandler: hubEventHandler)
        } catch let authError as AuthError {
            throw authError

        } catch {
            let amplifyError = AuthError.configuration(
                "Error configuring \(String(describing: self))",
                """
                There was an error configuring the plugin. See the underlying error for more details.
                """,
                error)
            throw amplifyError
        }
    }

    func awsMobileClientAdapter(from authConfiguration: JSONValue) throws -> AWSMobileClientBehavior {
        let identityPoolConfig = identityPoolServiceConfiguration(from: authConfiguration)
        let userPoolConfig = userPoolServiceConfiguration(from: authConfiguration)

        // Auth plugin require atleast one of the Cognito service to work. Throw an error if both the service
        // configuration are nil.
        guard identityPoolConfig != nil || userPoolConfig != nil else {
            throw AuthError.configuration(
                "Error configuring \(String(describing: self))",
                """
                Could not read Cognito Service configuration from the auth configuration. Make sure that auth category
                is properly configured and auth information are present in the configuration. You can use Amplify CLI to
                configure the auth category.
                """)

        }
        return AWSMobileClientAdapter(userPoolConfiguration: userPoolConfig,
                                      identityPoolConfiguration: identityPoolConfig)
    }

    func identityPoolServiceConfiguration(from authConfiguration: JSONValue) -> AmplifyAWSServiceConfiguration? {
        let regionKeyPath = "CredentialsProvider.CognitoIdentity.Default.Region"
        guard case .string(let regionString) = authConfiguration.value(at: regionKeyPath) else {
            let amplifyMessage =
            """
                Could not read Cognito identity pool information from the configuration.
                """
            Amplify.Logging.warn(amplifyMessage)
            return nil
        }
        let region = (regionString as NSString).aws_regionTypeValue()
        let anonymousCredentialProvider = AWSAnonymousCredentialsProvider()
        return AmplifyAWSServiceConfiguration(region: region, credentialsProvider: anonymousCredentialProvider)
    }

    func userPoolServiceConfiguration(from authConfiguration: JSONValue) -> AmplifyAWSServiceConfiguration? {
        let regionKeyPath = "CognitoUserPool.Default.Region"
        guard case .string(let regionString) = authConfiguration.value(at: regionKeyPath) else {
            let amplifyMessage =
            """
                Could not read Cognito user pool information from the configuration.
                """
            Amplify.Logging.warn(amplifyMessage)
            return nil
        }
        let region = (regionString as NSString).aws_regionTypeValue()
        return AmplifyAWSServiceConfiguration(region: region)
    }

    // MARK: Internal

    /// Internal configure method to set the properties of the plugin
    ///
    /// Called from the configure method which implements the Plugin protocol. Useful for testing by passing in mocks.
    ///
    /// - Parameters:
    ///   - authenticationProvider: Provider that gives authentication abilities
    ///   - authorizationProvider: Provider that gives authorization abilities
    ///   - queue: The queue which operations are stored and dispatched for asychronous processing.
    func configure(authenticationProvider: AuthenticationProviderBehavior,
                   authorizationProvider: AuthorizationProviderBehavior,
                   userService: AuthUserServiceBehavior,
                   deviceService: AuthDeviceServiceBehavior,
                   hubEventHandler: AuthHubEventBehavior,
                   queue: OperationQueue = OperationQueue()) {
        self.authenticationProvider = authenticationProvider
        self.authorizationProvider = authorizationProvider
        self.userService = userService
        self.deviceService = deviceService
        self.hubEventHandler = hubEventHandler
        self.queue = queue
    }
}
