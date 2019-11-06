//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify

extension CoreMLPredictionsPlugin {

    public func reset(onComplete: @escaping BasicClosure) {

        if queue != nil {
            queue = nil
        }

        onComplete()
    }
}
