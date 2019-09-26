//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Convenience typealias defining a closure that can be used to filter Hub messages
public typealias HubFilter = (HubPayload) -> Bool

/// Convenience filters for common filtering use cases
public struct HubFilters {

    /// Always true
    public static func always() -> HubFilter {
        let filter: HubFilter = { _ in
            return true
        }
        return filter
    }

    /// True if all filters evaluate to true
    public static func all(filters: HubFilter...) -> HubFilter {
        let filter: HubFilter = { payload -> Bool in
            return filters.allSatisfy { $0(payload) }
        }
        return filter
    }

    /// True if both `lhs` or `rhs` evaluates to true
    public static func and(lhs: @escaping HubFilter, rhs: @escaping HubFilter) -> HubFilter {
        let filter: HubFilter = { payload -> Bool in
            return lhs(payload) && rhs(payload)
        }
        return filter
    }

    /// True if any of the filters evaluate to true
    public static func any(filters: HubFilter...) -> HubFilter {
        let filter: HubFilter = { payload -> Bool in
            let firstIndex = filters.firstIndex { $0(payload) }
            return firstIndex != nil
        }
        return filter
    }

    /// True if either `lhs` or `rhs` evaluates to true
    public static func or(lhs: @escaping HubFilter, rhs: @escaping HubFilter) -> HubFilter {
        let filter: HubFilter = { payload -> Bool in
            return lhs(payload) || rhs(payload)
        }
        return filter
    }

    /// Returns a HubFilter that is `true` if the event's `context` property has a UUID that matches `operation.id`
    /// - Parameter operation: The operation to match
    public static func hubFilter<Request: AmplifyOperationRequest, InProcess, Complete, Error: AmplifyError>
        (forOperation operation: AmplifyOperation<Request, InProcess, Complete, Error>) -> HubFilter {
        let operationId = operation.id
        let filter: HubFilter = { payload in
            guard let context = payload.context as? AmplifyOperationContext<Request> else {
                return false
            }

            return context.operationId == operationId
        }

        return filter
    }
}
