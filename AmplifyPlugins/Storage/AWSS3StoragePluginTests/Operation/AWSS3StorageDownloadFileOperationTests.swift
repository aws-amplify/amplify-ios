//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import Amplify
@testable import AmplifyTestCommon
@testable import AWSS3StoragePlugin
@testable import AWSPluginsCore
import AWSS3

class AWSS3StorageDownloadFileOperationTests: AWSS3StorageOperationTestBase {

    func testDownloadFileOperationValidationError() {
        let request = StorageDownloadFileRequest(key: "",
                                                 local: testURL,
                                                 options: StorageDownloadFileRequest.Options())
        let failedInvoked = expectation(description: "failed was invoked on operation")
        let operation = AWSS3StorageDownloadFileOperation(request,
                                                          storageService: mockStorageService,
                                                          authService: mockAuthService) { event in
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
        waitForExpectations(timeout: 1)
        XCTAssertTrue(operation.isFinished)
    }

    func testDownloadFileOperationGetIdentityIdError() {
        mockAuthService.getIdentityIdError = AuthError.identity("", "", "")
        let request = StorageDownloadFileRequest(key: testKey,
                                                 local: testURL,
                                                 options: StorageDownloadFileRequest.Options())
        let failedInvoked = expectation(description: "failed was invoked on operation")
        let operation = AWSS3StorageDownloadFileOperation(request,
                                                          storageService: mockStorageService,
                                                          authService: mockAuthService) { event in
            switch event {
            case .failed(let error):
                guard case .authError = error else {
                    XCTFail("Should have failed with identity error")
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

    func testDownloadFileOperationDownloadLocal() {
        mockStorageService.storageServiceDownloadEvents = [
            StorageEvent.initiated(StorageTaskReference(AWSS3TransferUtilityTask())),
            StorageEvent.inProcess(Progress()),
            StorageEvent.completed(nil)]
        let url = URL(fileURLWithPath: "path")
        let request = StorageDownloadFileRequest(key: testKey,
                                                 local: testURL,
                                                 options: StorageDownloadFileRequest.Options())
        let expectedServiceKey = StorageAccessLevel.public.rawValue + "/" + testKey
        let inProcessInvoked = expectation(description: "inProgress was invoked on operation")
        let completeInvoked = expectation(description: "complete was invoked on operation")
        let operation = AWSS3StorageDownloadFileOperation(request,
                                                          storageService: mockStorageService,
                                                          authService: mockAuthService) { event in
            switch event {
            case .completed:
                completeInvoked.fulfill()
            case .inProcess:
                inProcessInvoked.fulfill()
            default:
                XCTFail("Unexpected event invoked on operation")
            }
        }

        operation.start()

        waitForExpectations(timeout: 1)
        XCTAssertTrue(operation.isFinished)
        mockStorageService.verifyDownload(serviceKey: expectedServiceKey, fileURL: url)
    }

    func testDownloadFileOperationDownloadLocalFailed() {
        mockStorageService.storageServiceDownloadEvents = [
            StorageEvent.initiated(StorageTaskReference(AWSS3TransferUtilityTask())),
            StorageEvent.inProcess(Progress()),
            StorageEvent.failed(StorageError.service("", ""))]
        let url = URL(fileURLWithPath: "path")
        let request = StorageDownloadFileRequest(key: testKey,
                                                 local: testURL,
                                                 options: StorageDownloadFileRequest.Options())
        let expectedServiceKey = StorageAccessLevel.public.rawValue + "/" + testKey
        let inProcessInvoked = expectation(description: "inProgress was invoked on operation")
        let failedInvoked = expectation(description: "failed was invoked on operation")
        let operation = AWSS3StorageDownloadFileOperation(request,
                                                          storageService: mockStorageService,
                                                          authService: mockAuthService) { event in
            switch event {
            case .failed:
                failedInvoked.fulfill()
            case .inProcess:
                inProcessInvoked.fulfill()
            default:
                XCTFail("Unexpected event invoked on operation")
            }
        }

        operation.start()

        waitForExpectations(timeout: 1)
        XCTAssertTrue(operation.isFinished)
        mockStorageService.verifyDownload(serviceKey: expectedServiceKey, fileURL: url)
    }

    func testGetOperationDownloadLocalFromTargetIdentityId() {
        mockStorageService.storageServiceDownloadEvents = [
            StorageEvent.initiated(StorageTaskReference(AWSS3TransferUtilityTask())),
            StorageEvent.inProcess(Progress()),
            StorageEvent.completed(nil)]
        let url = URL(fileURLWithPath: "path")
        let options = StorageDownloadFileRequest.Options(accessLevel: .protected,
                                                         targetIdentityId: testTargetIdentityId)
        let request = StorageDownloadFileRequest(key: testKey,
                                                 local: testURL,
                                                 options: options)
        let expectedServiceKey = StorageAccessLevel.protected.rawValue + "/" + testTargetIdentityId + "/" + testKey
        let inProcessInvoked = expectation(description: "inProgress was invoked on operation")
        let completeInvoked = expectation(description: "complete was invoked on operation")
        let operation = AWSS3StorageDownloadFileOperation(request,
                                                          storageService: mockStorageService,
                                                          authService: mockAuthService) { event in
            switch event {
            case .completed:
                completeInvoked.fulfill()
            case .inProcess:
                inProcessInvoked.fulfill()
            default:
                XCTFail("Unexpected event invoked on operation")
            }
        }

        operation.start()

        XCTAssertTrue(operation.isFinished)
        waitForExpectations(timeout: 1)
        mockStorageService.verifyDownload(serviceKey: expectedServiceKey, fileURL: url)
    }

    // TODO: missing unit tests for pause resume and cancel. do we create a mock of the StorageTaskReference?
}
