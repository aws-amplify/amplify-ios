//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import Combine

import AmplifyCombineSupport

@testable import Amplify
@testable import AmplifyTestCommon

class DownloadFileTests: XCTestCase {

    var plugin: MockStorageCategoryPlugin!

    override func setUpWithError() throws {
        Amplify.reset()

        let categoryConfig = StorageCategoryConfiguration(
            plugins: ["MockStorageCategoryPlugin": true]
        )

        let amplifyConfig = AmplifyConfiguration(storage: categoryConfig)
        plugin = MockStorageCategoryPlugin()
        try Amplify.add(plugin: plugin)
        try Amplify.configure(amplifyConfig)
    }

    func testOperationSucceeds() {
        let receivedValue = expectation(description: "Received value")
        let receivedError = expectation(description: "Received error")
        receivedError.isInverted = true
        plugin.responders.downloadFile = { _, _, _, _, resultListener in
            resultListener?(.successfulVoid)
        }
        let sink = Amplify.Storage.downloadFile(key: "key", local: URL(fileURLWithPath: "file:///path/to/file"))
            .resultPublisher
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    receivedError.fulfill()
                }
            }, receiveValue: { _ in
                receivedValue.fulfill()
            })

        waitForExpectations(timeout: 0.05)
        sink.cancel()
    }

    func testOperationFails() {
        let receivedValue = expectation(description: "Received value")
        receivedValue.isInverted = true
        let receivedError = expectation(description: "Received error")
        plugin.responders.downloadFile = { _, _, _, _, resultListener in
            resultListener?(.failure(.unknown("Test")))
        }
        let sink = Amplify.Storage.downloadFile(key: "key", local: URL(fileURLWithPath: "file:///path/to/file"))
            .resultPublisher
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    receivedError.fulfill()
                }
            }, receiveValue: { _ in
                receivedValue.fulfill()
            })

        waitForExpectations(timeout: 0.05)
        sink.cancel()
    }

    /// This test mimics a longer-running operation by introducing a delay before invoking the
    /// progress & result listeners. This gives the subscription a chance to be registered and start
    /// listening before the handlers are invoked. In real life, there is a possibility that some progress
    /// events would be delivered before the subscription was returned.
    func testProgress() {
        let receivedProgress = expectation(description: "Received progress report")
        let receivedCompletion = expectation(description: "Received completion")

        plugin.responders.downloadFile = { _, _, _, progressListener, resultListener in
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(10)) {
                progressListener?(Progress())
                resultListener?(.successfulVoid)
            }
        }

        let sink = Amplify.Storage.downloadFile(
            key: "key",
            local: URL(fileURLWithPath: "file:///path/to/file")
        )
            .progressPublisher
            .sink(
                receiveCompletion: { _ in receivedCompletion.fulfill() },
                receiveValue: { _ in receivedProgress.fulfill() }
        )
        waitForExpectations(timeout: 1.0)
        sink.cancel()
    }

}