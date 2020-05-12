//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCore

public class AmplifyAWSCredentialsProvider: NSObject, AWSCredentialsProvider {

    public func credentials() -> AWSTask<AWSCredentials> {
        let completionSource = AWSTaskCompletionSource<AWSCredentials>()
        _  = Amplify.Auth.fetchAuthSession { [weak self] event in

            switch event {
            case .completed(let session):
                self?.parseAWSCredentialsFromSession(session, completionSource: completionSource)
            case .failed(let error):
                completionSource.set(error: error)
            default:
                let error = AuthError.unknown("Fetch auth session returned an invalid result type")
                completionSource.set(error: error)
            }
        }
        return completionSource.task
    }

    public func invalidateCachedTemporaryCredentials() {
        guard let authPlugin = try? Amplify.Auth.getPlugin(for: "awsCognitoAuthPlugin")
            as? AuthInvalidateCredentialBehavior else {
                return
        }

        authPlugin.invalidateCachedTemporaryCredentials()
    }

    private func parseAWSCredentialsFromSession(_ session: AuthSession,
                                                completionSource: AWSTaskCompletionSource<AWSCredentials>) {
        let credentialsResult = (session as? AuthAWSCredentialsProvider)?.getAWSCredentials()
        switch credentialsResult {
        case .success(let credentials):
            completionSource.set(result: credentials.toAWSCoreCredentials())
        case .failure(let error):
            completionSource.set(error: error)
        case .none:
            let error = AuthError.unknown("Auth session doesnot include aws credentials information")
            completionSource.set(error: error)
        }
    }
}

extension AuthAWSCredentials {
    func toAWSCoreCredentials() -> AWSCredentials {
        if let tempCredentials = self as? AuthAWSTemporaryCredentials {
            return AWSCredentials(accessKey: tempCredentials.accessKey,
                                  secretKey: tempCredentials.secretKey,
                                  sessionKey: tempCredentials.sessionKey,
                                  expiration: tempCredentials.expiration)
        } else {
            return AWSCredentials(accessKey: accessKey,
                                  secretKey: secretKey,
                                  sessionKey: nil,
                                  expiration: nil)
        }
    }
}
