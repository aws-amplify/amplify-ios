//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify

public class CoreMLIdentifyOperation: AmplifyOperation<PredictionsIdentifyRequest,
    Void,
    IdentifyResult,
PredictionsError>, PredictionsIdentifyOperation {

    weak var coreMLVision: CoreMLVisionBehavior?

    init(_ request: PredictionsIdentifyRequest,
         coreMLVision: CoreMLVisionBehavior,
         listener: EventListener?) {

        self.coreMLVision = coreMLVision
        super.init(categoryType: .predictions,
                   eventName: HubPayload.EventName.Predictions.identifyLabels,
                   request: request,
                   listener: listener)
    }

    override public func main() {

        guard let coreMLVisionAdapter = coreMLVision else {
            finish()
            return
        }

        if isCancelled {
            finish()
            return
        }
        switch request.identifyType {
        case .detectCelebrity, .detectEntities:
            let errorDescription = CoreMLPluginErrorString.operationNotSupported.errorDescription
            let recovery = CoreMLPluginErrorString.operationNotSupported.recoverySuggestion
            let predictionsError = PredictionsError.service(errorDescription, recovery, nil)
            dispatch(event: .failed(predictionsError))
            finish()
        case .detectText:
            guard  let result = coreMLVisionAdapter.detectText(request.image) else {
                let errorDescription = CoreMLPluginErrorString.detectTextNoResult.errorDescription
                let recovery = CoreMLPluginErrorString.detectTextNoResult.recoverySuggestion
                let predictionsError = PredictionsError.service(errorDescription, recovery, nil)
                dispatch(event: .failed(predictionsError))
                finish()
                return
            }
            dispatch(event: .completed(result))
            finish()
        case .detectLabels:
            guard  let result = coreMLVisionAdapter.detectLabels(request.image) else {
                let errorDescription = CoreMLPluginErrorString.detectLabelsNoResult.errorDescription
                let recovery = CoreMLPluginErrorString.detectLabelsNoResult.recoverySuggestion
                let predictionsError = PredictionsError.service(errorDescription, recovery, nil)
                dispatch(event: .failed(predictionsError))
                finish()
                return
            }
            dispatch(event: .completed(result))
            finish()
        }
    }
}
