//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import Amplify
import AWSAPICategoryPlugin
import AWSMobileClient
@testable import AWSAPICategoryPluginTestCommon

class RESTWithIAMIntegrationTests: XCTestCase {

    /*
     Folow these instructions to get this set up: https://aws-amplify.github.io/docs/ios/api#rest-api
     */

    static let networkTimeout = TimeInterval(180)

    static let restAPI = "restAPI"

    static let apiConfig = APICategoryConfiguration(plugins: [
        "AWSAPICategoryPlugin": [
            RESTWithIAMIntegrationTests.restAPI: [
                "Endpoint": "https://crmjcxtcwa.execute-api.us-west-2.amazonaws.com/devo",
                "Region": "us-west-2",
                "AuthorizationType": "AWS_IAM",
                "EndpointType": "REST"
            ]
        ]
    ])

    override func setUp() {

        let config = [
            "CredentialsProvider": [
                "CognitoIdentity": [
                    "Default": [
                        "PoolId": "us-west-2:6254b084-a9cd-407c-ade2-fd8b881f87ce",
                        "Region": "us-west-2"
                    ]
                ]
            ],
            "CognitoUserPool": [
                "Default": [
                    "PoolId": "us-west-2_VnaF2mqfl",
                    "AppClientId": "2a90rcn2s10im86ef0756fvf0h",
                    "AppClientSecret": "mk6lbnvbr6d84g2nffnghhnr4td04v971teniqtiu6ap29kjsgb",
                    "Region": "us-west-2"
                ]
            ]
        ]

        AWSInfo.configureDefaultAWSInfo(config)

        RESTWithIAMIntegrationTests.initializeMobileClient()

        Amplify.reset()
        let plugin = AWSAPICategoryPlugin()

        let amplifyConfig = AmplifyConfiguration(api: RESTWithIAMIntegrationTests.apiConfig)
        do {
            try Amplify.add(plugin: plugin)
            try Amplify.configure(amplifyConfig)
        } catch {
            XCTFail("Error during setup: \(error)")
        }
    }

    override func tearDown() {
        Amplify.reset()
    }

    func testGetAPISuccess() {
        let completeInvoked = expectation(description: "request completed")
        let request = RESTRequest(apiName: RESTWithIAMIntegrationTests.restAPI,
                                  path: "/items")
        _ = Amplify.API.get(request: request) { event in
            switch event {
            case .completed(let data):
                let result = String(decoding: data, as: UTF8.self)
                print(result)
                completeInvoked.fulfill()
            case .failed(let error):
                XCTFail("Unexpected .failed event: \(error)")
            default:
                XCTFail("Unexpected event: \(event)")
            }
        }

        wait(for: [completeInvoked], timeout: RESTWithIAMIntegrationTests.networkTimeout)
    }

    func testGetAPIFailedAccessDenied() {
        let failedInvoked = expectation(description: "request failed")
        let request = RESTRequest(apiName: RESTWithIAMIntegrationTests.restAPI,
                                  path: "/invalidPath")
        _ = Amplify.API.get(request: request) { event in
            switch event {
            case .completed(let data):
                XCTFail("Unexpected .complted event: \(data)")
            case .failed(let error):
                guard case let .httpStatusError(_, _, httpURLResponse, error) = error else {
                    XCTFail("Error should be httpStatusError")
                    return
                }

                XCTAssertEqual(httpURLResponse.statusCode, 403)
                failedInvoked.fulfill()
            default:
                XCTFail("Unexpected event: \(event)")
            }
        }

        wait(for: [failedInvoked], timeout: RESTWithIAMIntegrationTests.networkTimeout)
    }

    func testPutAPISuccess() {
        let completeInvoked = expectation(description: "request completed")
        let request = RESTRequest(apiName: RESTWithIAMIntegrationTests.restAPI,
                                  path: "/items")
        _ = Amplify.API.put(request: request) { event in
            switch event {
            case .completed(let data):
                let result = String(decoding: data, as: UTF8.self)
                print(result)
                completeInvoked.fulfill()
            case .failed(let error):
                XCTFail("Unexpected .failed event: \(error)")
            default:
                XCTFail("Unexpected event: \(event)")
            }
        }

        wait(for: [completeInvoked], timeout: RESTWithIAMIntegrationTests.networkTimeout)
    }

    func testPostAPISuccess() {
        let completeInvoked = expectation(description: "request completed")
        let request = RESTRequest(apiName: RESTWithIAMIntegrationTests.restAPI,
                                  path: "/items")
        _ = Amplify.API.post(request: request) { event in
            switch event {
            case .completed(let data):
                let result = String(decoding: data, as: UTF8.self)
                print(result)
                completeInvoked.fulfill()
            case .failed(let error):
                XCTFail("Unexpected .failed event: \(error)")
            default:
                XCTFail("Unexpected event: \(event)")
            }
        }

        wait(for: [completeInvoked], timeout: RESTWithIAMIntegrationTests.networkTimeout)
    }

    func testDeleteAPISuccess() {
        let completeInvoked = expectation(description: "request completed")
        let request = RESTRequest(apiName: RESTWithIAMIntegrationTests.restAPI,
                                  path: "/items")
        _ = Amplify.API.delete(request: request) { event in
            switch event {
            case .completed(let data):
                let result = String(decoding: data, as: UTF8.self)
                print(result)
                completeInvoked.fulfill()
            case .failed(let error):
                XCTFail("Unexpected .failed event: \(error)")
            default:
                XCTFail("Unexpected event: \(event)")
            }
        }

        wait(for: [completeInvoked], timeout: RESTWithIAMIntegrationTests.networkTimeout)
    }

    func testHeadAPIAccessDenied() {
        let failedInvoked = expectation(description: "request completed")
        let request = RESTRequest(apiName: RESTWithIAMIntegrationTests.restAPI,
                                  path: "/items")
        _ = Amplify.API.head(request: request) { event in
            switch event {
            case .completed(let data):
                XCTFail("Unexpected .completed event: \(data)")
            case .failed(let error):
                guard case let .httpStatusError(_, _, httpURLResponse, _) = error else {
                    XCTFail("Error should be httpStatusError")
                    return
                }

                XCTAssertEqual(httpURLResponse.statusCode, 403)
                failedInvoked.fulfill()
            default:
                XCTFail("Unexpected event: \(event)")
            }
        }

        wait(for: [failedInvoked], timeout: RESTWithIAMIntegrationTests.networkTimeout)
    }

    func testPatchAPINotFound() {
        let failedInvoked = expectation(description: "request completed")
        let request = RESTRequest(apiName: RESTWithIAMIntegrationTests.restAPI,
                                  path: "/items")
        _ = Amplify.API.patch(request: request) { event in
            switch event {
            case .completed(let data):
                XCTFail("Unexpected .completed event: \(data)")
            case .failed(let error):
                guard case let .httpStatusError(_, _, httpURLResponse, _) = error else {
                    XCTFail("Error should be httpStatusError")
                    return
                }

                XCTAssertEqual(httpURLResponse.statusCode, 404)
                failedInvoked.fulfill()
            default:
                XCTFail("Unexpected event: \(event)")
            }
        }

        wait(for: [failedInvoked], timeout: RESTWithIAMIntegrationTests.networkTimeout)
    }

    // MARK: - Utilities

    static func initializeMobileClient() {
        let callbackInvoked = DispatchSemaphore(value: 1)

        AWSMobileClient.default().initialize { userState, error in
            if let error = error {
                XCTFail("Error initializing AWSMobileClient. Error: \(error.localizedDescription)")
                return
            }

            guard let userState = userState else {
                XCTFail("userState is unexpectedly empty initializing AWSMobileClient")
                return
            }

            if userState != UserState.signedOut {
                AWSMobileClient.default().signOut()
            }
            print("AWSMobileClient Initialized")
            callbackInvoked.signal()
        }

        _ = callbackInvoked.wait(timeout: .now() + networkTimeout)
    }

}
