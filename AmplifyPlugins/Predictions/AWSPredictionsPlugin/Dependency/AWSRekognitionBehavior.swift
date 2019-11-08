//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import AWSRekognition

protocol AWSRekognitionBehavior {

    func detectLabels(request: AWSRekognitionDetectLabelsRequest) -> AWSTask<AWSRekognitionDetectLabelsResponse>

    func detectCelebs(request: AWSRekognitionRecognizeCelebritiesRequest) -> AWSTask<AWSRekognitionRecognizeCelebritiesResponse>

    func getRekognition() -> AWSRekognition
}
