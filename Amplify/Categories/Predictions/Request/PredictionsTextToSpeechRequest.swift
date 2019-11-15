//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct PredictionsTextToSpeechRequest: AmplifyOperationRequest, PredictionsConvertRequest {

    /// The text to synthesize to speech
    public let textToSpeech: String

    /// Options to adjust the behavior of this request, including plugin options
    public let options: Options

    public init(textToSpeech: String,
                options: Options) {
        self.textToSpeech = textToSpeech
        self.options = options
    }
}

public extension PredictionsTextToSpeechRequest {

    struct Options {

        /// The calltype for the operation. The default value will be `auto`.
        public let callType: CallType
        
        
        ///the voice they would like to use for the audio file
        public let voiceType: VoiceType

        /// Extra plugin specific options, only used in special circumstances when the existing options do not provide
        /// a way to utilize the underlying storage system's functionality. See plugin documentation for expected
        /// key/values
        public let pluginOptions: Any?

        public init(callType: CallType = .auto,
                    voiceType: VoiceType = .englishFemaleIvy,
                    pluginOptions: Any? = nil) {
            self.callType = callType
            self.voiceType = voiceType
            self.pluginOptions = pluginOptions
        }
    }
}
