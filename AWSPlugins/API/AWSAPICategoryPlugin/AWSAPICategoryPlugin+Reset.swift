//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify

public extension AWSAPICategoryPlugin {
    func reset(onComplete: @escaping BasicClosure) {
        mapper.reset()

        mapper = OperationTaskMapper()

        let waitForReset = DispatchSemaphore(value: 0)
        httpTransport.reset { waitForReset.signal() }
        _ = waitForReset.wait()

        httpTransport = nil

        pluginConfig = nil

        authService = nil

        onComplete()
    }
}
