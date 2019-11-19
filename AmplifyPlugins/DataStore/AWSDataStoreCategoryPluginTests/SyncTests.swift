//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import SQLite
import CwlPreconditionTesting

@testable import Amplify
@testable import AmplifyTestCommon
@testable import AWSDataStoreCategoryPlugin

class SyncTests: XCTestCase {

    // Tests in this class will directly access the database to validate persistent queue behavior
    var storageAdapter: SQLiteStorageEngineAdapter!

    /// Amplify should not crash if attempting to mutate a non-syncable model
    /// without a configured API category
    ///
    /// - Given: An Amplify system configured with a DataStore but no API category
    /// - When:
    ///    - I invoke `save` on a non-syncable model
    /// - Then:
    ///    - The operation succeeds
    func testNonSyncableWithoutAPICategorySucceeds() throws {
        try setUpWithAPI()

        let model = MockUnsynced()

        let modelSaved = expectation(description: "Model saved")
        Amplify.DataStore.save(model) { _ in modelSaved.fulfill() }
        wait(for: [modelSaved], timeout: 1.0)
    }

    /// Amplify should crash with a preconditionFailure if attempting to mutate a syncable model
    /// without a configured API category
    ///
    /// - Given: An Amplify system configured with a DataStore but no API category
    /// - When:
    ///    - I invoke `save` on a syncable model
    /// - Then:
    ///    - Amplify crashes
    func testSyncWithoutAPICategoryCrashes() throws {
        try setUpWithoutAPI()

        let model = MockSynced()

        let exception: BadInstructionException? = catchBadInstruction {
            Amplify.DataStore.save(model) { _ in }
        }
        XCTAssertNotNil(exception)
    }

    /// Amplify should allow me to subscribe() to model
    ///
    /// - Given: A configured Amplify system on iOS 13 or higher
    /// - When:
    ///    - I invoke `Amplify.DataStore.subscribe()`
    /// - Then:
    ///    - I receive a notification for updates to that model
    func testSubscribe() {
        XCTFail("Not yet implemented")
    }

    /// Amplify notifies me of save events
    ///
    /// - Given: A configured DataStore
    /// - When:
    ///    - I subscribe to model events
    /// - Then:
    ///    - I am notified of `save` events
    func testSave() {
        XCTFail("Not yet implemented")
    }

    /// Amplify notifies me of update events
    ///
    /// - Given: A configured DataStore
    /// - When:
    ///    - I subscribe to model events
    /// - Then:
    ///    - I am notified of `update` events
    func testUpdate() {
        XCTFail("Not yet implemented")
    }

    /// Amplify notifies me of delete events
    ///
    /// - Given: A configured DataStore
    /// - When:
    ///    - I subscribe to model events
    /// - Then:
    ///    - I am notified of `delete` events
    func testDelete() {
        XCTFail("Not yet implemented")
    }

}

// MARK: - Setup

extension SyncTests {
    private func setUpCore() throws -> AmplifyConfiguration {
        Amplify.reset()
        ModelRegistry.register(modelType: MockSynced.self)
        ModelRegistry.register(modelType: MockUnsynced.self)

        let connection = try Connection(.inMemory)
        storageAdapter = SQLiteStorageEngineAdapter(connection: connection)

        let syncEngineFactory: CloudSyncEngineBehavior.Factory? = { CloudSyncEngine(storageEngine: $0) }
        let storageEngine = StorageEngine(adapter: storageAdapter, syncEngineFactory: syncEngineFactory)

        let dataStorePublisher = DataStorePublisher()
        let dataStorePlugin = AWSDataStoreCategoryPlugin(storageEngine: storageEngine,
                                                         dataStorePublisher: dataStorePublisher)
        try Amplify.add(plugin: dataStorePlugin)

        let dataStoreConfig = DataStoreCategoryConfiguration(plugins: [
            "AWSDataStoreCategoryPlugin": true
        ])

        let amplifyConfig = AmplifyConfiguration(dataStore: dataStoreConfig)

        return amplifyConfig
    }

    private func setUpAPICategory(config: AmplifyConfiguration) throws -> AmplifyConfiguration {
        let apiPlugin = MockAPICategoryPlugin()
        try Amplify.add(plugin: apiPlugin)

        let apiConfig = APICategoryConfiguration(plugins: [
            "MockAPICategoryPlugin": true
        ])

        let amplifyConfig = AmplifyConfiguration(api: apiConfig, dataStore: config.dataStore)

        return amplifyConfig
    }

    private func setUpWithAPI() throws {
        let configWithoutAPI = try setUpCore()
        let configWithAPI = try setUpAPICategory(config: configWithoutAPI)
        try Amplify.configure(configWithAPI)
    }

    private func setUpWithoutAPI() throws {
        let configWithoutAPI = try setUpCore()
        try Amplify.configure(configWithoutAPI)
    }

}

// MARK: - MockSynced

public struct MockSynced: Model {

    public let id: String

    public init(id: String = UUID().uuidString) {
        self.id = id
    }

}

extension MockSynced {

    // MARK: - CodingKeys
    public enum CodingKeys: String, ModelKey {
        case id
    }

    public static let keys = CodingKeys.self

    // MARK: - ModelSchema

    public static let schema = defineSchema { model in
        let post = MockSynced.keys

        model.attributes = [.isSyncable]

        model.fields(
            .id()
        )
    }

}

// MARK: - MockUnsynced

public struct MockUnsynced: Model {

    public let id: String

    public init(id: String = UUID().uuidString) {
        self.id = id
    }

}

extension MockUnsynced {

    // MARK: - CodingKeys
    public enum CodingKeys: String, ModelKey {
        case id
    }

    public static let keys = CodingKeys.self

    // MARK: - ModelSchema

    public static let schema = defineSchema { model in
        let post = MockUnsynced.keys

        model.fields(
            .id()
        )
    }

}
