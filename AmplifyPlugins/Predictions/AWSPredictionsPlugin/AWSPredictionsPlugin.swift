//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation
import AWSPluginsCore

final public class AWSPredictionsPlugin: PredictionsCategoryPlugin {

    let awsPredictionsPluginKey = "AWSPredictionsPlugin"

    /// A queue that regulates the execution of operations.
    var queue: OperationQueue!

    /// An instance of the predictions  service
    var predictionsService: AWSPredictionsService!

    var authService: AWSAuthServiceBehavior!

    var config: AWSPredictionsPluginConfiguration!

    ///public limit rekognition has on number of faces it can detect.
    public static let rekognitionMaxFacesLimit = 50

    /// The unique key of the plugin within the predictions category.
    public var key: PluginKey {
        return awsPredictionsPluginKey
    }

    public init() {
    }
}
