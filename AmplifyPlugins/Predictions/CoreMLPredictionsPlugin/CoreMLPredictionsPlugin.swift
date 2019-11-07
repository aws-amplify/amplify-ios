//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify

/// Predictions plugin that uses CoreML service to get results.
final public class CoreMLPredictionsPlugin: PredictionsCategoryPlugin {

    var coreMLNaturalLanguage: CoreMLNaturalLanguageBehavior!

    /// A queue that regulates the execution of operations.
    var queue: OperationQueue!

    /// The unique key of the plugin within the predictions category.
    public var key: PluginKey {
        return CoreMLPluginConstants.coreMLPredictionsPluginKey
    }

    public init() {
    }
}
