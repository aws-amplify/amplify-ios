//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify

struct GraphQLResponseDecoder {

    static func decode<R: Decodable>(graphQLServiceResponse: AWSAppSyncGraphQLResponse,
                                     responseType: R.Type) throws -> GraphQLResponse<R> {

        switch (graphQLServiceResponse.data, graphQLServiceResponse.errors) {
        case (nil, nil):
            throw APIError.unknown("both cannot be nil", "service error")

        case (.some(let data), .none):
            let responseData = try decode(graphQLData: data, into: responseType)
            return GraphQLResponse<R>.success(responseData)

        case (.none, .some(let errors)):
            let responseErrors = try decodeErrors(graphQLErrors: errors)
            return GraphQLResponse<R>.error(responseErrors)

        case (.some(let data), .some(let errors)):
            let responseData = try decode(graphQLData: data, into: responseType)
            let responseErrors = try decodeErrors(graphQLErrors: errors)
            return GraphQLResponse<R>.partial(responseData, responseErrors)
        }
    }

    static func deserialize(graphQLResponse: Data) throws -> AWSAppSyncGraphQLResponse {
        let jsonObject = try deserializeObject(graphQLResponse: graphQLResponse)
        let errors = try getAPIErrors(from: jsonObject)
        let data = try getGraphQLData(from: jsonObject)

        return AWSAppSyncGraphQLResponse(data: data, errors: errors)
    }

    // MARK: - Private methods

    private static func deserializeObject(graphQLResponse: Data) throws -> [String: JSONValue] {
        let json: JSONValue

        do {
            json = try JSONDecoder().decode(JSONValue.self, from: graphQLResponse)
        } catch {
            throw APIError.operationError("Could not deserialize response data",
                                              "Service issue",
                                              error)
        }

        guard case .object(let jsonObject) = json else {
            throw APIError.unknown("Deserialized response data is not an object",
                                       "Service issue")
        }

        return jsonObject
    }

    private static func getAPIErrors(from jsonObject: [String: JSONValue]) throws -> [JSONValue]? {
        guard let errors = jsonObject["errors"] else {
            return nil
        }

        guard case .array(let errorArray) = errors else {
            throw APIError.unknown("Deserialized response error is not an array",
                                       "Service issue")
        }

        return errorArray
    }

    private static func getGraphQLData(from jsonObject: [String: JSONValue]) throws -> [String: JSONValue]? {
        guard let data = jsonObject["data"] else {
            return nil
        }

        guard case .object(let dataObject) = data else {
            throw APIError.unknown("Failed to case data object to dict",
                                       "Service issue")
        }

        return dataObject
    }

    private static func decode<R: Decodable>(graphQLData: [String: JSONValue],
                                             into responseType: R.Type) throws -> R {
        do {
            let serializedJSON = try JSONEncoder().encode(graphQLData)

            if responseType == String.self {
                guard let responseString = String(data: serializedJSON, encoding: .utf8) else {
                    throw APIError.operationError("could not get string from data", "", nil)
                }

                guard let response = responseString as? R else {
                    throw APIError.operationError("not of type R", "", nil)
                }

                return response
            }

            return try JSONDecoder().decode(responseType, from: serializedJSON)
        } catch let decodingError as DecodingError {
            throw APIError(error: decodingError)
        } catch {
            throw APIError.operationError("", "", error)
        }
    }

    private static func decodeErrors(graphQLErrors: [JSONValue]) throws -> [GraphQLError] {
        var responseErrors = [GraphQLError]()
        for error in graphQLErrors {
            do {
                let responseError = try decode(graphQLError: error)
                responseErrors.append(responseError)
            } catch let decodingError as DecodingError {
                throw APIError(error: decodingError)
            } catch {
                throw APIError.operationError("", "", error)
            }
        }

        return responseErrors
    }

    private static func decode(graphQLError: JSONValue) throws -> GraphQLError {
        do {
            let serializedJSON = try JSONEncoder().encode(graphQLError)
            return try JSONDecoder().decode(GraphQLError.self, from: serializedJSON)
        } catch let decodingError as DecodingError {
            throw APIError(error: decodingError)
        } catch {
            throw APIError.operationError("", "", error)
        }
    }
}
