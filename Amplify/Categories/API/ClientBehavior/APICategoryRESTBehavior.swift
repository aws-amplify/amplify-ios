//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Behavior of the API category related to REST operations
public protocol APICategoryRESTBehavior {

    /// Perform an HTTP GET operation
    ///
    /// - Parameter apiName: The name of theb API to perform the request against
    /// - Parameter path: The path to the resource being requested
    /// - Parameter options: Options to adjust the behavior of this request, including plugin-options
    /// - Returns: An operation that can be observed for its value
    func get(apiName: String,
             path: String,
             listener: APIOperation.EventListener?) -> APIOperation

    /// Perform an HTTP POST operation
    ///
    /// - Parameter apiName: The name of theb API to perform the request against
    /// - Parameter path: The path to the resource being requested
    /// - Parameter body: The content body of the request
    /// - Parameter options: Options to adjust the behavior of this request, including plugin-options
    /// - Returns: An operation that can be observed for its value
    func post(apiName: String,
              path: String,
              body: String?,
              listener: APIOperation.EventListener?) -> APIOperation
}
