//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify

protocol CoreMLNaturalLanguageBehavior {

    /// Detect dominant language using coreml
    ///
    /// Will return nil if CoreML couldnot be able to infer the language
    ///
    /// - Parameter text: Input text
    func detectDominantLanguage(for text: String) -> LanguageType?

    /// Detect syntax tokens
    ///
    /// - Parameter text: Input text
    func getSyntaxTokens(for text: String) -> [SyntaxToken]

    /// Get entities for the text
    ///
    /// - Parameter text: Input text
    func getEntities(for text: String) -> [EntityDetectionResult]

    /// Get the sentiment score of the given paragraph.
    ///
    /// The value maps the value given here `NLTagSchemeSentimentScore`
    ///
    /// - Parameter text: Input text
    func getSentinment(for text: String) -> Double
}
