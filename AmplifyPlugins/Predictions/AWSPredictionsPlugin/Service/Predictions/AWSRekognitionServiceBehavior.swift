//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify
import AWSRekognition

protocol AWSRekognitionServiceBehaviour {

    typealias RekognitionServiceEventHandler = (RekognitionServiceEvent) -> Void
    typealias RekognitionServiceEvent = PredictionsEvent<IdentifyResult, PredictionsError>

    func detectLabels(image: UIImage,
                      onEvent: @escaping RekognitionServiceEventHandler)

}
