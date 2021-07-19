//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import Amplify
@testable import AmplifyTestCommon
@testable import AWSS3StoragePlugin

class AWSS3StoragePluginConfigurationTests: XCTestCase {

    func testConfiguration() {
        let storagePlugin = AWSS3StoragePlugin(configuration: .customPrefixResolver(MockPrefixResolver()))
        XCTAssertNotNil(storagePlugin.storageConfiguration.customPrefixResolver as? MockPrefixResolver)
    }

    func testConfigurationWithPassthroughKeyResolver() {
        let storagePlugin = AWSS3StoragePlugin(configuration: .passThroughPrefixResolver)
        XCTAssertNotNil(storagePlugin.storageConfiguration.customPrefixResolver as? PassThroughPrefixResolver)
    }

    func getPrefixResolverWithEmptyConfigAndNilOptions() {
        let configuration = AWSS3StoragePluginConfiguration()
        XCTAssertNil(configuration.getPrefixResolver(options: nil))
    }

    func getPrefixResolverWithValidConfigAndNilOptions() {
        let configuration = AWSS3StoragePluginConfiguration.passThroughPrefixResolver
        XCTAssertNotNil(configuration.getPrefixResolver(options: nil))
    }

    func getPrefixResolverWithEmptyConfigAndNilOptionsPrefixResolver() {
        let configuration = AWSS3StoragePluginConfiguration()
        let options = AWSS3PluginOptions(customPrefixResolver: nil)
        XCTAssertNil(configuration.getPrefixResolver(options: options))
    }

    func getPrefixResolverWithEmptyConfigAndValidOptions() {
        let configuration = AWSS3StoragePluginConfiguration()
        let options = AWSS3PluginOptions.passThroughKeyResolver
        XCTAssertNotNil(configuration.getPrefixResolver(options: options))
    }

    func getPrefixResolverWithValidConfigAndOptions() {
        let configuration = AWSS3StoragePluginConfiguration.passThroughPrefixResolver
        let options = AWSS3PluginOptions(customPrefixResolver: MockPrefixResolver())
        guard configuration.getPrefixResolver(options: options) as? MockPrefixResolver != nil else {
            XCTFail("Could not get prefix resolver from plugin options")
            return
        }
    }

    struct MockPrefixResolver: AWSS3PluginCustomPrefixResolver {
        func resolvePrefix(for accessLevel: StorageAccessLevel,
                           targetIdentityId: String?) -> Result<String, StorageError> {
            .success("")
        }
    }
}
