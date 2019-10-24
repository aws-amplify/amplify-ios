//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSPluginsCore

final public class AWSAPICategoryPlugin: APICategoryPlugin {

    public var key: PluginKey {
        return "AWSAPICategoryPlugin"
    }

    /// A holder for API configurations. This will be populated during the
    /// configuration phase, and is clearable by `reset()`.
    var pluginConfig: AWSAPICategoryPluginConfig!

    /// The provider for Auth services required to access protected APIs. This will be
    /// populated during the configuration phase, and is clearable by `reset()`.
    var authService: AWSAuthServiceBehavior!

    /// The provider for network connections and operations. This will be populated
    /// during initialization, and is clearable by `reset()`.
    var httpTransport: HTTPTransport!

    /// Maps APIOperations to HTTPTransportTasks
    var mapper: OperationTaskMapper

    init(httpTransport: HTTPTransport) {
        self.httpTransport = httpTransport
        self.mapper = OperationTaskMapper()
    }

}

public extension AWSAPICategoryPlugin {

    convenience init() {
        let defaultHTTPTransport = URLSessionHTTPTransport()
        self.init(httpTransport: defaultHTTPTransport)
    }

}
