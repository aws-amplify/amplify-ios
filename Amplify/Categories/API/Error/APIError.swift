//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Errors specific to the API Category
public enum APIError {

    public typealias UserInfo = [String: Any]
    public typealias StatusCode = Int

    /// An unknown error
    case unknown(ErrorDescription, RecoverySuggestion, Error? = nil)

    /// The configuration for a particular API was invalid
    case invalidConfiguration(ErrorDescription, RecoverySuggestion, Error? = nil)

    /// The URL in a request was invalid or missing
    case invalidURL(ErrorDescription, RecoverySuggestion, Error? = nil)

    /// An in-process operation encountered a processing error
    case operationError(ErrorDescription, RecoverySuggestion, Error? = nil)

    /// The category received an underlying error from network layer.
    case networkError(ErrorDescription, UserInfo? = nil, Error? = nil)

    /// A non 2xx response from the service.
    case httpStatusError(StatusCode, HTTPURLResponse)

    /// An error to encapsulate an error received by a dependent plugin
    case pluginError(AmplifyError)

}

extension APIError: AmplifyError {
    public var errorDescription: ErrorDescription {
        switch self {
        case .unknown(let errorDescription, _, _):
            return "Unexpected error occurred with message: \(errorDescription)"

        case .invalidConfiguration(let errorDescription, _, _):
            return errorDescription

        case .invalidURL(let errorDescription, _, _):
            return errorDescription

        case .operationError(let errorDescription, _, _):
            return errorDescription

        case .networkError(let errorDescription, _, _):
            return errorDescription

        case .httpStatusError(let statusCode, _):
            return "The HTTP response status code is [\(statusCode)]."

        case .pluginError(let error):
            return error.errorDescription
        }
    }

    public var recoverySuggestion: RecoverySuggestion {
        switch self {
        case .unknown(_, let recoverySuggestion, _):
            return """
            \(recoverySuggestion)

            This should never happen. There is a possibility that there is a bug if this error persists.
            Please take a look at https://github.com/aws-amplify/amplify-ios/issues to see if there are any
            existing issues that match your scenario, and file an issue with the details of the bug if there isn't.
            """

        case .invalidConfiguration(_, let recoverySuggestion, _):
            return recoverySuggestion

        case .invalidURL(_, let recoverySuggestion, _):
            return recoverySuggestion

        case .operationError(_, let recoverySuggestion, _):
            return recoverySuggestion

        case .networkError(let errorDescription, _, _):
            return errorDescription

        case .httpStatusError:
            return """
            The metadata associated with the response is contained in the HTTPURLResponse.
            For more information on HTTP status codes, take a look at
            https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
            """
        case .pluginError(let error):
            return error.recoverySuggestion
        }
    }

    public var underlyingError: Error? {
        switch self {
        case .unknown(_, _, let error):
            return error
        case .invalidConfiguration(_, _, let error):
            return error
        case .invalidURL(_, _, let error):
            return error
        case .operationError(_, _, let error):
            return error
        case .networkError(_, _, let error):
            return error
        case .httpStatusError:
            return nil
        case .pluginError(let error):
            return error
        }
    }
}
