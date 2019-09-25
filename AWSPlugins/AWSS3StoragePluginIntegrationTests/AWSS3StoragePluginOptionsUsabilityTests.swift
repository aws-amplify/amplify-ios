//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import AWSMobileClient
import Amplify
import AWSS3StoragePlugin
import AWSS3
class AWSS3StoragePluginOptionsUsabilityTests: AWSS3StoragePluginTestBase {

    /// Given: An object in storage
    /// When: Call the GetURL API with 10 second expiry time
    /// Then: Retrieve data successfully when the URL has not expired and fail to after the expiry time
    func testGetRemoteURLWithExpires() {
        let key = "testGetRemoteURLWithExpires"
        putData(key: key, dataString: key)

        var remoteURLOptional: URL?
        let completeInvoked = expectation(description: "Completed is invoked")

        let expires = 10
        let options = StorageGetURLOptions(accessLevel: nil,
                                           targetIdentityId: nil,
                                           expires: expires)
        let operation = Amplify.Storage.getURL(key: key, options: options) { (event) in
            switch event {
            case .completed(let result):
                remoteURLOptional = result
                completeInvoked.fulfill()
            case .failed(let error):
                XCTFail("Failed with \(error)")
            default:
                break
            }
        }
        XCTAssertNotNil(operation)
        waitForExpectations(timeout: networkTimeout)
        guard let remoteURL = remoteURLOptional else {
            XCTFail("Failed to get remoteURL")
            return
        }

        let dataTaskCompleteInvoked = expectation(description: "Completion of retrieving data at URL is invoked")
        let task = URLSession.shared.dataTask(with: remoteURL) { (data, response, error) in
            guard error == nil else {
                XCTFail("Failed to received data from url with error \(error)")
                return
            }

            guard let response = response as? HTTPURLResponse, (200 ... 299).contains(response.statusCode) else {
                XCTFail("Failed to received data with bad status code")
                return
            }

            guard let data = data else {
                XCTFail("Failed to received data, empty data object")
                return
            }

            let dataString = String(data: data, encoding: .utf8)!
            XCTAssertEqual(dataString, key)
            dataTaskCompleteInvoked.fulfill()
        }
        task.resume()
        waitForExpectations(timeout: networkTimeout)

        sleep(15)

        let urlExpired = expectation(description: "Retrieving expired url should have bad response")
        let task2 = URLSession.shared.dataTask(with: remoteURL) { (_, response, error) in
            guard error == nil else {
                XCTFail("Failed to received data from url with error \(error)")
                return
            }

            guard let response = response as? HTTPURLResponse else {
                XCTFail("Could not get response")
                return
            }

            XCTAssertEqual(response.statusCode, 403)
            urlExpired.fulfill()
        }
        task2.resume()
        waitForExpectations(timeout: networkTimeout)
    }

    /// Given: An object uploaded with metadata with key `metadataKey` and value `metadataValue`
    /// When: Call the headObject API
    /// Then: The expected metadata should exist on the object
    func testPutWithMetadata() {
        let key = "testputwithmetadata"
        let value = key + "Value"
        let data = key.data(using: .utf8)!
        let metadataKey = "metadatakey"
        let metadataValue = metadataKey + "Value"
        let metadata = [key: value, metadataKey: metadataValue]
        let options = StoragePutOptions(accessLevel: nil, contentType: nil, metadata: metadata)
        let completeInvoked = expectation(description: "Completed is invoked")

        let operation = Amplify.Storage.put(key: key, data: data, options: options) { (event) in
            switch event {
            case .completed:
                completeInvoked.fulfill()
            case .failed(let error):
                XCTFail("Failed with \(error)")
            default:
                break
            }
        }

        XCTAssertNotNil(operation)
        waitForExpectations(timeout: networkTimeout)

        do {
            let pluginOptional = try Amplify.Storage.getPlugin(for: "AWSS3StoragePlugin")

            guard let plugin = pluginOptional as? AWSS3StoragePlugin else {
                XCTFail("Could not cast as AWSS3StoragePlugin")
                return
            }

            let awsS3 = plugin.getEscapeHatch()
            let request: AWSS3HeadObjectRequest = AWSS3HeadObjectRequest()
            if case let .string(bucket) = bucket {
                request.bucket = bucket
            }
            request.key = "public/" + key

            let task = awsS3.headObject(request)
            task.waitUntilFinished()

            if let error = task.error {
                XCTFail("Failed to get headObject \(error)")
            } else if let result = task.result {
                let headObjectOutput = result as AWSS3HeadObjectOutput
                print("headObject \(result)")
                XCTAssertNotNil(headObjectOutput)
                XCTAssertNotNil(headObjectOutput.metadata)
                if let metadata = headObjectOutput.metadata {
                    XCTAssertEqual(metadata[key], value)
                    XCTAssertEqual(metadata[metadataKey], metadataValue)
                }
            }
        } catch {
            XCTFail("Failed to get AWSS3StoragePlugin")
        }
    }

    func testPutLargeDataWithMetadata() {

    }

    func testPutWithContentType() {

    }

//    func testPutWithTags() {
//        XCTFail("Not yet implemented")
//    }
//
//    func testPutLargeDataWithMultiPart() {
//        XCTFail("Not yet implemented")
//    }
}
