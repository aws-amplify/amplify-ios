//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import Amplify
@testable import AWSS3StoragePlugin

class AWSS3StoragePluginAPIBehaviorTests: AWSS3StoragePluginTests {

    // MARK: GetURL API Tests

    func testPluginGetURL() {
        let operation = storagePlugin.getURL(key: testKey, options: nil, listener: nil)

        XCTAssertNotNil(operation)
        guard let awss3StorageGetURLOperation = operation as? AWSS3StorageGetURLOperation else {
            XCTFail("operation could not be cast as AWSS3StorageGetURLOperation")
            return
        }

        let request = awss3StorageGetURLOperation.request
        XCTAssertNotNil(request)
        XCTAssertEqual(request.options.accessLevel, defaultAccessLevel)
        XCTAssertNil(request.options.targetIdentityId)
        XCTAssertEqual(request.key, testKey)
        XCTAssertEqual(request.options.expires, StorageGetURLRequest.Options.defaultExpireInSeconds)
        XCTAssertEqual(queue.size, 1)
    }

    func testPluginGetURLWithOptions() {
        let options = StorageGetURLRequest.Options(accessLevel: .private,
                                                   targetIdentityId: testIdentityId,
                                                   expires: testExpires,
                                                   pluginOptions: [:])

        let operation = storagePlugin.getURL(key: testKey, options: options, listener: nil)

        XCTAssertNotNil(operation)
        guard let awss3StorageGetURLOperation = operation as? AWSS3StorageGetURLOperation else {
            XCTFail("operation could not be cast as AWSS3StorageGetURLOperation")
            return
        }
        let request = awss3StorageGetURLOperation.request
        XCTAssertNotNil(request)
        XCTAssertNotEqual(request.options.accessLevel, defaultAccessLevel)
        XCTAssertEqual(request.options.accessLevel, .private)
        XCTAssertEqual(request.options.targetIdentityId, testIdentityId)
        XCTAssertEqual(request.key, testKey)
        XCTAssertEqual(request.options.expires, testExpires)

        XCTAssertEqual(queue.size, 1)
    }

    // MARK: GetData API Tests

    func testPluginGetData() {
        let operation = storagePlugin.getData(key: testKey, options: nil, listener: nil)

        XCTAssertNotNil(operation)
        guard let awss3StorageGetDataOperation = operation as? AWSS3StorageGetDataOperation else {
            XCTFail("operation could not be cast as AWSS3StorageGetDataOperation")
            return
        }

        let request = awss3StorageGetDataOperation.request
        XCTAssertNotNil(request)
        XCTAssertEqual(request.options.accessLevel, defaultAccessLevel)
        XCTAssertNil(request.options.targetIdentityId)
        XCTAssertEqual(request.key, testKey)
        XCTAssertEqual(queue.size, 1)
    }

    func testPluginGetWithOptions() {
        let options = StorageGetDataRequest.Options(accessLevel: .private,
                                            targetIdentityId: testIdentityId,
                                            pluginOptions: [:])

        let operation = storagePlugin.getData(key: testKey, options: options, listener: nil)

        XCTAssertNotNil(operation)
        guard let awss3StorageGetDataOperation = operation as? AWSS3StorageGetDataOperation else {
            XCTFail("operation could not be cast as AWSS3StorageGetDataOperation")
            return
        }
        let request = awss3StorageGetDataOperation.request
        XCTAssertNotNil(request)
        XCTAssertNotEqual(request.options.accessLevel, defaultAccessLevel)
        XCTAssertEqual(request.options.accessLevel, .private)
        XCTAssertEqual(request.options.targetIdentityId, testIdentityId)
        XCTAssertEqual(request.key, testKey)
        XCTAssertEqual(queue.size, 1)
    }

    // MARK: DownloadFile API Tests

    func testPluginDownloadFile() {
        let operation = storagePlugin.downloadFile(key: testKey, local: testURL, options: nil, listener: nil)

        XCTAssertNotNil(operation)
        guard let awss3StorageDownloadFileOperation = operation as? AWSS3StorageDownloadFileOperation else {
            XCTFail("operation could not be cast as AWSS3StorageDownloadFileOperation")
            return
        }

        let request = awss3StorageDownloadFileOperation.request
        XCTAssertNotNil(request)
        XCTAssertEqual(request.options.accessLevel, defaultAccessLevel)
        XCTAssertNil(request.options.targetIdentityId)
        XCTAssertEqual(request.key, testKey)
        XCTAssertEqual(request.local, testURL)
        XCTAssertEqual(queue.size, 1)
    }

    func testPluginDownloadFileWithOptions() {
        let options = StorageDownloadFileRequest.Options(accessLevel: .private,
                                                 targetIdentityId: testIdentityId,
                                                 pluginOptions: [:])

        let operation = storagePlugin.downloadFile(key: testKey, local: testURL, options: options, listener: nil)

        XCTAssertNotNil(operation)
        guard let awss3StorageDownloadFileOperation = operation as? AWSS3StorageDownloadFileOperation else {
            XCTFail("operation could not be cast as AWSS3StorageDownloadFileOperation")
            return
        }
        let request = awss3StorageDownloadFileOperation.request
        XCTAssertNotNil(request)
        XCTAssertNotEqual(request.options.accessLevel, defaultAccessLevel)
        XCTAssertEqual(request.options.accessLevel, .private)
        XCTAssertEqual(request.options.targetIdentityId, testIdentityId)
        XCTAssertEqual(request.key, testKey)
        XCTAssertEqual(request.local, testURL)
        XCTAssertEqual(queue.size, 1)
    }

    // MARK: Put API tests

    func testPluginPut() {
        let operation = storagePlugin.put(key: testKey,
                                          data: testData,
                                          options: nil,
                                          listener: nil)

        XCTAssertNotNil(operation)
        guard let awss3StoragePutOperation = operation as? AWSS3StoragePutOperation else {
            XCTFail("operation could not be cast as AWSS3StoragePutOperation")
            return
        }
        let request = awss3StoragePutOperation.request
        XCTAssertNotNil(request)
        XCTAssertEqual(request.options.accessLevel, defaultAccessLevel)
        XCTAssertEqual(request.key, testKey)
        XCTAssertNil(request.options.contentType)
        XCTAssertNil(request.options.metadata)
        XCTAssertNil(request.options.pluginOptions)
        guard case .data(let data) = request.source else {
            XCTFail("The request upload source should be data")
            return
        }
        XCTAssertEqual(data, testData)
        XCTAssertEqual(queue.size, 1)
    }

    func testPluginPutWithOptions() {
        let options = StoragePutRequest.Options(accessLevel: .private,
                                                metadata: [:],
                                                contentType: testContentType,
                                                pluginOptions: [:])

        let operation = storagePlugin.put(key: testKey,
                                          data: testData,
                                          options: options,
                                          listener: nil)

        XCTAssertNotNil(operation)
        guard let awss3StoragePutOperation = operation as? AWSS3StoragePutOperation else {
            XCTFail("operation could not be cast as AWSS3StoragePutOperation")
            return
        }
        let request = awss3StoragePutOperation.request
        XCTAssertNotNil(request)
        XCTAssertNotEqual(request.options.accessLevel, defaultAccessLevel)
        XCTAssertEqual(request.options.accessLevel, .private)
        XCTAssertEqual(request.key, testKey)
        XCTAssertNotNil(request.options.contentType)
        XCTAssertEqual(request.options.contentType, testContentType)
        XCTAssertNotNil(request.options.metadata)
        XCTAssertNotNil(request.options.pluginOptions)
        guard case .data(let data) = request.source else {
            XCTFail("The request upload source should be data")
            return
        }
        XCTAssertEqual(data, testData)
        XCTAssertEqual(queue.size, 1)
    }

    // MARK: Put to local file API tests

    func testPluginPutToLocalFile() {
        let operation = storagePlugin.put(key: testKey,
                                          local: testURL,
                                          options: nil,
                                          listener: nil)

        XCTAssertNotNil(operation)
        guard let awss3StoragePutOperation = operation as? AWSS3StoragePutOperation else {
            XCTFail("operation could not be cast as AWSS3StoragePutOperation")
            return
        }
        let request = awss3StoragePutOperation.request
        XCTAssertNotNil(request)
        XCTAssertEqual(request.options.accessLevel, defaultAccessLevel)
        XCTAssertEqual(request.key, testKey)
        XCTAssertNil(request.options.contentType)
        XCTAssertNil(request.options.metadata)
        XCTAssertNil(request.options.pluginOptions)
        guard case .local(let file) = request.source else {
            XCTFail("The request upload source should be url")
            return
        }
        XCTAssertEqual(file, testURL)

        XCTAssertEqual(queue.size, 1)
    }

    func testPluginPutToLocalFileWithOptions() {
        let options = StoragePutRequest.Options(accessLevel: .private,
                                       metadata: [:],
                                       contentType: testContentType,
                                       pluginOptions: [:])

        let operation = storagePlugin.put(key: testKey,
                                          local: testURL,
                                          options: options,
                                          listener: nil)

        XCTAssertNotNil(operation)
        guard let awss3StoragePutOperation = operation as? AWSS3StoragePutOperation else {
            XCTFail("operation could not be cast as AWSS3StoragePutOperation")
            return
        }
        let request = awss3StoragePutOperation.request
        XCTAssertNotNil(request)
        XCTAssertNotEqual(request.options.accessLevel, defaultAccessLevel)
        XCTAssertEqual(request.options.accessLevel, .private)
        XCTAssertEqual(request.key, testKey)
        XCTAssertNotNil(request.options.contentType)
        XCTAssertEqual(request.options.contentType, testContentType)
        XCTAssertNotNil(request.options.metadata)
        XCTAssertNotNil(request.options.pluginOptions)
        guard case .local(let file) = request.source else {
            XCTFail("The request upload source should be url")
            return
        }
        XCTAssertEqual(file, testURL)

        XCTAssertEqual(queue.size, 1)
    }

    // MARK: Remove API tests

    func testPluginRemove() {
        let operation = storagePlugin.remove(key: testKey, options: nil, listener: nil)

        XCTAssertNotNil(operation)
        guard let awss3StorageRemoveOperation = operation as? AWSS3StorageRemoveOperation else {
            XCTFail("operation could not be cast as AWSS3StorageRemoveOperation")
            return
        }
        let request = awss3StorageRemoveOperation.request
        XCTAssertNotNil(request)
        XCTAssertEqual(request.options.accessLevel, defaultAccessLevel)
        XCTAssertEqual(request.key, testKey)
        XCTAssertNil(request.options.pluginOptions)
        XCTAssertEqual(queue.size, 1)
    }

    func testPluginRemoveWithOptions() {
        let options = StorageRemoveRequest.Options(accessLevel: .private, pluginOptions: [:])

        let operation = storagePlugin.remove(key: testKey, options: options, listener: nil)

        XCTAssertNotNil(operation)
        guard let awss3StorageRemoveOperation = operation as? AWSS3StorageRemoveOperation else {
            XCTFail("operation could not be cast as AWSS3StorageRemoveOperation")
            return
        }
        let request = awss3StorageRemoveOperation.request
        XCTAssertNotNil(request)
        XCTAssertNotEqual(request.options.accessLevel, defaultAccessLevel)
        XCTAssertEqual(request.options.accessLevel, .private)
        XCTAssertEqual(request.key, testKey)
        XCTAssertNotNil(request.options.pluginOptions)
        XCTAssertEqual(queue.size, 1)
    }

    // MARK: List API tests

    func testPluginList() {
        let operation = storagePlugin.list(options: nil, listener: nil)

        XCTAssertNotNil(operation)
        guard let awss3StorageListOperation = operation as? AWSS3StorageListOperation else {
            XCTFail("operation could not be cast as AWSS3StoragelistOperation")
            return
        }
        let request = awss3StorageListOperation.request
        XCTAssertNotNil(request)
        XCTAssertEqual(request.options.accessLevel, defaultAccessLevel)
        XCTAssertNil(request.options.path)
        XCTAssertNil(request.options.pluginOptions)
        XCTAssertEqual(queue.size, 1)
    }

    func testPluginListWithOptions() {
        let options = StorageListRequest.Options(accessLevel: .private,
                                        targetIdentityId: testIdentityId,
                                        path: testPath,
                                        pluginOptions: [:])

        let operation = storagePlugin.list(options: options, listener: nil)

        XCTAssertNotNil(operation)
        guard let awss3StorageListOperation = operation as? AWSS3StorageListOperation else {
            XCTFail("operation could not be cast as AWSS3StoragelistOperation")
            return
        }
        let request = awss3StorageListOperation.request
        XCTAssertNotNil(request)
        XCTAssertNotEqual(request.options.accessLevel, defaultAccessLevel)
        XCTAssertEqual(request.options.accessLevel, .private)
        XCTAssertNotNil(request.options.targetIdentityId, testIdentityId)
        XCTAssertEqual(request.options.path, testPath)
        XCTAssertNotNil(request.options.pluginOptions)
        XCTAssertEqual(queue.size, 1)
    }
}
