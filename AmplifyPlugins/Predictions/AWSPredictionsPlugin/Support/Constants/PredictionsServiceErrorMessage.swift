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

    static let noLaungageFound: PredictionsServiceErrorString = (
        "No result was found for language. An unknown error occurred.",
        "Please try with different input")
}
