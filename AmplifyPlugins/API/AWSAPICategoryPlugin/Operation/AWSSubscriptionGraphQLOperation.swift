//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation
import AWSCore
import AWSPluginsCore

final public class AWSSubscriptionGraphQLOperation<R: Decodable>: AmplifyOperation<GraphQLRequest,
    SubscriptionEvent<GraphQLResponse<R>>,
    Void,
    APIError> {

    let pluginConfig: AWSAPICategoryPluginConfiguration
    let responseType: R.Type
    let subscriptionConnectionFactory: SubscriptionConnectionFactory
    let authService: AWSAuthServiceBehavior

    var subscriptionConnection: SubscriptionConnection?
    var subscriptionItem: SubscriptionItem?

    init(request: GraphQLRequest,
         responseType: R.Type,
         pluginConfig: AWSAPICategoryPluginConfiguration,
         subscriptionConnectionFactory: SubscriptionConnectionFactory,
         authService: AWSAuthServiceBehavior,
         listener: AWSSubscriptionGraphQLOperation.EventListener?) {

        self.responseType = responseType
        self.pluginConfig = pluginConfig
        self.subscriptionConnectionFactory = subscriptionConnectionFactory
        self.authService = authService

        super.init(categoryType: .api,
                   eventName: HubPayload.EventName.API.subscribe,
                   request: request,
                   listener: listener)
    }

    override public func cancel() {
        if let subscriptionItem = subscriptionItem, let subscriptionConnection = subscriptionConnection {
            subscriptionConnection.unsubscribe(item: subscriptionItem)
        }
        super.cancel()
    }

    override public func main() {
        if isCancelled {
            finish()
            return
        }

        // Validate the request
        if let error = request.validate() {
            dispatch(event: .failed(error))
            finish()
            return
        }

        // Retrieve endpoint configuration
        guard let endpointConfig = pluginConfig.endpoints[request.apiName] else {
            let error = APIError.invalidConfiguration(
                "Unable to get an endpoint configuration for \(request.apiName)",
                """
                Review your API plugin configuration and ensure \(request.apiName) has a valid configuration.
                """
            )
            dispatch(event: .failed(error))
            finish()
            return
        }

        // Retrieve the subscription connection
        let connection: SubscriptionConnection
        do {
            connection = try subscriptionConnectionFactory.getOrCreateConnection(for: endpointConfig,
                                                                                 authService: authService)
        } catch {
            let error = APIError.operationError("Unable to get connection for api \(request.apiName)", "", error)
            dispatch(event: .failed(error))
            finish()
            return
        }

        // Create subscription
        subscriptionItem = connection.subscribe(requestString: request.document,
                                                variables: request.variables,
                                                eventHandler: { [weak self] event, _ in
            self?.onSubscriptionEvent(event: event)
        })

    }

    private func onSubscriptionEvent(event: SubscriptionEvent<Data>) {
        switch event {
        case .connection(let subscriptionConnectionState):
            let subscriptionEvent = SubscriptionEvent<GraphQLResponse<R>>.connection(subscriptionConnectionState)
            dispatch(event: .inProcess(subscriptionEvent))
        case .data(let graphQLResponseData):
            do {
                let graphQLServiceResponse = try GraphQLResponseDecoder.deserialize(graphQLResponse: graphQLResponseData)
                let graphQLResponse = try GraphQLResponseDecoder.decode(
                    graphQLServiceResponse: graphQLServiceResponse, responseType: responseType)
                dispatch(event: .inProcess(.data(graphQLResponse)))
            } catch {
                dispatch(event: .failed(APIError.operationError("Failed to deserialize", "", error)))
            }
        case .failed(let error):
            dispatch(event: .failed(APIError.operationError("failed event", "", error)))
            finish()
            return
        }
    }
}
