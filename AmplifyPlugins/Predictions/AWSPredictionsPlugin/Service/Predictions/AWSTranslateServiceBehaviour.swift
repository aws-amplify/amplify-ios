//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSTranslate

protocol AWSTranslateServiceBehaviour {

    typealias TranslateTextServiceEventHandler = (TranslateTextServiceEvent) -> Void
    typealias TranslateTextServiceEvent = PredictionsEvent<TranslateTextResult, PredictionsError>

    func translateText(text: String,
                       language: LanguageType,
                       targetLanguage: LanguageType,
                       onEvent: @escaping TranslateTextServiceEventHandler)
}
