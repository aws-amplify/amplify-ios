//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation

final public class AWSGraphQLOperation<R: ResponseType>: AmplifyOperation<GraphQLRequest,
    Void,
    GraphQLResponse<R.SerializedObject>,
    GraphQLError> {

    var graphQLResponseData = Data()
    let session: URLSessionBehavior
    let mapper: OperationTaskMapper
    let pluginConfig: AWSAPICategoryPluginConfiguration
    let responseType: R

    init(request: GraphQLRequest,
         eventName: String,
         responseType: R,
         listener: AWSGraphQLOperation.EventListener?,
         session: URLSessionBehavior,
         mapper: OperationTaskMapper,
         pluginConfig: AWSAPICategoryPluginConfiguration) {

        self.responseType = responseType
        self.session = session
        self.mapper = mapper
        self.pluginConfig = pluginConfig

        super.init(categoryType: .api,
                   eventName: eventName,
                   request: request,
                   listener: listener)
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
            let error = GraphQLError.invalidConfiguration(
                "Unable to get an endpoint configuration for \(request.apiName)",
                """
                Review your API plugin configuration and ensure \(request.apiName) has a valid configuration.
                """
            )
            dispatch(event: .failed(error))
            finish()
            return
        }

        // Prepare request payload
        let queryDocument = GraphQLRequestUtils.getQueryDocument(document: request.document,
                                                                 variables: request.variables)
        let requestPayload: Data
        do {
            requestPayload = try JSONSerialization.data(withJSONObject: queryDocument)
        } catch {
            dispatch(event: .failed(GraphQLError.operationError("Failed to serialize query document",
                                                                "fix the document or variables",
                                                                error)))
            finish()
            return
        }

        // Create request
        let urlRequest = GraphQLRequestUtils.constructRequest(with: endpointConfig.baseURL,
                                                              requestPayload: requestPayload)

        // Intercept request
        let finalRequest = endpointConfig.interceptors.reduce(urlRequest) { (request, interceptor) -> URLRequest in
            do {
                return try interceptor.intercept(request)
            } catch {
                dispatch(event: .failed(GraphQLError.operationError("Failed to intercept request fully..",
                                                                    "Something wrong with the interceptor",
                                                                    error)))
                cancel()
                return request
            }
        }

        if isCancelled {
            finish()
            return
        }

        // Perform task of request
        let task = session.dataTaskBehavior(with: finalRequest)
        mapper.addPair(operation: self, task: task)
        task.resume()
    }
}
