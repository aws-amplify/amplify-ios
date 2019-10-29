//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import Amplify
@testable import AmplifyTestCommon
@testable import AWSPluginsCore
@testable import AWSPluginsTestCommon
@testable import AWSS3StoragePlugin

class AWSS3StorageRemoveOperationTests: AWSS3StorageOperationTestBase {

    func testRemoveOperationValidationError() {
        let options = StorageRemoveRequest.Options()
        let request = StorageRemoveRequest(key: "", options: options)

        let failedInvoked = expectation(description: "failed was invoked on operation")
        let operation = AWSS3StorageRemoveOperation(request,
                                                    storageService: mockStorageService,
                                                    authService: mockAuthService) { (event) in
            switch event {
            case .failed(let error):
                guard case .validation = error else {
                    XCTFail("Should have failed with validation error")
                    return
                }
                failedInvoked.fulfill()
            default:
                XCTFail("Should have received failed event")
            }
        }

        operation.start()

        XCTAssertTrue(operation.isFinished)
        waitForExpectations(timeout: 1)
    }

    func testRemoveOperationGetIdentityIdError() {
        mockAuthService.getIdentityIdError = AuthError.identity("", "", "")

        let options = StorageRemoveRequest.Options()
        let request = StorageRemoveRequest(key: testKey, options: options)
        let failedInvoked = expectation(description: "failed was invoked on operation")
        let operation = AWSS3StorageRemoveOperation(request,
                                                    storageService: mockStorageService,
                                                    authService: mockAuthService) { (event) in
            switch event {
            case .failed(let error):
                guard case .authError = error else {
                    XCTFail("Should have failed with authError")
                    return
                }
                failedInvoked.fulfill()
            default:
                XCTFail("Should have received failed event")
            }
        }

        operation.start()

        XCTAssertTrue(operation.isFinished)
        waitForExpectations(timeout: 1)
    }

    func testRemoveOperationDeleteSuccess() {
        mockStorageService.storageServiceDeleteEvents = [StorageEvent.completed(())]
        let options = StorageRemoveRequest.Options()
        let request = StorageRemoveRequest(key: testKey, options: options)

        let expectedServiceKey = StorageAccessLevel.public.rawValue + "/" + testKey
        let completeInvoked = expectation(description: "complete was invoked on operation")
        let operation = AWSS3StorageRemoveOperation(request,
                                                    storageService: mockStorageService,
                                                    authService: mockAuthService) { (event) in
            switch event {
            case .completed:
                completeInvoked.fulfill()
            default:
                XCTFail("Should have received completed event")
            }
        }

        operation.start()

        waitForExpectations(timeout: 1)
        XCTAssertTrue(operation.isFinished)
        mockStorageService.verifyDelete(serviceKey: expectedServiceKey)
    }

    func testRemoveOperationDeleteFail() {
        mockStorageService.storageServiceDeleteEvents = [StorageEvent.failed(StorageError.service("", ""))]
        let options = StorageRemoveRequest.Options()
        let request = StorageRemoveRequest(key: testKey, options: options)

        let expectedServiceKey = StorageAccessLevel.public.rawValue + "/" + testKey
        let failedInvoked = expectation(description: "failed was invoked on operation")
        let operation = AWSS3StorageRemoveOperation(request,
                                                    storageService: mockStorageService,
                                                    authService: mockAuthService) { (event) in
            switch event {
            case .failed:
                failedInvoked.fulfill()
            default:
                XCTFail("Should have received failed event")
            }
        }

        operation.start()

        waitForExpectations(timeout: 1)
        XCTAssertTrue(operation.isFinished)
        mockStorageService.verifyDelete(serviceKey: expectedServiceKey)
    }

    func testRemoveOperationDeleteForPrivateAccessLevel() {
        mockAuthService.identityId = testIdentityId
        mockStorageService.storageServiceDeleteEvents = [StorageEvent.completed(())]
        let options = StorageRemoveRequest.Options(accessLevel: .private)
        let request = StorageRemoveRequest(key: testKey, options: options)

        let expectedServiceKey = StorageAccessLevel.private.rawValue + "/" + testIdentityId + "/" + testKey
        let completeInvoked = expectation(description: "complete was invoked on operation")
        let operation = AWSS3StorageRemoveOperation(request,
                                                    storageService: mockStorageService,
                                                    authService: mockAuthService) { (event) in
            switch event {
            case .completed:
                completeInvoked.fulfill()
            default:
                XCTFail("Should have received completed event")
            }
        }

        operation.start()

        waitForExpectations(timeout: 1)
        XCTAssertTrue(operation.isFinished)
        mockStorageService.verifyDelete(serviceKey: expectedServiceKey)
    }
}
