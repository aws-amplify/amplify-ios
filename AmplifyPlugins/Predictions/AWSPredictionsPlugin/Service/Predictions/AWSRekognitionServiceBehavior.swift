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

    func detectLabels(image: URL,
                      onEvent: @escaping RekognitionServiceEventHandler)

    func detectCelebs(image: URL, onEvent: @escaping RekognitionServiceEventHandler)

    func detectText(image: URL, onEvent: @escaping RekognitionServiceEventHandler)

    func detectEntities(image: URL, onEvent: @escaping RekognitionServiceEventHandler)
}
