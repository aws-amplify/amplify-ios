//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify

extension QueryPredicate {
    var graphQLFilterVariables: [String: Any] {
        if let operation = self as? QueryPredicateOperation {
            return operation.graphQLFilterOperation
        } else if let group = self as? QueryPredicateGroup {
            return group.graphQLFilterGroup
        }

        preconditionFailure(
            "Could not find QueryPredicateOperation or QueryPredicateGroup for \(String(describing: self))")
    }

    func graphQLFilterVariablesString() throws -> String {
        let graphQLFilterVariablesData = try JSONSerialization.data(withJSONObject: graphQLFilterVariables,
                                                                    options: .prettyPrinted)

        guard let serializedString = String(data: graphQLFilterVariablesData, encoding: .utf8) else {
            preconditionFailure("""
            Could not initialize String from graphQLFilterVariables: \(String(describing: graphQLFilterVariablesData))
            """)
        }

        return serializedString
    }
}

extension QueryPredicateOperation {
    var graphQLFilterOperation: [String: Any] {
        return [self.field: [self.operator.graphQLOperator: self.operator.value]]
    }
}

extension QueryPredicateGroup {
    var graphQLFilterGroup: [String: Any] {
        switch type {
        case .and, .or:
            var graphQLPredicateOperation = [self.type.rawValue: [Any]()]
            predicates.forEach { predicate in
                graphQLPredicateOperation[self.type.rawValue]?.append(predicate.graphQLFilterVariables)
            }
            return graphQLPredicateOperation
        case .not:
            if let predicate = self.predicates.first {
                return [self.type.rawValue: predicate.graphQLFilterVariables]
            } else {
                preconditionFailure("Missing predicate for \(String(describing: self)) with type: \(type)")
            }
        }
    }
}
extension QueryOperator {
    var graphQLOperator: String {
        switch self {
        case .notEqual:
            return "ne"
        case .equals:
            return "eq"
        case .lessOrEqual:
            return "le"
        case .lessThan:
            return "lt"
        case .greaterOrEqual:
            return "ge"
        case .greaterThan:
            return "gt"
        case .contains:
            return "contains"
        case .between:
            return "between"
        case .beginsWith:
            return "beginsWith"
        }
    }

    var value: Any? {
        switch self {
        case .notEqual(let value),
             .equals(let value):
            if let value = value {
                return value.graphQLValue()
            }

            return nil
        case .lessOrEqual(let value),
             .lessThan(let value),
             .greaterOrEqual(let value),
             .greaterThan(let value):
            return value.graphQLValue()
        case .contains(let value):
            return value
        case .between(let start, let end):
            return [start.graphQLValue(), end.graphQLValue()]
        case .beginsWith(let value):
            return value
        }
    }
}

extension Persistable {
    internal func graphQLValue() -> Any {
        let value = self

        if let value = value as? Bool {
            return value
        }

        if let value = value as? Date {
            return value.iso8601
        }

        if let value = value as? Double {
            return Decimal(value)
        }

        if let value = value as? Int {
            return value
        }

        if let value = value as? String {
            return value
        }

        preconditionFailure("""
        Value \(String(describing: value)) of type \(String(describing: type(of: value)))
        is not a compatible type.
        """)
    }
}
