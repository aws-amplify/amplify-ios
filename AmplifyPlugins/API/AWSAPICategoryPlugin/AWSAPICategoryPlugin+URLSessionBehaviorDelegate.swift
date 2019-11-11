//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension AWSAPICategoryPlugin: URLSessionBehaviorDelegate {
    public func urlSessionBehavior(_ session: URLSessionBehavior,
                                   dataTaskBehavior: URLSessionDataTaskBehavior,
                                   didCompleteWithError error: Error?) {
        mapper.operation(for: dataTaskBehavior)?.complete(with: error)
    }

    public func urlSessionBehavior(_ session: URLSessionBehavior,
                                   dataTaskBehavior: URLSessionDataTaskBehavior,
                                   didReceive data: Data) {
        mapper.operation(for: dataTaskBehavior)?.updateProgress(data)
    }
}
