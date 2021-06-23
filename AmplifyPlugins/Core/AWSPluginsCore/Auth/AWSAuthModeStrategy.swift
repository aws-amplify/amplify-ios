//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify

/// Represents different auth strategies supported by a client
/// interfacing with an AppSync backend
public enum AuthModeStrategyType {
    /// Default authorization type read from API configuration
    case `default`

    /// Uses schema metadata to create a prioritized list of potential authorization types
    /// that could be used for a request. The client iterates through that list until one of the
    /// avaialable types succecceds or all of them fail.
    case multiAuth

    /// Custom provided authorization strategy.
    case custom(AuthModeStrategy)
}

/// Methods for checking user current status
public protocol AuthModeStrategyDelegate: AnyObject {
    func isUserLoggedIn() -> Bool
}

/// Represents an authorization strategy used by DataStore
public protocol AuthModeStrategy: AnyObject {

    var authDelegate: AuthModeStrategyDelegate? { get set }

    init()

    func authTypesFor(schema: ModelSchema,
                      operation: ModelOperation) -> AWSAuthorizationTypeIterator
}

/// AuthorizationType iterator with an extra `count` property used
/// to predict the number of values
public protocol AuthorizationTypeIterator {
    associatedtype AuthorizationType

    init(withValues: [AuthorizationType])

    /// Total number of values
    var count: Int { get }

    /// Next available `AuthorizationType` or `nil` if exhausted
    mutating func next() -> AuthorizationType?
}

/// AuthorizationTypeIterator for values of type `AWSAuthorizationType`
public struct AWSAuthorizationTypeIterator: AuthorizationTypeIterator {
    public typealias AuthorizationType = AWSAuthorizationType

    private var values: IndexingIterator<[AWSAuthorizationType]>
    private var _count: Int

    public init(withValues values: [AWSAuthorizationType]) {
        self.values = values.makeIterator()
        self._count = values.count
    }

    public var count: Int {
        _count
    }

    public mutating func next() -> AWSAuthorizationType? {
        values.next()
    }
}

// MARK: - AWSDefaultAuthModeStrategy

public class AWSDefaultAuthModeStrategy: AuthModeStrategy {
    public weak var authDelegate: AuthModeStrategyDelegate?
    required public init() {}

    public func authTypesFor(schema: ModelSchema,
                             operation: ModelOperation) -> AWSAuthorizationTypeIterator {
        return AWSAuthorizationTypeIterator(withValues: [])
    }
}

// MARK: - AWSMultiAuthModeStrategy

/// Multi-auth strategy implementation based on schema metadata
public class AWSMultiAuthModeStrategy: AuthModeStrategy {
    public weak var authDelegate: AuthModeStrategyDelegate?

    private typealias AuthStrategyPriority = Int

    required public init() {}

    private static func defaultAuthTypeFor(authStrategy: AuthStrategy) -> AWSAuthorizationType {
        var defaultAuthType: AWSAuthorizationType
        switch authStrategy {
        case .owner:
            defaultAuthType = .amazonCognitoUserPools
        case .groups:
            defaultAuthType = .amazonCognitoUserPools
        case .private:
            defaultAuthType = .amazonCognitoUserPools
        case .public:
            defaultAuthType = .apiKey
        }
        return defaultAuthType
    }

    /// Given an auth rule, returns the corresponding AWSAuthorizationType
    /// - Parameter authRule: authorization rule
    /// - Returns: returns corresponding AWSAuthorizationType or a default
    private static func authTypeFor(authRule: AuthRule) -> AWSAuthorizationType {
        if let authProvider = authRule.provider {
            return authProvider.toAWSAuthorizationType()
        }

        return defaultAuthTypeFor(authStrategy: authRule.allow)
    }

    /// Given an auth rule strategy returns its corresponding priority
    /// - Parameter authStrategy: auth rule strategy
    /// - Returns: priority
    private static func priorityOf(authStrategy: AuthStrategy) -> AuthStrategyPriority {
        switch authStrategy {
        case .owner:
            return 0
        case .groups:
            return 1
        case .private:
            return 2
        case .public:
            return 3
        }
    }

    /// A predicate used to sort Auth rules according to above priority rules
    private static let comparator = { (rule1: AuthRule, rule2: AuthRule) -> Bool in
        priorityOf(authStrategy: rule1.allow) < priorityOf(authStrategy: rule2.allow)
    }

    
    /// Returns the proper authorization type for the provided schema according to a set of priority rules
    /// - Parameters:
    ///   - schema: model schema
    ///   - operation: model operation
    /// - Returns: an iterator for the applicable auth rules
    public func authTypesFor(schema: ModelSchema,
                             operation: ModelOperation) -> AWSAuthorizationTypeIterator {
        var applicableAuthRules = schema.authRules
            .filter(modelOperation: operation)
            .sorted(by: AWSMultiAuthModeStrategy.comparator)

        // if there isn't a user signed in, returns only public rules
        if let authDelegate = authDelegate, !authDelegate.isUserLoggedIn() {
            applicableAuthRules = applicableAuthRules.filter { rule in
                return rule.allow == .public
            }
        }
        return AWSAuthorizationTypeIterator(withValues: applicableAuthRules.map {
            AWSMultiAuthModeStrategy.authTypeFor(authRule: $0)
        })
    }
}
