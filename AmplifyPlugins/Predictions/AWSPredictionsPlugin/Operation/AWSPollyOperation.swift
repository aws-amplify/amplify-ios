//
//  AWSTextToSpeechOperation.swift
//  AWSPredictionsPlugin
//
//  Created by Stone, Nicki on 11/14/19.
//  Copyright © 2019 Amazon Web Services. All rights reserved.
//

import Foundation
import Amplify
import AWSPluginsCore

public class AWSPollyOperation: AmplifyOperation<PredictionsTextToSpeechRequest,
    Void, TextToSpeechResult, PredictionsError>,
PredictionsTextToSpeechOperation {

    let predictionsService: AWSPredictionsService
    let authService: AWSAuthServiceBehavior

    init(_ request: PredictionsTextToSpeechRequest,
         predictionsService: AWSPredictionsService,
         authService: AWSAuthServiceBehavior,
         listener: EventListener?) {
        self.predictionsService = predictionsService
        self.authService = authService
        super.init(categoryType: .predictions,
                   eventName: HubPayload.EventName.Predictions.textToSpeech,
                   request: request,
                   listener: listener)
    }

    override public func cancel() {
        super.cancel()
    }

    override public func main() {
        if isCancelled {
            finish()
            return
        }

        if let error = request.validate() {
            dispatch(event: .failed(error))
            finish()
            return
        }

        predictionsService.synthesizeText(text: request.textToSpeech,
                                          voiceId: request.options.voiceType) { [weak self] event in
            self?.onServiceEvent(event: event)
        }

    }

    private func onServiceEvent(event: PredictionsEvent<TextToSpeechResult, PredictionsError>) {
        switch event {
        case .completed(let result):
            dispatch(event: .completed(result))
            finish()
        case .failed(let error):
            dispatch(event: .failed(error))
            finish()

        }
    }

}
