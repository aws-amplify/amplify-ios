//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSTranslate
import Amplify

typealias AWSTranslateErrorMessageString = (errorDescription: ErrorDescription, recoverySuggestion: RecoverySuggestion)

struct AWSTranslateErrorMessage {
    static let accessDenied: AWSTranslateErrorMessageString = (
        "Access denied! You do not have sufficient access to perform this action.",
        "Please check that your Cognito IAM role has permissions to access Translate.")

    static let detectedLanguageLowConfidence: AWSTranslateErrorMessageString = (
        "A language was detected but with very low confidence",
        "Please make sure you sent in one of the available languages for Translate")

    static let internalServerError: AWSTranslateErrorMessageString = (
        "An internal server error occurred",
        """
        Please take a look at https://github.com/aws-amplify/amplify-ios/issues to see if there are any
        existing issues that match your scenario, and file an issue with the details of the bug if there isn't.
        """)

    static let invalidParameterValue: AWSTranslateErrorMessageString = (
        "An invalid or out-of-range value was supplied for the input parameter.",
        "Please check your request and try again.")

    static let invalidRequest: AWSTranslateErrorMessageString = (
        "An invalid request was sent.",
        "Please check your request and try again.")

    static let limitExceeded: AWSTranslateErrorMessageString = (
        "The number of requests made has exceeded the limit.",
        "Please decrease the number of requests and try again.")

    static let resourceNotFound: AWSTranslateErrorMessageString = (
        "Your resource was not found.",
        "Please make sure you either created the resource using the Amplify CLI or the AWS Console")

    static let serviceUnavailable: AWSTranslateErrorMessageString = (
        "The service is currently unavailable.",
        "Please check to see if there is an outage at https://status.aws.amazon.com/ and reach out to AWS support.")

    static let textSizeLimitExceeded: AWSTranslateErrorMessageString = (
        "The size of the text string exceeded the limit. The limit is the first 256 terms in a string of text.",
        "Please send a shorter text string.")
    
    static let tooManyRequests: AWSTranslateErrorMessageString = (
        """
        Too many requests made, the limit of requests was exceeded. Please check the limits here https://docs.aws.amazon.com/general/latest/gr/aws_service_limits.html#limits_amazon_translate
        """,
        "Please decrease the number of requests and try again.")
    
    static let unsupportedLanguagePair: AWSTranslateErrorMessageString = (
        "Your target language and source language are an unsupported language pair.",
        "Please refer to this table to see supported language pairs https://docs.aws.amazon.com/translate/latest/dg/what-is.html.")

    // swiftlint:disable cyclomatic_complexity
    static func map(_ errorType: AWSTranslateErrorType) -> PredictionsError? {
        switch errorType {
        case .detectedLanguageLowConfidence:
            return PredictionsError.serviceError(
                detectedLanguageLowConfidence.errorDescription,
                detectedLanguageLowConfidence.recoverySuggestion)
        case .internalServer:
            return PredictionsError.serviceError(
                internalServerError.errorDescription,
                internalServerError.recoverySuggestion)
        case .invalidParameterValue:
            return PredictionsError.serviceError(
                invalidParameterValue.errorDescription,
                invalidParameterValue.recoverySuggestion)
        case .invalidRequest:
            return PredictionsError.serviceError(
                invalidRequest.errorDescription,
                invalidRequest.recoverySuggestion)
        case .limitExceeded:
            return PredictionsError.serviceError(
                limitExceeded.errorDescription,
                limitExceeded.recoverySuggestion)
        case .resourceNotFound:
            return PredictionsError.serviceError(
                resourceNotFound.errorDescription,
                resourceNotFound.recoverySuggestion)
        case .serviceUnavailable:
            return PredictionsError.serviceError(
                serviceUnavailable.errorDescription,
                serviceUnavailable.recoverySuggestion)
        case .textSizeLimitExceeded:
            return PredictionsError.serviceError(
            textSizeLimitExceeded.errorDescription,
            textSizeLimitExceeded.recoverySuggestion)
        case .tooManyRequests:
            return PredictionsError.serviceError(
            tooManyRequests.errorDescription,
            tooManyRequests.recoverySuggestion)
        case .unknown:
            return PredictionsError.unknownError("An unknown error occurred.", "")
        case .unsupportedLanguagePair:
            return PredictionsError.serviceError(
            unsupportedLanguagePair.errorDescription,
            unsupportedLanguagePair.recoverySuggestion)
        default:
            return nil
        }
    }
}
