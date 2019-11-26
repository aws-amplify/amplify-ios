//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSPluginsCore
import Combine

/// Subscribes to an IncomingSubscriptionAsyncEventQueue, and publishes AnyModel
final class AsyncSubscriptionEventToAnyModelMapper: Subscriber {
    typealias Input = IncomingAsyncSubscriptionEventPublisher.Event
    typealias Failure = DataStoreError

    var subscription: Subscription?

    private let modelsFromSubscription: PassthroughSubject<AnyModel, DataStoreError>

    var publisher: AnyPublisher<AnyModel, DataStoreError> {
        modelsFromSubscription.eraseToAnyPublisher()
    }

    init() {
        self.modelsFromSubscription = PassthroughSubject<AnyModel, DataStoreError>()
    }

    // MARK: - Subscriber

    func receive(subscription: Subscription) {
        log.info("received subscription: \(subscription)")
        self.subscription = subscription
        subscription.request(.max(1))
    }

    func receive(_ input: IncomingAsyncSubscriptionEventPublisher.Event) -> Subscribers.Demand {
        log.verbose("\(#function): \(input)")

        switch input {
        case .completed:
            log.debug("received completed event: \(input)")
            modelsFromSubscription.send(completion: .finished)
        case .failed(let apiError):
            let dataStoreError = DataStoreError.api(apiError)
            log.error(error: dataStoreError)
            modelsFromSubscription.send(completion: .failure(dataStoreError))
        case .inProcess(let subscriptionEvent):
            dispose(of: subscriptionEvent)
        default:
            break
        }
        return .max(1)
    }

    func receive(completion: Subscribers.Completion<DataStoreError>) {
        log.info("received completion: \(completion)")
    }

    // MARK: - Event processing

    private func dispose(of subscriptionEvent: SubscriptionEvent<GraphQLResponse<AnyModel>>) {
        log.verbose("dispose(of subscriptionEvent): \(subscriptionEvent)")
        switch subscriptionEvent {
        case .connection(let connectionState):
            // Connection events are informational only at this level. The terminal state is represented at the AsyncEvent Completion/Error
            log.info("connectionState now \(connectionState)")
        case .data(let graphQLResponse):
            dispose(of: graphQLResponse)
        }
    }

    private func dispose(of graphQLResponse: GraphQLResponse<AnyModel>) {
        log.verbose("dispose(of graphQLResponse): \(graphQLResponse)")
        switch graphQLResponse {
        case .success(let anyModel):
            modelsFromSubscription.send(anyModel)
        case .failure(let failure):
            log.error(error: failure)
        }
    }
}

extension AsyncSubscriptionEventToAnyModelMapper: DefaultLogger { }
