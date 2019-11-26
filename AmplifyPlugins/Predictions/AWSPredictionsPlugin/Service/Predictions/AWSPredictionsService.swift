//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSRekognition
import AWSTranslate
import AWSTextract
import AWSComprehend
import AWSPolly
import AWSPluginsCore

class AWSPredictionsService {

    var identifier: String!
    var awsTranslate: AWSTranslateBehavior!
    var awsRekognition: AWSRekognitionBehavior!
    var awsPolly: AWSPollyBehavior!
    var awsTranscribe: AWSTranscribeBehavior!
    var awsComprehend: AWSComprehendBehavior!
    var awsTextract: AWSTextractBehavior!
    var predictionsConfig: PredictionsPluginConfiguration!
    let rekognitionWordLimit = 50

    convenience init(configuration: PredictionsPluginConfiguration,
                     cognitoCredentialsProvider: AWSCognitoCredentialsProvider,
                     identifier: String) throws {

        let interpretServiceConfiguration = ServiceConfiguration(region: configuration.interpret.region,
                                                                 credentialsProvider: cognitoCredentialsProvider)
        let identifyServiceConfiguration = ServiceConfiguration(region: configuration.identify.region,
                                                                credentialsProvider: cognitoCredentialsProvider)
        let convertServiceConfiguration =  ServiceConfiguration(region: configuration.convert.region,
                                                                credentialsProvider: cognitoCredentialsProvider)

        let awsTranslateAdapter = AWSPredictionsService.makeAWSTranslate(
            serviceConfiguration: convertServiceConfiguration,
            identifier: identifier)
        let awsRekognitionAdapter = AWSPredictionsService.makeRekognition(
            serviceConfiguration: identifyServiceConfiguration,
            identifier: identifier)
        let awsTextractAdapter = AWSPredictionsService.makeTextract(
            serviceConfiguration: identifyServiceConfiguration,
            identifier: identifier)
        let awsComprehendAdapter = AWSPredictionsService.makeComprehend(
            serviceConfiguration: interpretServiceConfiguration,
            identifier: identifier)
        let awsPollyAdapter = AWSPredictionsService.makePolly(
            serviceConfiguration: convertServiceConfiguration,
            identifier: identifier)

        self.init(identifier: identifier,
                  awsTranslate: awsTranslateAdapter,
                  awsRekognition: awsRekognitionAdapter,
                  awsTextract: awsTextractAdapter,
                  awsComprehend: awsComprehendAdapter,
                  awsPolly: awsPollyAdapter,
                  configuration: configuration)

    }

    init(identifier: String,
         awsTranslate: AWSTranslateBehavior,
         awsRekognition: AWSRekognitionBehavior,
         awsTextract: AWSTextractBehavior,
         awsComprehend: AWSComprehendBehavior,
         awsPolly: AWSPollyBehavior,
         configuration: PredictionsPluginConfiguration) {

        self.identifier = identifier
        self.awsTranslate = awsTranslate
        self.awsRekognition = awsRekognition
        self.awsTextract = awsTextract
        self.awsComprehend = awsComprehend
        self.awsPolly = awsPolly
        self.predictionsConfig = configuration

    }

    func reset() {

        AWSTranslate.remove(forKey: identifier)
        awsTranslate = nil

        AWSRekognition.remove(forKey: identifier)
        awsRekognition = nil

        AWSTextract.remove(forKey: identifier)
        awsTextract = nil

        AWSComprehend.remove(forKey: identifier)
        awsComprehend = nil

        AWSPolly.remove(forKey: identifier)
        awsPolly = nil

        identifier = nil
    }

    func getEscapeHatch(key: PredictionsAWSService) -> AWSService {
        switch key {
        case .rekognition:
            return awsRekognition.getRekognition()
        case .translate:
            return awsTranslate.getTranslate()
        case .polly:
            return awsPolly.getPolly()
        case .transcribe:
            return awsTranscribe.getTranscribe()
        case .comprehend:
            return awsComprehend.getComprehend()
        case .textract:
            return awsTextract.getTextract()
        }
    }

    private static func makeAWSTranslate(serviceConfiguration: AWSServiceConfiguration,
                                         identifier: String) -> AWSTranslateAdapter {
        AWSTranslate.register(with: serviceConfiguration, forKey: identifier)
        let awsTranslate = AWSTranslate(forKey: identifier)
        return AWSTranslateAdapter(awsTranslate)
    }

    private static func makeRekognition(serviceConfiguration: AWSServiceConfiguration,
                                        identifier: String) -> AWSRekognitionAdapter {
        AWSRekognition.register(with: serviceConfiguration, forKey: identifier)
        let awsRekognition = AWSRekognition(forKey: identifier)
        return AWSRekognitionAdapter(awsRekognition)
    }

    private static func makeTextract(serviceConfiguration: AWSServiceConfiguration,
                                     identifier: String) -> AWSTextractAdapter {
        AWSTextract.register(with: serviceConfiguration, forKey: identifier)
        let awsTextract = AWSTextract(forKey: identifier)
        return AWSTextractAdapter(awsTextract)
    }

    private static func makePolly(serviceConfiguration: AWSServiceConfiguration,
                                  identifier: String) -> AWSPollyAdapter {
        AWSPolly.register(with: serviceConfiguration, forKey: identifier)
        let awsPolly = AWSPolly(forKey: identifier)
        return AWSPollyAdapter(awsPolly)
    }

    private static func makeComprehend(serviceConfiguration: AWSServiceConfiguration,
                                       identifier: String) -> AWSComprehendAdapter {
        AWSComprehend.register(with: serviceConfiguration, forKey: identifier)
        let awsComprehend = AWSComprehend(forKey: identifier)
        return AWSComprehendAdapter(awsComprehend)
    }
}
