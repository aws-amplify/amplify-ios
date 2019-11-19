//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

extension APICategory: APICategoryGraphQLBehavior {

    public func query<M: Model>(from modelType: M.Type,
                                byId id: String,
                                listener: GraphQLOperation<M?>.EventListener?) -> GraphQLOperation<M?> {
        plugin.query(from: modelType, byId: id, listener: listener)
    }

    public func query<M: Model>(from modelType: M.Type,
                                where predicate: QueryPredicate?,
                                listener: GraphQLOperation<[M]>.EventListener?) -> GraphQLOperation<[M]> {
        plugin.query(from: modelType, where: predicate, listener: listener)
    }

    public func mutate<M: Model>(of model: M,
                                 type: GraphQLMutationType,
                                 listener: GraphQLOperation<M>.EventListener?) -> GraphQLOperation<M> {
        plugin.mutate(of: model, type: type, listener: listener)
    }

    public func subscribe<M: Model>(from modelType: M.Type,
                                    type: GraphQLSubscriptionType,
                                    listener: GraphQLSubscriptionOperation<M>.EventListener?) -> GraphQLSubscriptionOperation<M> {
        plugin.subscribe(from: modelType, type: type, listener: listener)
    }

    public func query<R: Decodable>(request: GraphQLRequest<R>,
                                    listener: GraphQLOperation<R>.EventListener?) -> GraphQLOperation<R> {
        plugin.query(request: request, listener: listener)
    }

    public func mutate<R: Decodable>(request: GraphQLRequest<R>,
                                     listener: GraphQLOperation<R>.EventListener?) -> GraphQLOperation<R> {
        plugin.mutate(request: request, listener: listener)
    }

    public func subscribe<R>(request: GraphQLRequest<R>,
                             listener: GraphQLSubscriptionOperation<R>.EventListener?) -> GraphQLSubscriptionOperation<R> {
        plugin.subscribe(request: request, listener: listener)
    }
}
