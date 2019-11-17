//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSRekognition
import Amplify

typealias AWSRekognitionErrorMessageString = (
    errorDescription: ErrorDescription,
    recoverySuggestion: RecoverySuggestion)

struct AWSRekognitionErrorMessage {
    static let accessDenied: AWSRekognitionErrorMessageString = (
        "Access denied!",
        "Please check that your Cognito IAM role has permissions to access Rekognition.")

    static let idempotentParameterMismatch: AWSRekognitionErrorMessageString = (
        """
        A ClientRequestToken input parameter was reused with an operation,
        but at least one of the other input parameters is different from
        the previous call to the operation.
        """,
        """
        This shouldn't happen. Please make sure your requests are sending correctly
        and if still no luck, please submit a github issue here
        https://github.com/aws-amplify/amplify-ios/issues.
        """)

    static let imageTooLarge: AWSRekognitionErrorMessageString = (
        "The image you sent was too large.",
        "Try downsizing the image and sending it again.")

    static let invalidImageFormat: AWSRekognitionErrorMessageString = (
        "The provided image format isn't supported.",
        "Use a supported image format (.JPEG and .PNG) and try again.")
    
    static let invalidPaginationToken: AWSRekognitionErrorMessageString = (
        "The pagination token in the request isn't valid. The token might have expired.",
        "Please try your request again.")
    
    static let invalidParameter: AWSRekognitionErrorMessageString = (
        "An input parameter violated a constraint.",
        "Validate your parameters before calling the API operation again.")
    
    static let limitExceeded: AWSRekognitionErrorMessageString = (
        "The request exceeded the service limits.",
        """
        Decrease the number of calls you are making or make sure your request is below the service limits for your region.
        Check the limits here:
        https://docs.aws.amazon.com/general/latest/gr/aws_service_limits.html#limits_rekognition
        """)
    
    static let provisionedThroughputExceeded: AWSRekognitionErrorMessageString = (
        "The number of requests exceeded your throughput limit.",
        """
        Decrease the number of calls you are making until it is below the limit for your region.
        Check the limits here:
        https://docs.aws.amazon.com/general/latest/gr/aws_service_limits.html#limits_rekognition
        """)
    
    static let resourceAlreadyExists: AWSRekognitionErrorMessageString = (
        "A collection with the specified ID already exists.",
        "Please create a new collection")
    
    static let resourceInUse: AWSRekognitionErrorMessageString = (
        "The resource is already in use.",
        "Retry when the resource is available.")
    
    static let resourceNotFound: AWSRekognitionErrorMessageString = (
        "The specified resource doesn't exist.",
        "Please make sure you have added the ability to identify things through the CLI or the AWS console.")
    
    static let throttling: AWSRekognitionErrorMessageString = (
        "Your rate of request increase is too fast.",
        "Slow down your request rate and gradually increase it.")

    // swiftlint:disable cyclomatic_complexity
    static func map(_ errorType: AWSRekognitionErrorType) -> PredictionsError? {
        switch errorType {
        case .accessDenied:
            return PredictionsError.accessDenied(
                accessDenied.errorDescription,
                accessDenied.recoverySuggestion)
        case .idempotentParameterMismatch:
            return PredictionsError.accessDenied(
            idempotentParameterMismatch.errorDescription,
            idempotentParameterMismatch.recoverySuggestion)
        case .imageTooLarge:
            return PredictionsError.accessDenied(
            imageTooLarge.errorDescription,
            imageTooLarge.recoverySuggestion)
        case .internalServer:
            return PredictionsError.internalServiceError("", "")
        case .invalidImageFormat:
            return PredictionsError.accessDenied(
            invalidImageFormat.errorDescription,
            invalidImageFormat.recoverySuggestion)
        case .invalidPaginationToken:
            return PredictionsError.accessDenied(
            invalidPaginationToken.errorDescription,
            invalidPaginationToken.recoverySuggestion)
        case .invalidParameter:
             return PredictionsError.accessDenied(
            invalidParameter.errorDescription,
            invalidParameter.recoverySuggestion)
        case .limitExceeded:
            return PredictionsError.accessDenied(
            limitExceeded.errorDescription,
            limitExceeded.recoverySuggestion)
        case .provisionedThroughputExceeded:
            return PredictionsError.accessDenied(
            provisionedThroughputExceeded.errorDescription,
            provisionedThroughputExceeded.recoverySuggestion)
        case .resourceAlreadyExists:
            return PredictionsError.accessDenied(
            resourceAlreadyExists.errorDescription,
            resourceAlreadyExists.recoverySuggestion)
        case .resourceInUse:
             return PredictionsError.accessDenied(
            resourceInUse.errorDescription,
            resourceInUse.recoverySuggestion)
        case .resourceNotFound:
            return PredictionsError.accessDenied(
            resourceNotFound.errorDescription,
            resourceNotFound.recoverySuggestion)
        case .throttling:
            return PredictionsError.accessDenied(
            throttling.errorDescription,
            throttling.recoverySuggestion)
        case .unknown:
            return PredictionsError.unknownError("An unknown error occurred.", "")
        case .videoTooLarge:
            return PredictionsError.accessDenied(
            limitExceeded.errorDescription,
            limitExceeded.recoverySuggestion)
        default:
            return nil
        }
    }
}
