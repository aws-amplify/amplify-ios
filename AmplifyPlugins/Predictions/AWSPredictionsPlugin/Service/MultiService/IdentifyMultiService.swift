//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify

class IdentifyMultiService: MultiServiceBehavior {

    typealias Event = PredictionsEvent<IdentifyResult, PredictionsError>
    typealias IdentifyEventHandler = (Event) -> Void

    weak var coreMLService: CoreMLPredictionBehavior?
    weak var predictionsService: AWSPredictionsService?
    var request: PredictionsIdentifyRequest!

    init(coreMLService: CoreMLPredictionBehavior?,
         predictionsService: AWSPredictionsService?) {
        self.coreMLService = coreMLService
        self.predictionsService = predictionsService
    }

    func setRequest(_ request: PredictionsIdentifyRequest) {
        self.request = request
    }

    func fetchOnlineResult(callback: @escaping IdentifyEventHandler) {
        guard let onlineService = predictionsService else {
            let message = PredictionsServiceErrorMessage.onlineIdentifyServiceNotAvailable.errorDescription
            let recoveryMessage = PredictionsServiceErrorMessage.onlineIdentifyServiceNotAvailable.recoverySuggestion
            let predictionError = PredictionsError.service(message, recoveryMessage, nil)
            callback(.failed(predictionError))
            return
        }

        switch request.identifyType {
        case .detectCelebrity:
            onlineService.detectCelebrities(image: request.image, onEvent: callback)
        case .detectText(let formatType):
            onlineService.detectText(image: request.image, format: formatType, onEvent: callback)
        case .detectLabels:
            onlineService.detectLabels(image: request.image, onEvent: callback)
        case .detectEntities:
            onlineService.detectEntities(image: request.image, onEvent: callback)
        }
    }

    func fetchOfflineResult(callback: @escaping IdentifyEventHandler) {
        guard let offlineService = coreMLService else {
            let message = PredictionsServiceErrorMessage.offlineIdentifyServiceNotAvailable.errorDescription
            let recoveryMessage = PredictionsServiceErrorMessage.offlineIdentifyServiceNotAvailable.recoverySuggestion
            let predictionError = PredictionsError.service(message, recoveryMessage, nil)
            callback(.failed(predictionError))
            return
        }
        offlineService.detectLabels(request.image,
                                    type: request.identifyType,
                                    onEvent: callback)
    }

    // MARK: -
    func combineResults(offlineResult: IdentifyResult?,
                        onlineResult: IdentifyResult?,
                        callback: @escaping  IdentifyEventHandler) {
        // TODO: Combine logic to be added
    }
}
