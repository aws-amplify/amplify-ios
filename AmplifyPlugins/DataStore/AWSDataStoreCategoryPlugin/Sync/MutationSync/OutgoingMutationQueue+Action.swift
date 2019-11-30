//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Combine

extension OutgoingMutationQueue {

    /// Actions are declarative, they say what I just did
    enum Action {
        // Startup/config actions
        case initialized
        case receivedStart(APICategoryGraphQLBehavior, MutationEventPublisher)
        case receivedSubscription

        // Terminal actions
        case receivedCancel
        case errored(AmplifyError)

        var displayName: String {
            switch self {
            case .errored:
                return "errored"
            case .initialized:
                return "initialized"
            case .receivedCancel:
                return "receivedCancel"
            case .receivedStart:
                return "receivedStart"
            case .receivedSubscription:
                return "receivedSubscription"
            }
        }
    }

}
