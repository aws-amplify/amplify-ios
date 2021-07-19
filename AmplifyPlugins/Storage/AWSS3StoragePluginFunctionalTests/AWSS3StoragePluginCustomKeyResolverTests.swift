//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import Amplify
import AWSS3StoragePlugin
@testable import AmplifyTestCommon

class AWSS3StoragePluginCustomKeyResolverTests: AWSS3StoragePluginTestBase {

    // This mock resolver shows how to perform an upload to the `.guest` access level with a custom prefix value.
    struct MockGuestOverridePrefixResolver: AWSS3PluginCustomPrefixResolver {
        func resolvePrefix(for accessLevel: StorageAccessLevel,
                           targetIdentityId: String?) -> Result<String, StorageError> {
            switch accessLevel {
            case .guest:
                return .success("public/customPublic/")
            case .protected:
                return .failure(.configuration("`.protected` StorageAccessLevel is not used", "", nil))
            case .private:
                return .failure(.configuration("`.protected` StorageAccessLevel is not used", "", nil))
            }
        }
    }

    /// Storage operations (upload, list, download) performed using a custom key resolver works as expected.
    ///
    /// - Given: Operations performed with the default access level (.guest) and a mock key resolver in plugin options.
    /// - When:
    ///    - Upload
    ///    - List from path equal to the `key` to retrieve the exact item that was uploaded.
    /// - Then:
    ///    - Download using the results from the List API as keys is successful
    ///
    func testUploadListDownload() {
        let key = UUID().uuidString
        let data = key.data(using: .utf8)!
        let uploadCompleted = expectation(description: "upload completed")

        let mockPrefixResolver = AWSS3PluginOptions(customPrefixResolver: MockGuestOverridePrefixResolver())
        let uploadOptions = StorageUploadDataRequest.Options(pluginOptions: mockPrefixResolver)
        _ = Amplify.Storage.uploadData(key: key, data: data, options: uploadOptions) { event in
            switch event {
            case .success:
                uploadCompleted.fulfill()
            case .failure(let error):
                XCTFail("Failed with \(error)")
            }
        }
        wait(for: [uploadCompleted], timeout: TestCommonConstants.networkTimeout)

        let listCompleted = expectation(description: "list completed")
        let listOptions = StorageListRequest.Options(path: key, pluginOptions: mockPrefixResolver)
        var resultItem: StorageListResult.Item?
        _ = Amplify.Storage.list(options: listOptions) { event in
            switch event {
            case .success(let result):
                XCTAssertNotNil(result)
                XCTAssertNotNil(result.items)
                XCTAssertEqual(result.items.count, 1)
                resultItem = result.items.first
                listCompleted.fulfill()
            case .failure(let error):
                XCTFail("Failed with \(error)")
            }
        }
        wait(for: [listCompleted], timeout: TestCommonConstants.networkTimeout)

        guard let item = resultItem else {
            XCTFail("Failed to retrieve key from List API")
            return
        }
        XCTAssertEqual(item.key, key)
        let downloadCompleted = expectation(description: "download completed")

        let downloadOptions = StorageDownloadDataRequest.Options(pluginOptions: mockPrefixResolver)
        _ = Amplify.Storage.downloadData(key: item.key, options: downloadOptions) { event in
            switch event {
            case .success(let data):
                XCTAssertNotNil(data)
                downloadCompleted.fulfill()
            case .failure(let error):
                XCTFail("Failed with \(error)")
            }
        }

        wait(for: [downloadCompleted], timeout: TestCommonConstants.networkTimeout)
    }

    /// Downloading data without the custom key resolver will fail if the key was uploaded with the resolver.
    ///
    /// - Given: Upload with `key` with the mock key resolver in plugin options.
    /// - When:
    ///    - Download without the key resolver.
    /// - Then:
    ///    - Download will fail
    ///
    func testUploadThenDownloadWithoutCustomResolverFails() {
        let key = UUID().uuidString
        let data = key.data(using: .utf8)!
        let uploadCompleted = expectation(description: "upload completed")

        let mockKeyResolver = AWSS3PluginOptions(customPrefixResolver: MockGuestOverridePrefixResolver())
        let uploadOptions = StorageUploadDataRequest.Options(pluginOptions: mockKeyResolver)
        _ = Amplify.Storage.uploadData(key: key, data: data, options: uploadOptions) { event in
            switch event {
            case .success:
                uploadCompleted.fulfill()
            case .failure(let error):
                XCTFail("Failed with \(error)")
            }
        }
        wait(for: [uploadCompleted], timeout: TestCommonConstants.networkTimeout)

        let downloadFailed = expectation(description: "download completed")

        _ = Amplify.Storage.downloadData(key: key) { event in
            switch event {
            case .success:
                XCTFail("Should not have completed successfully")
            case .failure(let error):
                guard case .keyNotFound = error else {
                    XCTFail("Should have been validation error")
                    return
                }

                downloadFailed.fulfill()
            }
        }

        wait(for: [downloadFailed], timeout: TestCommonConstants.networkTimeout)
    }
}
