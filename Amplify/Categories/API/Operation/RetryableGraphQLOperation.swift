//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation


/// Convenience protocol to handle any kind of GraphQLOperation
public protocol AnyGraphQLOperation {
    associatedtype Success
    associatedtype Failure: Error
    typealias ResultListener = (Result<Success, Failure>) -> Void
}

/// Abastraction for a retryable GraphQLOperation.
public protocol RetryableGraphQLOperationBehavior: Operation, DefaultLogger {
    associatedtype Payload: Decodable

    /// GraphQLOperation concrete type
    associatedtype OperationType: AnyGraphQLOperation

    typealias RequestFactory = () -> GraphQLRequest<Payload>
    typealias OperationFactory = (GraphQLRequest<Payload>, @escaping OperationResultListener) -> OperationType
    typealias OperationResultListener = OperationType.ResultListener

    /// Operation unique identifier
    var id: UUID { get }

    /// Number of attempts (min 1)
    var attempts: Int { get set }

    /// Underlying GraphQL operation instantiated by `operationFactory`
    var underlyingOperation: OperationType? { get set }

    /// Maximum number of allowed retries
    var maxRetries: Int { get }

    /// GraphQLRequest factory, invoked to create a new operation
    var requestFactory: RequestFactory { get }

    /// GraphQL operation factory, invoked with a newly created GraphQL request
    /// and a wrapped result listener.
    var operationFactory: OperationFactory { get }

    var resultListener: OperationResultListener { get }

    init(requestFactory: @escaping RequestFactory,
         maxRetries: Int,
         resultListener: @escaping OperationResultListener,
         _ operationFactory: @escaping OperationFactory)

    func start(request: GraphQLRequest<Payload>)
    
    func shouldRetry(error: APIError?) -> Bool
}

// MARK: RetryableGraphQLOperationBehavior + default implementation
extension RetryableGraphQLOperationBehavior {
    public func start(request: GraphQLRequest<Payload>) {
        attempts += 1
        log.debug("[\(id)] - Try [\(attempts)/\(maxRetries)]")
        let wrappedResultListener: OperationResultListener = { result in
            if case let .failure(error) = result, self.shouldRetry(error: error as? APIError) {
                self.log.debug("\(error)")
                self.start(request: self.requestFactory())
                return
            }

            if case let .failure(error) = result {
                self.log.debug("\(error)")
                self.log.debug("[\(self.id)] - Failed")
            }

            if case .success = result {
                self.log.debug("[Operation \(self.id)] - Success")
            }
            self.resultListener(result)
        }
        underlyingOperation = operationFactory(request, wrappedResultListener)
    }
}

// MARK: - RetryableGraphQLOperation
public final class RetryableGraphQLOperation<Payload: Decodable>: Operation, RetryableGraphQLOperationBehavior {
    public typealias Payload = Payload
    public typealias OperationType = GraphQLOperation<Payload>

    public var id: UUID
    public var maxRetries: Int
    public var attempts: Int = 0
    public var requestFactory: RequestFactory
    public var underlyingOperation: GraphQLOperation<Payload>?
    public var resultListener: OperationResultListener
    public var operationFactory: OperationFactory

    public init(requestFactory: @escaping () -> GraphQLRequest<Payload>,
                maxRetries: Int,
                resultListener: @escaping OperationResultListener,
                _ operationFactory: @escaping OperationFactory) {
        self.id = UUID()
        self.maxRetries = max(1, maxRetries)
        self.requestFactory = requestFactory
        self.operationFactory = operationFactory
        self.resultListener = resultListener
    }
    public override func main() {
        start(request: requestFactory())
    }

    public override func cancel() {
        underlyingOperation?.cancel()
    }
    
    public func shouldRetry(error: APIError?) -> Bool {
        guard case let .operationError(_, _, underlyingError) = error,
              let authError = underlyingError as? AuthError,
              case .signedOut = authError else {
                  return false
              }
        return self.attempts < self.maxRetries
    }
}

// MARK: - RetryableGraphQLSubscriptionOperation
public final class RetryableGraphQLSubscriptionOperation<Payload: Decodable>: Operation, RetryableGraphQLOperationBehavior {
    public typealias OperationType = GraphQLSubscriptionOperation<Payload>

    public typealias Payload = Payload

    public var id: UUID
    public var maxRetries: Int
    public var attempts: Int = 0
    public var underlyingOperation: GraphQLSubscriptionOperation<Payload>?
    public var requestFactory: RequestFactory
    public var resultListener: OperationResultListener
    public var operationFactory: OperationFactory

    public init(requestFactory: @escaping RequestFactory,
                maxRetries: Int,
                resultListener: @escaping OperationResultListener,
                _ operationFactory: @escaping OperationFactory) {
        self.id = UUID()
        self.maxRetries = max(1, maxRetries)
        self.requestFactory = requestFactory
        self.operationFactory = operationFactory
        self.resultListener = resultListener
    }
    public override func main() {
        start(request: requestFactory())
    }

    public override func cancel() {
        underlyingOperation?.cancel()
    }
    
    public func shouldRetry(error: APIError?) -> Bool {
        return self.attempts < self.maxRetries
    }

}


// MARK: GraphQLOperation - GraphQLSubscriptionOperation + AnyGraphQLOperation
extension GraphQLOperation: AnyGraphQLOperation {}
extension GraphQLSubscriptionOperation: AnyGraphQLOperation {}
