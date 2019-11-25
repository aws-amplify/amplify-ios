//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import Amplify
@testable import AmplifyTestCommon
@testable import AWSAPICategoryPlugin

class APICategoryPluginConcurrencyTests: XCTestCase {

    override func setUp() {
        Amplify.reset()
        Amplify.Logging.logLevel = .verbose
        ModelRegistry.register(modelType: AmplifyTestCommon.Post.self)
        ModelRegistry.register(modelType: AmplifyTestCommon.Comment.self)

        let apiConfig = APICategoryConfiguration(plugins: [
            "AWSAPICategoryPlugin": [
                "Default": [
                    "Endpoint": "https://ldm7yqjfjngrjckbziumz5fxbe.appsync-api.us-west-2.amazonaws.com/graphql",
                    "Region": "us-west-2",
                    "AuthorizationType": "API_KEY",
                    "ApiKey": "da2-7jhi34lssbbmjclftlykznhw5m",
                    "EndpointType": "GraphQL"
                ]
            ]
        ])

        let amplifyConfig = AmplifyConfiguration(api: apiConfig)
        do {
            try Amplify.add(plugin: AWSAPICategoryPlugin())
            try Amplify.configure(amplifyConfig)
        } catch {
            XCTFail("Error during setup: \(error)")
        }
    }

    /// This test should ensure the plugin provides a stable platform for establishing multiple subscriptions
    /// concurrently on separate queues. It should also be run with Thread Sanitizer enabled to test for Data Race
    /// conditions.
    func testConcurrentSubscriptions() {
        XCTFail("Not yet implemented")
    }
}
