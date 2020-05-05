//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify

typealias FetchUserAttributesCompletion = (Result<[AuthUserAttribute], AmplifyAuthError>) -> Void
typealias UpdateUserAttributeCompletion = (Result<AuthUpdateAttributeResult, AmplifyAuthError>) -> Void
typealias UpdateUserAttributesCompletion = (Result<[AuthUserAttributeKey: AuthUpdateAttributeResult],
    AmplifyAuthError>) -> Void
typealias ResendAttributeConfirmationCodeCompletion = (Result<AuthCodeDeliveryDetails,
    AmplifyAuthError>) -> Void
typealias ConfirmAttributeCompletion = (Result<Void, AmplifyAuthError>) -> Void
typealias ChangePasswordCompletion = (Result<Void, AmplifyAuthError>) -> Void

protocol AuthUserServiceBehavior: class {

    func fetchAttributes(request: AuthFetchUserAttributesRequest,
                         completionHandler: @escaping FetchUserAttributesCompletion)

    func updateAttribute(request: AuthUpdateUserAttributeRequest,
                         completionHandler: @escaping UpdateUserAttributeCompletion)

    func updateAttributes(request: AuthUpdateUserAttributesRequest,
                          completionHandler: @escaping UpdateUserAttributesCompletion)

    func resendAttributeConfirmationCode(request: AuthAttributeResendConfirmationCodeRequest,
                                         completionHandler: @escaping ResendAttributeConfirmationCodeCompletion)

    func confirmAttribute(request: AuthConfirmUserAttributeRequest,
                          completionHandler: @escaping ConfirmAttributeCompletion)

    func changePassword(request: AuthChangePasswordRequest,
                        completionHandler: @escaping ChangePasswordCompletion)
}
