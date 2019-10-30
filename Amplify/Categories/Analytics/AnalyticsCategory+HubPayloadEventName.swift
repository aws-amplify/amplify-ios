//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension HubPayload.EventName {
    struct Analytics { }
}

public extension HubPayload.EventName.Analytics {
    static let identifyUser = "Analytics.identifyUser"
    static let record = "Analytics.record"
    static let flushEvents = "Analytics.flushEvents"
}
