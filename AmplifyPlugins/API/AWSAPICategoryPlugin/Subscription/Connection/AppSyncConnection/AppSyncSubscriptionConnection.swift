//
// Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// Licensed under the Amazon Software License
// http://aws.amazon.com/asl/
//

import Foundation

enum SubscriptionState {

    case notSubscribed

    case inProgress

    case subscribed
}

class AppSyncSubscriptionConnection: SubscriptionConnection, RetryableConnection {

    /// Provides a way to connect, disconnect, and send messages to the service.
    let connectionProvider: ConnectionProvider

    /// Map of all subscriptions on this connection
    var subscriptionItems: [String: SubscriptionItem] = [:]

    /// Retry logic to handle
    var retryHandler: ConnectionRetryHandler?

    convenience init(url: URL, interceptor: AuthInterceptor) {
        let connectionProvider = AppSyncConnectionProvider(for: url, interceptor: interceptor)
        connectionProvider.addInterceptor(interceptor)
        self.init(connectionProvider: connectionProvider)
    }

    init(connectionProvider: ConnectionProvider) {
        self.connectionProvider = connectionProvider

        connectionProvider.setListener { [weak self] (event) in
            guard let self = self else {
                return
            }

            switch event {
            case .connection(let identifier, let state):
                self.handleConnectionEvent(identifier: identifier, connectionState: state)
            case .data(let response):
                self.handleDataEvent(response: response)
            case .error(let identifier, let error):
                self.handleError(identifier: identifier, error: error)
            }
        }
    }

    func subscribe(requestString: String,
                   variables: [String: Any]?,
                   eventHandler: @escaping SubscriptionEventHandler<Data>) -> SubscriptionItem {
        let subscriptionItem = SubscriptionItem(requestString: requestString,
                                                variables: variables,
                                                eventHandler: eventHandler)
        subscriptionItems[subscriptionItem.identifier] = subscriptionItem
        connectionProvider.connect(identifier: subscriptionItem.identifier)

        return subscriptionItem
    }

    func unsubscribe(item: SubscriptionItem) {
        print("Unsubscribe - \(item.identifier)")
        let message = AppSyncMessage(id: item.identifier, type: .unsubscribe("stop"))
        connectionProvider.write(message)

        // TODO: find where the message comes back, and remove the mapping to subscriptionItem.
        //ie. subscriptionItems[item.identifier] = nil
    }

    func addRetryHandler(handler: ConnectionRetryHandler) {
        retryHandler = handler
    }
}
