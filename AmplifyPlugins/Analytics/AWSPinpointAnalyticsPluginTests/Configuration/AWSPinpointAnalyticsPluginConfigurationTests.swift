//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import Amplify

@testable import AWSPinpointAnalyticsPlugin

class AWSPinpointAnalyticsPluginConfigurationTests: XCTestCase {

    let testAppId = "testAppId"
    let appId: JSONValue = "testAppId"
    let testRegion = "us-east-1"
    let region: JSONValue = "us-east-1"
    let testAutoFlushInterval = 300
    let autoFlushInterval: JSONValue = 300
    let testTrackAppSession = false
    let trackAppSession: JSONValue = false
    let testAutoSessionTrackingInterval = 100
    let autoSessionTrackingInterval: JSONValue = 100
    let pinpointAnalyticsPluginConfiguration = JSONValue.init(
        dictionaryLiteral:
        (AWSPinpointAnalyticsPluginConfiguration.appIdConfigKey, "testAppId"),
        (AWSPinpointAnalyticsPluginConfiguration.regionConfigKey, "us-east-1"))
    let regionConfiguration = JSONValue.init(dictionaryLiteral:
        (AWSPinpointAnalyticsPluginConfiguration.regionConfigKey, "us-east-1"))

    func testConfigureSuccess() throws {
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration))

        do {
            let config = try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)
            XCTAssertNotNil(config)
            XCTAssertEqual(config.appId, testAppId)
            XCTAssertEqual(config.region, testRegion.aws_regionTypeValue())
            XCTAssertEqual(config.targetingRegion, testRegion.aws_regionTypeValue())
            XCTAssertEqual(config.autoFlushEventsInterval,
                           AWSPinpointAnalyticsPluginConfiguration.defaultAutoFlushEventsInterval)
            XCTAssertEqual(config.trackAppSessions,
                           AWSPinpointAnalyticsPluginConfiguration.defaultTrackAppSession)
            XCTAssertEqual(config.autoSessionTrackingInterval,
                           AWSPinpointAnalyticsPluginConfiguration.defaultAutoSessionTrackingInterval)
        } catch {
            XCTFail("Failed to instantiate analytics plugin configuration")
        }
    }

     func testConfigureWithAutoFlushEventsIntervalSuccess() {
         let analyticsPluginConfig = JSONValue.init(
             dictionaryLiteral:
             (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
             (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration),
             (AWSPinpointAnalyticsPluginConfiguration.autoFlushEventsIntervalKey, autoFlushInterval))

         do {
             let config = try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)
            XCTAssertNotNil(config)
            XCTAssertEqual(config.appId, testAppId)
            XCTAssertEqual(config.region, testRegion.aws_regionTypeValue())
            XCTAssertEqual(config.targetingRegion, testRegion.aws_regionTypeValue())
            XCTAssertEqual(config.autoFlushEventsInterval, testAutoFlushInterval)
            XCTAssertEqual(config.trackAppSessions,
                           AWSPinpointAnalyticsPluginConfiguration.defaultTrackAppSession)
            XCTAssertEqual(config.autoSessionTrackingInterval,
                           AWSPinpointAnalyticsPluginConfiguration.defaultAutoSessionTrackingInterval)
         } catch {
            XCTFail("Failed to instantiate analytics plugin configuration")
         }
     }

     func testConfigureThrowsErrorForInvalidAutoFlushEventsIntervalValue() {
        let autoFlushInterval = JSONValue.init(integerLiteral: -100)
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.autoFlushEventsIntervalKey, autoFlushInterval))

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription,
                           AnalyticsPluginErrorConstant.invalidAutoFlushEventsInterval.errorDescription)
        }
    }

    func testConfigureWithTrackAppSessionSuccess() {
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.trackAppSessionsKey, trackAppSession))

        do {
            let config = try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)
            XCTAssertNotNil(config)
            XCTAssertEqual(config.appId, testAppId)
            XCTAssertEqual(config.region, testRegion.aws_regionTypeValue())
            XCTAssertEqual(config.targetingRegion, testRegion.aws_regionTypeValue())
            XCTAssertEqual(config.autoFlushEventsInterval,
                           AWSPinpointAnalyticsPluginConfiguration.defaultAutoFlushEventsInterval)
            XCTAssertEqual(config.trackAppSessions, testTrackAppSession)
            XCTAssertEqual(config.autoSessionTrackingInterval,
                           AWSPinpointAnalyticsPluginConfiguration.defaultAutoSessionTrackingInterval)
        } catch {
            XCTFail("Failed to instantiate analytics plugin configuration")
        }
     }

    func testConfigureWithAutoSessionTrackingIntervalSuccess() {
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.autoSessionTrackingIntervalKey, autoSessionTrackingInterval))

        do {
            let config = try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)
            XCTAssertNotNil(config)
            XCTAssertEqual(config.appId, testAppId)
            XCTAssertEqual(config.region, testRegion.aws_regionTypeValue())
            XCTAssertEqual(config.targetingRegion, testRegion.aws_regionTypeValue())
            XCTAssertEqual(config.autoFlushEventsInterval,
                           AWSPinpointAnalyticsPluginConfiguration.defaultAutoFlushEventsInterval)
            XCTAssertEqual(config.trackAppSessions, AWSPinpointAnalyticsPluginConfiguration.defaultTrackAppSession)
            XCTAssertEqual(config.autoSessionTrackingInterval, testAutoSessionTrackingInterval)
        } catch {
            XCTFail("Failed to instantiate analytics plugin configuration")
        }
     }

    func testConfigureThrowsErrorForInvalidAutoSessionTrackingValue() {
        let autoSessionTrackingInterval = JSONValue.init(integerLiteral: -100)
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.autoSessionTrackingIntervalKey, autoSessionTrackingInterval))

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription,
                           AnalyticsPluginErrorConstant.invalidAutoSessionTrackingInterval.errorDescription)
        }
    }

     func testConfigureThrowsErrorForMissingConfigurationObject() {
        let analyticsPluginConfig = JSONValue.init(stringLiteral: "notADictionaryLiteral")

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription,
                           AnalyticsPluginErrorConstant.configurationObjectExpected.errorDescription)
        }
     }

     func testConfigureThrowsErrorForMissingPinpointAnalyticsConfiguration() {
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration))

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription,
                           AnalyticsPluginErrorConstant.missingPinpointAnalyicsConfiguration.errorDescription)
        }
     }

     func testConfigureThrowsErrorForMissingPinpointAnalyticsConfigurationObject() {
        let pinpointAnalyticsPluginConfiguration = JSONValue.init(stringLiteral: "notDictionary")
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration))

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription,
                           AnalyticsPluginErrorConstant.pinpointAnalyticsConfigurationExpected.errorDescription)
        }
     }

     func testConfigureThrowsErrorForMissingPinpointAnalyticsAppId() {
        let pinpointAnalyticsPluginConfiguration = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.regionConfigKey, region))
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration))

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription, AnalyticsPluginErrorConstant.missingAppId.errorDescription)
        }
     }

     func testConfigureThrowsErrorForEmptyPinpointAnalyticsAppIdValue() {
        let pinpointAnalyticsPluginConfiguration = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.appIdConfigKey, ""),
            (AWSPinpointAnalyticsPluginConfiguration.regionConfigKey, region))
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration))

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription, AnalyticsPluginErrorConstant.emptyAppId.errorDescription)
        }
     }

    func testConfigureThrowsErrorForInvalidPinpointAnalyticsAppIdValue() {
        let pinpointAnalyticsPluginConfiguration = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.appIdConfigKey, 1),
            (AWSPinpointAnalyticsPluginConfiguration.regionConfigKey, region))
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration))

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription, AnalyticsPluginErrorConstant.invalidAppId.errorDescription)
        }
    }

    func testConfigureThrowsErrorForMissingPinpointAnalyticsRegion() {
        let pinpointAnalyticsPluginConfiguration = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.appIdConfigKey, appId))
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration))

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription, AnalyticsPluginErrorConstant.missingRegion.errorDescription)
        }
    }

    func testConfigureThrowsErrorForEmptyPinpointAnalyticsRegionValue() {
        let pinpointAnalyticsPluginConfiguration = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.appIdConfigKey, appId),
            (AWSPinpointAnalyticsPluginConfiguration.regionConfigKey, ""))
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration))

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription, AnalyticsPluginErrorConstant.emptyRegion.errorDescription)
        }
    }

    func testConfigureThrowsErrorForInvalidPinpointAnalyticsRegionValue() {
        let pinpointAnalyticsPluginConfiguration = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.appIdConfigKey, appId),
            (AWSPinpointAnalyticsPluginConfiguration.regionConfigKey, "invalidRegion"))
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration))

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription, AnalyticsPluginErrorConstant.invalidRegion.errorDescription)
        }
    }

    func testConfigureThrowsErrorForMissingPinpointTargetingConfiguration() {
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration))

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription,
                           AnalyticsPluginErrorConstant.missingPinpointTargetingConfiguration.errorDescription)
        }

    }

    func testConfigureThrowsErrorForMissingPinpointTargetingConfigurationObject() {
        let regionConfiguration = JSONValue.init(stringLiteral: "notDictionary")
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration))

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription,
                           AnalyticsPluginErrorConstant.pinpointTargetingConfigurationExpected.errorDescription)
        }
    }

    func testConfigureThrowsErrorForMissingPinpointTargetingRegion() {
        let regionConfiguration = JSONValue.init(dictionaryLiteral:
            ("MissingRegionKey", region))
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration))

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription, AnalyticsPluginErrorConstant.missingRegion.errorDescription)
        }
    }

    func testConfigureThrowsErrorForEmptyPinpointTargetingRegionValue() {
        let regionConfiguration = JSONValue.init(dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.regionConfigKey, ""))
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration))

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription, AnalyticsPluginErrorConstant.emptyRegion.errorDescription)
        }
    }

    func testConfigureThrowsErrorForInvalidPinpointTargetingRegionValue() {
        let regionConfiguration = JSONValue.init(dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.regionConfigKey, "invalidRegion"))
        let analyticsPluginConfig = JSONValue.init(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration))

        XCTAssertThrowsError(try AWSPinpointAnalyticsPluginConfiguration(analyticsPluginConfig)) { error in
            guard case let PluginError.pluginConfigurationError(errorDescription, _, _) = error else {
                XCTFail("Expected PluginError pluginConfigurationError, got: \(error)")
                return
            }
            XCTAssertEqual(errorDescription, AnalyticsPluginErrorConstant.invalidRegion.errorDescription)
        }
    }
}
