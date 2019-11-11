//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum AuthError {
    case identity(ErrorName, ErrorDescription, RecoverySuggestion, Error? = nil)
    case unknown(ErrorDescription, Error? = nil)
}

extension AuthError: AmplifyError {
    public var errorDescription: ErrorDescription {
        switch self {
        case .identity(let errorName, let errorDescription, _, _):
            return "Could not get IdentityId due to [\(errorName)] with message: \(errorDescription)"
        case .unknown(let errorDescription, _):
            return "Unexpected error occurred with message: \(errorDescription)"
        }
    }

    public var recoverySuggestion: RecoverySuggestion {
        switch self {
        case .identity(_, _, let recoverySuggestion, _):
            return recoverySuggestion
        case .unknown:
            return """
            This should never happen. There is a possibility that there is a bug if this error persists.
            Please take a look at https://github.com/aws-amplify/amplify-ios/issues to see if there are any
            existing issues that match your scenario, and file an issue with the details of the bug if there isn't.
            """
        }
    }

    public var underlyingError: Error? {
        switch self {
        case .identity(_, _, _, let underlyingError),
             .unknown(_, let underlyingError):
            return underlyingError
        }
    }
}
