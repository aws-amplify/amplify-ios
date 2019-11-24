//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Combine
import Foundation

class MockAPICategoryPlugin: MessageReporter, APICategoryPlugin {

    var key: String {
        return "MockAPICategoryPlugin"
    }

    func configure(using configuration: Any) throws {
        notify("configure")
    }

    func reset(onComplete: @escaping BasicClosure) {
        notify("reset")
        onComplete()
    }

    // MARK: - Model-based GraphQL methods

    func query<M>(from modelType: M.Type,
                  byId id: String,
                  listener: GraphQLOperation<M?>.EventListener?) -> GraphQLOperation<M?> {
        fatalError("Not yet implemented")
    }

    func query<M>(from modelType: M.Type,
                  where predicate: QueryPredicate?,
                  listener: GraphQLOperation<[M]>.EventListener?) -> GraphQLOperation<[M]> {
        fatalError("Not yet implemented")
    }

    func mutate<M>(of model: M,
                   type: GraphQLMutationType,
                   listener: GraphQLOperation<M>.EventListener?) -> GraphQLOperation<M> {
        fatalError("Not yet implemented")
    }

    func subscribe<M>(from modelType: M.Type,
                      type: GraphQLSubscriptionType,
                      listener: GraphQLSubscriptionOperation<M>.EventListener?) -> GraphQLSubscriptionOperation<M> {
        notify("subscribe(from:\(modelType),type:\(type),listener:)")

        let options = GraphQLOperationRequest<M>.Options()
        let request = GraphQLOperationRequest<M>(apiName: nil,
                                                 operationType: .subscription,
                                                 document: "",
                                                 variables: nil,
                                                 responseType: M.self,
                                                 options: options)
        let operation = MockSubscriptionGraphQLOperation(request: request, responseType: M.self)
        return operation
    }

    @available(iOS 13.0, *)
    func subscribe(modelType: Model.Type, mutationType: GraphQLMutationType) -> AnyPublisher<AnyModel, APIError> {
        notify("subscribe(modelType:\(modelType),mutationType:\(mutationType))")
        let error = APIError.invalidConfiguration("Mock method doesn't actually subscribe", "")
        return Fail<AnyModel, APIError>(error: error).eraseToAnyPublisher()
    }

    // MARK: - Request-based GraphQL methods

    func mutate<R>(request: GraphQLRequest<R>,
                   listener: GraphQLOperation<R>.EventListener?) -> GraphQLOperation<R> {

        notify("mutate")
        let options = GraphQLOperationRequest<R>.Options()
        let request = GraphQLOperationRequest<R>(apiName: request.apiName,
                                                 operationType: .mutation,
                                                 document: request.document,
                                                 variables: request.variables,
                                                 responseType: request.responseType,
                                                 options: options)
        let operation = MockGraphQLOperation(request: request, responseType: request.responseType)
        return operation
    }

    func query<R: Decodable>(request: GraphQLRequest<R>,
                             listener: GraphQLOperation<R>.EventListener?) -> GraphQLOperation<R> {

        notify("query")
        let options = GraphQLOperationRequest<R>.Options()
        let request = GraphQLOperationRequest<R>(apiName: request.apiName,
                                                 operationType: .query,
                                                 document: request.document,
                                                 variables: request.variables,
                                                 responseType: request.responseType,
                                                 options: options)
        let operation = MockGraphQLOperation(request: request, responseType: request.responseType)
        return operation
    }

    func subscribe<R: Decodable>(request: GraphQLRequest<R>,
                                 listener: GraphQLSubscriptionOperation<R>.EventListener?) ->
        GraphQLSubscriptionOperation<R> {
            notify("subscribe")
            let options = GraphQLOperationRequest<R>.Options()
            let request = GraphQLOperationRequest<R>(apiName: request.apiName,
                                                     operationType: .subscription,
                                                     document: request.document,
                                                     variables: request.variables,
                                                     responseType: request.responseType,
                                                     options: options)
            let operation = MockSubscriptionGraphQLOperation(request: request, responseType: request.responseType)
            return operation
    }

    // MARK: - REST methods

    func get(request: RESTRequest, listener: RESTOperation.EventListener?) -> RESTOperation {
        notify("get")
        let operationRequest = RESTOperationRequest(apiName: request.apiName,
                                           operationType: .get,
                                           path: request.path,
                                           queryParameters: request.queryParameters,
                                           body: request.body,
                                           options: RESTOperationRequest.Options())
        let operation = MockAPIOperation(request: operationRequest)
        return operation
    }

    func put(request: RESTRequest, listener: RESTOperation.EventListener?) -> RESTOperation {
        notify("put")
        let request = RESTOperationRequest(apiName: request.apiName,
                                           operationType: .put,
                                           path: request.path,
                                           queryParameters: request.queryParameters,
                                           body: request.body,
                                           options: RESTOperationRequest.Options())
        let operation = MockAPIOperation(request: request)
        return operation
    }

    func post(request: RESTRequest, listener: RESTOperation.EventListener?) -> RESTOperation {
        notify("post")
        let request = RESTOperationRequest(apiName: request.apiName,
                                           operationType: .post,
                                           path: request.path,
                                           queryParameters: request.queryParameters,
                                           body: request.body,
                                           options: RESTOperationRequest.Options())
        let operation = MockAPIOperation(request: request)
        return operation
    }

    func delete(request: RESTRequest, listener: RESTOperation.EventListener?) -> RESTOperation {
        notify("delete")
        let request = RESTOperationRequest(apiName: request.apiName,
                                           operationType: .delete,
                                           path: request.path,
                                           queryParameters: request.queryParameters,
                                           body: request.body,
                                           options: RESTOperationRequest.Options())
        let operation = MockAPIOperation(request: request)
        return operation
    }

    func patch(request: RESTRequest, listener: RESTOperation.EventListener?) -> RESTOperation {
        notify("patch")
        let request = RESTOperationRequest(apiName: request.apiName,
                                           operationType: .patch,
                                           path: request.path,
                                           queryParameters: request.queryParameters,
                                           body: request.body,
                                           options: RESTOperationRequest.Options())
        let operation = MockAPIOperation(request: request)
        return operation
    }

    func head(request: RESTRequest, listener: RESTOperation.EventListener?) -> RESTOperation {
        notify("head")
        let request = RESTOperationRequest(apiName: request.apiName,
                                           operationType: .head,
                                           path: request.path,
                                           queryParameters: request.queryParameters,
                                           body: request.body,
                                           options: RESTOperationRequest.Options())
        let operation = MockAPIOperation(request: request)
        return operation
    }

    func add(interceptor: URLRequestInterceptor, for apiName: String) {
        notify("addInterceptor")
    }
}

class MockSecondAPICategoryPlugin: MockAPICategoryPlugin {
    override var key: String {
        return "MockSecondAPICategoryPlugin"
    }
}

class MockGraphQLOperation<R: Decodable>: GraphQLOperation<R> {
    override func pause() {
    }

    override func resume() {
    }

    init(request: Request,
         responseType: R.Type) {
        super.init(categoryType: .api,
                   eventName: HubPayload.EventName.API.mutate,
                   request: request)
    }
}

class MockSubscriptionGraphQLOperation<R: Decodable>: GraphQLSubscriptionOperation<R> {

    override func pause() {
    }

    override func resume() {
    }

    init(request: Request,
         responseType: R.Type) {
        super.init(categoryType: .api,
                   eventName: HubPayload.EventName.API.subscribe,
                   request: request)
    }
}

class MockAPIOperation: AmplifyOperation<RESTOperationRequest, Void, Data, APIError>, RESTOperation {
    override func pause() {
    }

    override func resume() {
    }

    init(request: Request) {
        super.init(categoryType: .api,
                   eventName: request.operationType.hubEventName,
                   request: request)
    }
}
