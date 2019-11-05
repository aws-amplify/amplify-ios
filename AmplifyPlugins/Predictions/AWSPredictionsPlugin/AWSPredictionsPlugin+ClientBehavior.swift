//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CoreGraphics
import Amplify

extension AWSPredictionsPlugin {

    public func convert(textToTranslate: String,
                        language: LanguageType?,
                        targetLanguage: LanguageType?,
                        listener: ((AsyncEvent<Void, TranslateTextResult, PredictionsError>) -> Void)?,
                        options: PredictionsTranslateTextRequest.Options?) -> PredictionsTranslateTextOperation {
        // TODO: Default values come from configuration
        let request = PredictionsTranslateTextRequest(textToTranslate: textToTranslate,
                                                      targetLanguage: targetLanguage ?? .italian,
                                                      language: language ?? .english,
                                                      options: options ?? PredictionsTranslateTextRequest.Options())
        let convertOperation = AWSTranslateOperation(request,
                                                     translateService: translateService,
                                                     authService: authService,
                                                     listener: listener)
        queue.addOperation(convertOperation)
        return convertOperation
    }

    public func identify(type: IdentifyType,
                         image: CGImage,
                         options: PredictionsIdentifyRequest.Options,
                         listener: PredictionsIdentifyOperation.EventListener? = nil) -> PredictionsIdentifyOperation {
        let options = options

        let request = PredictionsIdentifyRequest(image: image, identifyType: type, options: options)
        let operation = AWSRekognitionOperation(
            request, rekognitionService: rekognitionService,
            authService: authService,
            listener: listener)

        queue.addOperation(operation)
        return operation

    }
}
