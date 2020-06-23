//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Combine

public typealias AuthPublisher<Output> = AnyPublisher<Output, AuthError>

public extension AuthCategoryBehavior {

    /// Confirm a reset password flow
    ///
    /// - Parameters:
    ///   - username: username whose password need to reset
    ///   - newPassword: new password for the user
    ///   - confirmationCode: Received confirmation code
    ///   - options: Parameters specific to plugin behavior
    /// - Returns: An AuthPublisher with the results of the operation
    func confirmResetPassword(
        for username: String,
        with newPassword: String,
        confirmationCode: String,
        options: AuthConfirmResetPasswordOperation.Request.Options? = nil
    ) -> AuthPublisher<Void> {
        Future { promise in
            _ = self.confirmResetPassword(
                for: username,
                with: newPassword,
                confirmationCode: confirmationCode,
                options: options
            ) { promise($0) }
        }.eraseToAnyPublisher()
    }

    /// Confirm a next step in the signIn flow
    ///
    /// - Parameters:
    ///   - challengeResponse: Challenge response required to confirm the next step in signIn flow
    ///   - options: Parameters specific to plugin behavior
    /// - Returns: An AuthPublisher with the results of the operation
    func confirmSignIn(
        challengeResponse: String,
        options: AuthConfirmSignInOperation.Request.Options? = nil
    ) -> AuthPublisher<AuthSignInResult> {
        Future { promise in
            _ = self.confirmSignIn(challengeResponse: challengeResponse, options: options) { promise($0) }
        }.eraseToAnyPublisher()
    }

    /// Confirm the `signUp` operation
    ///
    /// Invoke this operation as a follow up for the `signUp` process if the authentication provider
    /// that you are using requires a next step of `confirmSignUp`. Calling this operation without
    /// first calling `signUp` or `resendSignUpCode` may cause an error.
    /// - Parameters:
    ///   - username: Username used that was used to signUp.
    ///   - confirmationCode: Confirmation code received to the user.
    ///   - options: Parameters specific to plugin behavior
    /// - Returns: An AuthPublisher with the results of the operation
    func confirmSignUp(
        for username: String,
        confirmationCode: String,
        options: AuthConfirmSignUpOperation.Request.Options? = nil
    ) -> AuthPublisher<AuthSignUpResult> {
        Future { promise in
            _ = self.confirmSignUp(for: username, confirmationCode: confirmationCode, options: options) { promise($0) }
        }.eraseToAnyPublisher()
    }

    /// Fetch the current authentication session
    ///
    /// - Parameters:
    ///   - options: Parameters specific to plugin behavior
    /// - Returns: An AuthPublisher with the results of the operation
    func fetchAuthSession(
        options: AuthFetchSessionOperation.Request.Options? = nil
    ) -> AuthPublisher<AuthSession> {
        Future { promise in
            _ = self.fetchAuthSession(options: options) { promise($0) }
        }.eraseToAnyPublisher()
    }

    /// Resend the confirmation code to confirm the signUp process
    ///
    /// - Parameters:
    ///   - username: Username of the user to be confirmed.
    ///   - options: Parameters specific to plugin behavior
    /// - Returns: An AuthPublisher with the results of the operation
    func resendSignUpCode(
        for username: String,
        options: AuthResendSignUpCodeOperation.Request.Options? = nil
    ) -> AuthPublisher<AuthCodeDeliveryDetails> {
        Future { promise in
            _ = self.resendSignUpCode(for: username, options: options) { promise($0) }
        }.eraseToAnyPublisher()
    }

    /// Initiate a reset password flow for the user
    ///
    /// - Parameters:
    ///   - username: username whose password need to reset
    ///   - options: Parameters specific to plugin behavior
    /// - Returns: An AuthPublisher with the results of the operation
    func resetPassword(
        for username: String,
        options: AuthResetPasswordOperation.Request.Options? = nil
    ) -> AuthPublisher<AuthResetPasswordResult> {
        Future { promise in
            _ = self.resetPassword(for: username, options: options) { promise($0) }
        }.eraseToAnyPublisher()
    }

    /// Sign in to the authentication provider
    ///
    /// Username and password are optional values. Check the plugin documentation to decide on what values
    /// need to be passed. For example, in a passwordless flow the plugin may only require the username, while
    /// the password is nil.
    ///
    /// - Parameters:
    ///   - username: Username to signIn the user
    ///   - password: Password to signIn the user
    ///   - options: Parameters specific to plugin behavior
    /// - Returns: An AuthPublisher with the results of the operation
    func signIn(
        username: String? = nil,
        password: String? = nil,
        options: AuthSignInOperation.Request.Options? = nil
    ) -> AuthPublisher<AuthSignInResult> {
        Future { promise in
            _ = self.signIn(username: username, password: password, options: options) { promise($0) }
        }.eraseToAnyPublisher()
    }

    /// Sign in using an auth provider via a web UI
    ///
    /// Calling this method will invoke the AuthProvider's default web user interface (as distinct from the web
    /// user interface provided by the plugin). Depending on the plugin implementation and the authentication
    /// state with the provider, this method might complete without showing any UI.
    ///
    /// - Parameters:
    ///   - authProvider: Auth provider used to signIn
    ///   - presentationAnchor: Anchor on which the UI is presented
    ///   - options: Parameters specific to plugin behavior
    /// - Returns: An AuthPublisher with the results of the operation
    func signInWithWebUI(
        for authProvider: AuthProvider,
        presentationAnchor: AuthUIPresentationAnchor,
        options: AuthSocialWebUISignInOperation.Request.Options? = nil
    ) -> AuthPublisher<AuthSignInResult> {
        Future { promise in
            _ = self.signInWithWebUI(for: authProvider, presentationAnchor: presentationAnchor, options: options) {
                promise($0)
            }
        }.eraseToAnyPublisher()
    }

    /// Sign in using pre configured web UI
    ///
    /// Calling this method will always launch the Auth plugin's default web user interface
    ///
    /// - Parameters:
    ///   - presentationAnchor: Anchor on which the UI is presented
    ///   - options: Parameters specific to plugin behavior
    /// - Returns: An AuthPublisher with the results of the operation
    func signInWithWebUI(
        presentationAnchor: AuthUIPresentationAnchor,
        options: AuthWebUISignInOperation.Request.Options? = nil
    ) -> AuthPublisher<AuthSignInResult> {
        Future { promise in
            _ = self.signInWithWebUI(presentationAnchor: presentationAnchor, options: options) { promise($0) }
        }.eraseToAnyPublisher()
    }

    /// Sign out the current user
    ///
    /// The plugin may provide additional options that modify this behavior, such as signing the user out
    /// from every active session. Consult the plugin documentation for details.
    ///
    /// - Parameters:
    ///   - options: Parameters specific to plugin behavior
    /// - Returns: An AuthPublisher with the results of the operation
    func signOut(
        options: AuthSignOutOperation.Request.Options? = nil
    ) -> AuthPublisher<Void> {
        Future { promise in
            _ = self.signOut(options: options) { promise($0) }
        }.eraseToAnyPublisher()
    }

    /// Sign up a user with the authentication provider
    ///
    /// If the signUp requires multiple steps (like passing a confirmation code), use the method
    /// `confirmSignUp` after this API completes. You can check if the user is confirmed or not
    /// using the result `AuthSignUpResult.userConfirmed`.
    ///
    /// - Parameters:
    ///   - username: username to signUp
    ///   - password: password as per the password policy of the provider
    ///   - options: Parameters specific to plugin behavior
    /// - Returns: An AuthPublisher with the results of the operation
    func signUp(
        username: String,
        password: String? = nil,
        options: AuthSignUpOperation.Request.Options? = nil
    ) -> AuthPublisher<AuthSignUpResult> {
        Future { promise in
            _ = self.signUp(username: username, password: password, options: options) { promise($0) }
        }.eraseToAnyPublisher()
    }

}
