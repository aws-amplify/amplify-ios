//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify

public extension AWSAPICategoryPlugin {

    /// Performs a GraphQL query
    ///
    /// - Parameter apiName: Name of the configured API
    /// - Parameter document: GraphQL query document
    /// - Parameter variables: specified for inputs specified in the `document`
    /// - Parameter responseType: The type to deserialize the response object to
    /// - Parameter listener: The closure to receive response updates.
    func query<R: ResponseType>(apiName: String,
                                document: String,
                                variables: [String: Any]?,
                                responseType: R,
                                listener: ((AsyncEvent<Void, GraphQLResponse<R.SerializedObject>, GraphQLError>) -> Void)?) ->
        AmplifyOperation<GraphQLRequest, Void, GraphQLResponse<R.SerializedObject>, GraphQLError> {

            return graphql(apiName: apiName,
                           operationType: .query,
                           eventName: HubPayload.EventName.API.query,
                           document: document,
                           variables: variables,
                           responseType: responseType,
                           listener: listener)
    }

    /// Performs a GraphQL mutation
    ///
    /// - Parameter apiName: Name of the configured API
    /// - Parameter document: GraphQL query document
    /// - Parameter variables: specified for inputs specified in the `document`
    /// - Parameter responseType: The type to deserialize the response object to
    /// - Parameter listener: The closure to receive response updates.
    func mutate<R: ResponseType>(apiName: String,
                                 document: String,
                                 variables: [String: Any]?,
                                 responseType: R,
                                 listener: ((AsyncEvent<Void, GraphQLResponse<R.SerializedObject>, GraphQLError>) -> Void)?) ->
        AmplifyOperation<GraphQLRequest, Void, GraphQLResponse<R.SerializedObject>, GraphQLError> {

        return graphql(apiName: apiName,
                       operationType: .mutation,
                       eventName: HubPayload.EventName.API.mutate,
                       document: document,
                       variables: variables,
                       responseType: responseType,
                       listener: listener)
    }


    func subscribe<R: ResponseType>(apiName: String,
                                    document: String,
                                    variables: [String: Any]?,
                                    responseType: R,
                                    listener: ((AsyncEvent<Void, GraphQLResponse<R.SerializedObject>, GraphQLError>) -> Void)?) ->
        AmplifyOperation<GraphQLRequest, Void, GraphQLResponse<R.SerializedObject>, GraphQLError> {

        return graphql(apiName: apiName,
                       operationType: .subscription,
                       eventName: HubPayload.EventName.API.subscribe,
                       document: document,
                       variables: variables,
                       responseType: responseType,
                       listener: listener)
    }

    /// Used by `query` and `mutate` to consolidate creating a `GraphQLRequest` containing a snapshot of the request
    /// and `AWSGraphQlOperation` to perform the execution of the request
    private func graphql<R: ResponseType>(apiName: String,
                                          operationType: GraphQLOperationType,
                                          eventName: String,
                                          document: String,
                                          variables: [String: Any]?,
                                          responseType: R,
                                          listener: ((AsyncEvent<Void, GraphQLResponse<R.SerializedObject>, GraphQLError>) -> Void)?) ->
        AmplifyOperation<GraphQLRequest, Void, GraphQLResponse<R.SerializedObject>, GraphQLError> {

            let graphQLQueryRequest = GraphQLRequest(apiName: apiName,
                                                     operationType: operationType,
                                                     document: document,
                                                     variables: variables,
                                                     options: GraphQLRequest.Options())

            let operation = AWSGraphQLOperation(request: graphQLQueryRequest,
                                                eventName: eventName,
                                                responseType: responseType,
                                                listener: listener,
                                                session: session,
                                                mapper: mapper,
                                                pluginConfig: pluginConfig)
            queue.addOperation(operation)
            return operation
    }
}
