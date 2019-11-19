//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import Amplify
import AWSPredictionsPlugin
import AWSCore

class InterpretBasicIntegrationTests: AWSPredictionsPluginTestBase {

    /// Test if we can make successful call to interpret
    ///
    /// - Given: Configured Amplify with prediction added
    /// - When:
    ///    - I invoke interpret with text
    /// - Then:
    ///    - Should return no empty result
    ///
    func testInterpretText() {
        AWSDDLog.sharedInstance.logLevel = .verbose
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        let interpretInvoked = expectation(description: "Interpret invoked")
        let operation = Amplify.Predictions.interpret(text: "Hello there how are you?") { event in
            switch event {
            case .completed(let result):
                interpretInvoked.fulfill()
                XCTAssertNotNil(result, "Result should contain value")
            case .failed(let error):
                XCTFail("Should not receive error \(error)")
            default:
                break
            }
        }
        XCTAssertNotNil(operation)
        waitForExpectations(timeout: networkTimeout)
    }

    /// Test if we can make successful call to interpret
    ///
    /// - Given: Configured Amplify with prediction added
    /// - When:
    ///    - I invoke interpret with text on offline mode
    /// - Then:
    ///    - Should return no empty result
    ///
    func testInterpretTextOffline() {
        let interpretInvoked = expectation(description: "Interpret invoked")
        let options = PredictionsInterpretRequest.Options(callType: .offline, pluginOptions: nil)
        let operation = Amplify.Predictions.interpret(text: "Hello there how are you?", options: options) { event in
            switch event {
            case .completed(let result):
                interpretInvoked.fulfill()
                XCTAssertNotNil(result, "Result should contain value")
            case .failed(let error):
                XCTFail("Should not receive error \(error)")
            default:
                break
            }
        }
        XCTAssertNotNil(operation)
        waitForExpectations(timeout: networkTimeout)
    }
}
