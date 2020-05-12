//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify

class AuthUserServiceAdapter: AuthUserServiceBehavior {

    let awsMobileClient: AWSMobileClientBehavior

    init(awsMobileClient: AWSMobileClientBehavior) {
        self.awsMobileClient = awsMobileClient
    }

    func fetchAttributes(request: AuthFetchUserAttributesRequest,
                         completionHandler: @escaping FetchUserAttributesCompletion) {
        awsMobileClient.getUserAttributes { result, error in
            guard error == nil else {
                let authError = AuthErrorHelper.toAuthError(error!)
                completionHandler(.failure(authError))
                return
            }
            guard let result = result else {
                // This should not happen, return an unknown error.
                let error = AuthError.unknown("Could not read result from fetchAttributes operation")
                completionHandler(.failure(error))
                return
            }
            let resultList = result.map { AuthUserAttribute($0.key.toUserAttributeKey(), value: $0.value) }
            completionHandler(.success(resultList))
        }
    }

    func updateAttribute(request: AuthUpdateUserAttributeRequest,
                         completionHandler: @escaping UpdateUserAttributeCompletion) {

        let attribuetList = [request.userAttribute]
        updateAttributes(attributeList: attribuetList) { result in
            switch result {
            case .success(let updateAttributeResultDict):
                guard let updateResult = updateAttributeResultDict[request.userAttribute.key] else {
                    let error = AuthError.unknown("Could not read result from updateAttribute operation")
                    completionHandler(.failure(error))
                    return
                }
                completionHandler(.success(updateResult))
            case .failure(let error):
                completionHandler(.failure(error))

            }
        }

    }

    func updateAttributes(request: AuthUpdateUserAttributesRequest,
                          completionHandler: @escaping UpdateUserAttributesCompletion) {
        updateAttributes(attributeList: request.userAttributes, completionHandler: completionHandler)
    }

    func resendAttributeConfirmationCode(request: AuthAttributeResendConfirmationCodeRequest,
                                         completionHandler: @escaping ResendAttributeConfirmationCodeCompletion) {

        awsMobileClient.verifyUserAttribute(attributeName: request.attributeKey.toString()) { result, error in

            guard error == nil else {
                let authError = AuthErrorHelper.toAuthError(error!)
                completionHandler(.failure(authError))
                return
            }

            guard let result = result else {
                // This should not happen, return an unknown error.
                let error = AuthError.unknown("""
                Could not read result from resendAttributeConfirmationCode operation
                """)
                completionHandler(.failure(error))
                return
            }
            let codeDeliveryDetails = AuthCodeDeliveryDetails(destination: result.toDeliveryDestination(),
                                                              attributeName: result.attributeName)
            completionHandler(.success(codeDeliveryDetails))
        }

    }

    func confirmAttribute(request: AuthConfirmUserAttributeRequest,
                          completionHandler: @escaping ConfirmAttributeCompletion) {

        awsMobileClient.confirmUpdateUserAttributes(attributeName: request.attributeKey.toString(),
                                                    code: request.confirmationCode) { error in
                                                        guard let error = error else {
                                                            completionHandler(.success(()))
                                                            return
                                                        }
                                                        let authError = AuthErrorHelper.toAuthError(error)
                                                        completionHandler(.failure(authError))
        }
    }

    func changePassword(request: AuthChangePasswordRequest,
                        completionHandler: @escaping ChangePasswordCompletion) {
        awsMobileClient.changePassword(currentPassword: request.oldPassword,
                                       proposedPassword: request.newPassword) { error in
                                        guard let error = error else {
                                            completionHandler(.success(()))
                                            return
                                        }
                                        let authError = AuthErrorHelper.toAuthError(error)
                                        completionHandler(.failure(authError))
        }

    }

    private func updateAttributes(attributeList: [AuthUserAttribute],
                                  completionHandler: @escaping UpdateUserAttributesCompletion) {

        let attributeMap = attributeList.reduce(into: [String: String]()) {
            $0[$1.key.toString()] = $1.value
        }
        awsMobileClient.updateUserAttributes(attributeMap: attributeMap) { result, error in
            guard error == nil else {
                let authError = AuthErrorHelper.toAuthError(error!)
                completionHandler(.failure(authError))
                return
            }

            guard let result = result else {
                // This should not happen, return an unknown error.
                let error = AuthError.unknown("Could not read result from verifyUserAttribute operation")
                completionHandler(.failure(error))
                return
            }

            var finalResult = [AuthUserAttributeKey: AuthUpdateAttributeResult]()
            for item in result {
                if let attribute = item.attributeName {
                    let authCodeDeliveryDetails = AuthCodeDeliveryDetails(destination: item.toDeliveryDestination(),
                                                                          attributeName: attribute)
                    let nextStep = AuthUpdateAttributeStep.confirmAttributeWithCode(authCodeDeliveryDetails, nil)
                    let updateAttributeResult = AuthUpdateAttributeResult(isUpdated: false,
                                                                          nextStep: nextStep)
                    finalResult[attribute.toUserAttributeKey()] = updateAttributeResult
                }
            }
            // Check if all items are added to the dictionary
            for item in attributeList where finalResult[item.key] == nil {
                let updateAttributeResult = AuthUpdateAttributeResult(isUpdated: true, nextStep: .done)
                finalResult[item.key] = updateAttributeResult
            }
            completionHandler(.success(finalResult))
        }
    }
}
