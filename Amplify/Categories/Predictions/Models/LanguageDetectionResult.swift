//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

public struct LanguageDetectionResult {
    let languageCode: LanguageType
    let score: Double?

    public init(languageCode: LanguageType, score: Double?) {
        self.languageCode = languageCode
        self.score = score
    }
}
