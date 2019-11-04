//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import CoreImage
import Foundation

class MockPredictionsCategoryPlugin: MessageReporter, PredictionsCategoryPlugin {

    func configure(using configuration: Any) throws {
        notify()
    }

    func convert(textToTranslate: String,
                 language: LanguageType?,
                 targetLanguage: LanguageType?,
                 listener: PredictionsTranslateTextOperation.EventListener?,
                 options: PredictionsTranslateTextRequest.Options?) -> PredictionsTranslateTextOperation {
        notify("textToTranslate")
        let request = PredictionsTranslateTextRequest(textToTranslate: textToTranslate,
                                                      targetLanguage: targetLanguage ?? .italian,
                                                      language: language ?? .english,
                                                      options: options ?? PredictionsTranslateTextRequest.Options())
        return MockPredictionsTranslateTextOperation(request: request)

    }

    func reset(onComplete: @escaping BasicClosure) {
        notify("reset")
        onComplete()
    }

    var key: String {
        return "MockPredictionsCategoryPlugin"
    }
}

class MockSecondPredictionsCategoryPlugin: MockPredictionsCategoryPlugin {
    override var key: String {
        return "MockSecondPredictionsCategoryPlugin"
    }
}

class MockPredictionsTranslateTextOperation: AmplifyOperation<PredictionsTranslateTextRequest,
Void,
TranslateTextResult,
PredictionsError>, PredictionsTranslateTextOperation {

    override func pause() {
    }

    override func resume() {
    }

    init(request: Request) {
        super.init(categoryType: .predictions,
                   eventName: HubPayload.EventName.Predictions.translate,
                   request: request)
    }

}
