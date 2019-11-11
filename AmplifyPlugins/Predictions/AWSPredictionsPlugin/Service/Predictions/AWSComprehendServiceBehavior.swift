//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify
import AWSComprehend

protocol AWSComprehendServiceBehavior {

    typealias ComprehendServiceEventHandler = (ComprehendServiceEvent) -> Void
    typealias ComprehendServiceEvent = PredictionsEvent<InterpretResult, PredictionsError>

    func comprehend(text: String,
                    onEvent: @escaping ComprehendServiceEventHandler)
}
