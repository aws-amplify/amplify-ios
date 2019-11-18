//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify

typealias PredictionsServiceErrorString = (errorDescription: ErrorDescription, recoverySuggestion: RecoverySuggestion)

struct PredictionsServiceErrorMessage {
    static let accessDenied: PredictionsServiceErrorString = (
        "Access denied!",
        "")

    static let noLanguageFound: PredictionsServiceErrorString = (
        "No result was found for language. An unknown error occurred.",
        "Please try with different input")

    static let dominantLanguageNotDetermined: PredictionsServiceErrorString = (
        "Could not determine the predominant language in the text",
        "Please try with different input")

    static let onlineInterpretServiceNotAvailable: PredictionsServiceErrorString = (
        "Online interpret service is not available",
        "Please check if the values are proprely initialized")

    static let offlineInterpretServiceNotAvailable: PredictionsServiceErrorString = (
        "Offline interpret service is not available",
        "Please check if the values are proprely initialized")

    static let noResultInterpretService: PredictionsServiceErrorString = (
        "Not able to fetch result for interpret text operation",
        "Please try with a different input")

    static let textNotFoundToInterpret: PredictionsServiceErrorString = (
    "Input text is nil",
    "Text given for interpret could not be found. Please check the input")
}
