//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify

public protocol UserPoolTokenProvider {
    func getToken() -> Result<String, AuthError>
}

public struct BasicUserPoolTokenProvider: UserPoolTokenProvider {

    let authService: AWSAuthServiceBehavior

    public init(authService: AWSAuthServiceBehavior) {
        self.authService = authService
    }

    public func getToken() -> Result<String, AuthError> {
        return authService.getToken()
    }
}
