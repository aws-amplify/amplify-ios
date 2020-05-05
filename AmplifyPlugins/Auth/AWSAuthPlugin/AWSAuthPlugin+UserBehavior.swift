//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify

extension AWSAuthPlugin {

    public func fetchAttributes(options: AuthFetchUserAttributeOperation.Request.Options? = nil,
                                listener: AuthFetchUserAttributeOperation.EventListener?)
        -> AuthFetchUserAttributeOperation {

            let options = options ?? AuthFetchUserAttributesRequest.Options()
            let request = AuthFetchUserAttributesRequest(options: options)
            let operation = AWSAuthFetchUserAttributeOperation(request,
                                                               userService: userService,
                                                               listener: listener)
            queue.addOperation(operation)
            return operation
    }

    public func update(userAttribute: AuthUserAttribute,
                       options: AuthUpdateUserAttributeOperation.Request.Options? = nil,
                       listener: AuthUpdateUserAttributeOperation.EventListener?) -> AuthUpdateUserAttributeOperation {
        let options = options ?? AuthUpdateUserAttributeRequest.Options()
        let request = AuthUpdateUserAttributeRequest(userAttribute: userAttribute, options: options)
        let operation = AWSAuthUpdateUserAttributeOperation(request,
                                                            userService: userService,
                                                            listener: listener)
        queue.addOperation(operation)
        return operation
    }

    public func update(userAttributes: [AuthUserAttribute],
                       options: AuthUpdateUserAttributesOperation.Request.Options? = nil,
                       listener: AuthUpdateUserAttributesOperation.EventListener?)
        -> AuthUpdateUserAttributesOperation {
            let options = options ?? AuthUpdateUserAttributesRequest.Options()
            let request = AuthUpdateUserAttributesRequest(userAttributes: userAttributes, options: options)
            let operation = AWSAuthUpdateUserAttributesOperation(request,
                                                                 userService: userService,
                                                                 listener: listener)
            queue.addOperation(operation)
            return operation
    }

    public func resendConfirmationCode(for attributeType: AuthUserAttributeKey,
                                       options: AuthAttributeResendConfirmationCodeOperation.Request.Options? = nil,
                                       listener: AuthAttributeResendConfirmationCodeOperation.EventListener?)
        -> AuthAttributeResendConfirmationCodeOperation {
            let options = options ?? AuthAttributeResendConfirmationCodeRequest.Options()
            let request = AuthAttributeResendConfirmationCodeRequest(attributeKey: attributeType, options: options)
            let operation = AWSAuthAttributeResendConfirmationCodeOperation(request,
                                                                userService: userService,
                                                                listener: listener)
            queue.addOperation(operation)
            return operation
    }

    public func confirm(userAttribute: AuthUserAttributeKey,
                        confirmationCode: String,
                        options: AuthConfirmUserAttributeOperation.Request.Options? = nil,
                        listener: AuthConfirmUserAttributeOperation.EventListener?)
        -> AuthConfirmUserAttributeOperation {
            let options = options ?? AuthConfirmUserAttributeRequest.Options()
            let request = AuthConfirmUserAttributeRequest(attributeKey: userAttribute,
                                                          confirmationCode: confirmationCode,
                                                          options: options)
            let operation = AWSAuthConfirmUserAttributeOperation(request,
                                                                 userService: userService,
                                                                 listener: listener)
            queue.addOperation(operation)
            return operation
    }

    public func update(oldPassword: String,
                       to newPassword: String,
                       options: AuthChangePasswordOperation.Request.Options? = nil,
                       listener: AuthChangePasswordOperation.EventListener?) -> AuthChangePasswordOperation {
        fatalError()
    }
}
