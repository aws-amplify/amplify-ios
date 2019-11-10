//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CoreGraphics

/// Behavior of the Predictions category that clients will use
public protocol PredictionsCategoryClientBehavior {

    //TOOD: Update the api names after final review

    /// Translate the text to the language specified.
    /// - Parameter textToTranslate: The text to translate
    /// - Parameter language: The language of the text given
    /// - Parameter targetLanguage: The language to which the text should be translated
    /// - Parameter listener: Triggered when the event occurs
    /// - Parameter options: Parameters to specific plugin behavior
    func convert(textToTranslate: String,
                 language: LanguageType?,
                 targetLanguage: LanguageType?,
                 listener: PredictionsTranslateTextOperation.EventListener?,
                 options: PredictionsTranslateTextRequest.Options?) -> PredictionsTranslateTextOperation

    /// Translate the text to the language specified.
    /// - Parameter type: The type of image detection you want to perform
    /// - Parameter image: The image you are sending
    /// - Parameter options: Parameters to specific plugin behavior
    /// - Parameter listener: Triggered when the event occurs
    func identify(type: IdentifyType,
                  image: CGImage,
                  options: PredictionsIdentifyRequest.Options?,
                  listener: PredictionsIdentifyOperation.EventListener?) -> PredictionsIdentifyOperation

    /// Interpret the text and return  sentiment analysis, entity detection, language detection,
    /// syntax detection, key phrases detection
    /// - Parameter text: Text to interpret
    /// - Parameter options:Parameters to specific plugin behavior
    /// - Parameter options:Parameters to specific plugin behavior
    func interpret(text: String,
                   options: PredictionsInterpretRequest.Options?,
                   listener: PredictionsInterpretOperation.EventListener?) -> PredictionsInterpretOperation
}











