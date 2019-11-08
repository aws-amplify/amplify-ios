//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify
import AWSMobileClient

public class AWSAuthService: AWSAuthServiceBehavior {

    var mobileClient: AWSMobileClientBehavior!

    public convenience init() {
        self.init(mobileClient: nil)
    }

    init(mobileClient: AWSMobileClientBehavior? = nil) {
        let mobileClient = mobileClient ?? AWSMobileClientAdapter(AWSMobileClient.default())
        self.mobileClient = mobileClient
    }

    public func getCognitoCredentialsProvider() -> AWSCognitoCredentialsProvider {
        return mobileClient.getCognitoCredentialsProvider()
    }

    public func getIdentityId() -> Result<String, AuthError> {
        let task = mobileClient.getIdentityId()
        task.waitUntilFinished()

        guard task.error == nil else {
            if let error = task.error! as? AWSMobileClientError {
                return .failure(map(error))
            }

            return .failure(AuthError.unknown("Some error occuring retrieving the IdentityId."))
        }

        guard let identityId = task.result else {
            let error = AuthError.unknown("Got successful response but missing IdentityId in the result.")
            return .failure(error)
        }

        return .success(identityId as String)
    }

    /// Used for testing only. Invoking this method outside of a testing scope has undefined behavior.
    public func reset() {
        mobileClient = nil
    }

    private func map(_ error: AWSMobileClientError) -> AuthError {
        switch error {
        case .identityIdUnavailable(let message):
            return AuthError.identity("Identity Id is Unavailable",
                                      message,
                                      """
                                      Check for network connectivity and try again.
                                      """,
                                      error)
        case .guestAccessNotAllowed(let message):
            return AuthError.identity("Guest access is not allowed",
                                      message,
                                      """
                                      Cognito was configured to disallow unauthenticated (guest) access.
                                      Turn on guest access and try again.
                                      """,
                                      error)
        default:
            return AuthError.unknown(error.localizedDescription)
        }
    }

}
