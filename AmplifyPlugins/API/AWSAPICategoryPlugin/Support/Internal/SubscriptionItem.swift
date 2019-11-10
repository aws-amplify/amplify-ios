//
// Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// Licensed under the Amazon Software License
// http://aws.amazon.com/asl/
//

import Foundation
import Amplify

/// Event handler for subscription.
typealias SubscriptionEventHandler<T> = (SubscriptionEvent<T>, SubscriptionItem) -> Void

/// Item that holds the subscription. This contains the raw query and variables.
class SubscriptionItem {

    /// Identifier for the subscription
    let identifier: String

    /// Subscription variables for the query
    let variables: [String: Any]?

    /// Request query for subscription
    let requestString: String

    /// State of the subscription
    var subscriptionState: SubscriptionState

    // Subscription related events will be send to this handler.
    let subscriptionEventHandler: SubscriptionEventHandler<Data>

    init(requestString: String,
         variables: [String: Any]?,
         subscriptionState: SubscriptionState = .notSubscribed,
         eventHandler: @escaping SubscriptionEventHandler<Data>) {

        self.identifier = UUID().uuidString
        self.variables = variables
        self.requestString = requestString
        self.subscriptionState = subscriptionState
        self.subscriptionEventHandler = eventHandler
    }

    func setState(subscriptionState: SubscriptionState) {
        self.subscriptionState = subscriptionState
        switch subscriptionState {
        case .notSubscribed:
            subscriptionEventHandler(.connection(.disconnected), self)
        case .inProgress:
            subscriptionEventHandler(.connection(.connecting), self)
        case .subscribed:
            subscriptionEventHandler(.connection(.connected), self)
        }
    }

    func dispatch(data: Data) {
        subscriptionEventHandler(.data(data), self)
    }

    func dispatch(error: Error) {
        subscriptionEventHandler(.failed(error), self)
    }
}
