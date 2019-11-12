//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSTextract

protocol AWSTextractServiceBehaviour {

    typealias TextractServiceEventHandler = (TextractServiceEvent) -> Void
    typealias TextractServiceEvent = PredictionsEvent<IdentifyResult, PredictionsError>

    func analyzeDocument(image: URL, features: [String], onEvent: @escaping TextractServiceEventHandler)

    func detectDocumentText(image: URL, onEvent: @escaping (AWSTextractDetectDocumentTextResponse) -> Void)

}
