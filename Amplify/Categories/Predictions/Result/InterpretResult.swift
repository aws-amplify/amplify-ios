//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

/// Results are mapped to InterpretResult for interpret() API
public struct InterpretResult {

    public let keyPhrases: [KeyPhrase]?
    public let sentiment: Sentiment?
    public let entities: [EntityDetectionResult]?
    public let language: LanguageDetectionResult?
    public let syntax: [SyntaxToken]?
}

extension InterpretResult {

    public struct Builder {

        var keyPhrases: [KeyPhrase]?
        var sentiment: Sentiment?
        var entities: [EntityDetectionResult]?
        var language: LanguageDetectionResult?
        var syntax: [SyntaxToken]?

        public init() {}

        public func build() -> InterpretResult {
            let result = InterpretResult(keyPhrases: keyPhrases,
                                         sentiment: sentiment,
                                         entities: entities,
                                         language: language,
                                         syntax: syntax)
            return result
        }

        @discardableResult
        mutating public func with(keyPhrases: [KeyPhrase]?) -> Builder {
            self.keyPhrases = keyPhrases
            return self
        }

        @discardableResult
        mutating public func with(sentiment: Sentiment?) -> Builder {
            self.sentiment = sentiment
            return self
        }

        @discardableResult
        mutating public func with(entities: [EntityDetectionResult]?) -> Builder {
            self.entities = entities
            return self
        }

        @discardableResult
        mutating public func with(language: LanguageDetectionResult?) -> Builder {
            self.language = language
            return self
        }

        @discardableResult
        mutating public func with(syntax: [SyntaxToken]?) -> Builder {
            self.syntax = syntax
            return self
        }
    }
}
