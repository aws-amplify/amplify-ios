//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

public typealias AuthUIPresentationAnchor = UIWindow

/// Behavior of the Auth category that clients will use
public protocol AuthCategoryBehavior {

    /// SignUp a user with the authentication provider.
    ///
    /// If the signUp require multiple steps like passing a confirmation code, use the method
    /// `confirmSignUp` after this api completes. You can check if the user is confirmed or not
    /// using the result `AuthSignUpResult.userConfirmed`.
    ///
    /// - Parameters:
    ///   - username: username to signUp
    ///   - password: password as per the password policy of the provider
    ///   - options: Parameters specific to plugin behavior
    ///   - listener: Triggered when the operation completes.
    func signUp(username: String,
                password: String?,
                options: AuthSignUpOperation.Request.Options?,
                listener: AuthSignUpOperation.EventListener?) -> AuthSignUpOperation

    /// Confirms the `signUp` operation.
    ///
    /// Invoke this operation as a follow up for the signUp process if the authentication provider
    /// that you are using required to follow a next step after signUp. Calling this operation without
    /// first calling `signUp` or `resendSignUpCode` may cause an error.
    /// - Parameters:
    ///   - username: Username used that was used to signUp.
    ///   - confirmationCode: Confirmation code received to the user.
    ///   - options: Parameters specific to plugin behavior
    ///   - listener: Triggered when the operation completes.
    func confirmSignUp(username: String,
                       confirmationCode: String,
                       options: AuthConfirmSignUpOperation.Request.Options?,
                       listener: AuthConfirmSignUpOperation.EventListener?) -> AuthConfirmSignUpOperation

    /// Resends the confirmation code to confirm the signUp process
    ///
    /// - Parameters:
    ///   - username: Username of the user to be confirmed.
    ///   - options: Parameters specific to plugin behavior.
    ///   - listener: Triggered when the operation completes.
    func resendSignUpCode(username: String,
                          options: AuthResendSignUpCodeOperation.Request.Options?,
                          listener: AuthResendSignUpCodeOperation.EventListener?) -> AuthResendSignUpCodeOperation

    /// SignIn to the authentication provider
    ///
    /// Username and password are optional values, check the plugin documentation to decide on what all values need to
    /// passed. For example in a passwordless flow you just need to pass the username and the passwordcould be nil.
    ///
    /// - Parameters:
    ///   - username: Username to signIn the user
    ///   - password: Password to signIn the user
    ///   - options: Parameters specific to plugin behavior
    ///   - listener: Triggered when the operation completes.
    func signIn(username: String?,
                password: String?,
                options: AuthSignInOperation.Request.Options?,
                listener: AuthSignInOperation.EventListener?) -> AuthSignInOperation

    /// SignIn using pre configured web UI.
    ///
    /// Calling this method will always launch the Auth plugin's default web user interface
    ///
    /// - Parameters:
    ///   - presentationAnchor: Anchor on which the UI is presented.
    ///   - options: Parameters specific to plugin behavior.
    ///   - listener: Triggered when the operation completes.
    func signInWithWebUI(presentationAnchor: AuthUIPresentationAnchor,
                         options: AuthWebUISignInOperation.Request.Options?,
                         listener: AuthWebUISignInOperation.EventListener?) -> AuthWebUISignInOperation

    /// SignIn using an auth provider on a web UI
    ///
    /// Calling this method will invoke the AuthProvider's default web user interface. Depending on the plugin
    /// implementation and the authentication state with the provider, this method might complete without showing
    /// any UI.
    ///
    /// - Parameters:
    ///   - authProvider: Auth provider used to signIn.
    ///   - presentationAnchor: Anchor on which the UI is presented.
    ///   - options: Parameters specific to plugin behavior.
    ///   - listener: Triggered when the operation completes.
    func signInWithWebUI(for authProvider: AuthProvider,
                         presentationAnchor: AuthUIPresentationAnchor,
                         options: AuthSocialWebUISignInOperation.Request.Options?,
                         listener: AuthSocialWebUISignInOperation.EventListener?) -> AuthSocialWebUISignInOperation

    /// Confirms a next step in signIn flow.
    ///
    /// - Parameters:
    ///   - challengeResponse: Challenge response required to confirm the next step in signIn flow
    ///   - options: Parameters specific to plugin behavior.
    ///   - listener: Triggered when the operation completes.
    func confirmSignIn(challengeResponse: String,
                       options: AuthConfirmSignInOperation.Request.Options?,
                       listener: AuthConfirmSignInOperation.EventListener?) -> AuthConfirmSignInOperation

    func fetchAuthState(listener: AuthStateOperation.EventListener?) -> AuthStateOperation

    // MARK: - Password Management

    func forgotPassword(username: String,
                        options: AuthForgotPasswordOperation.Request.Options?,
                        listener: AuthForgotPasswordOperation.EventListener?) -> AuthForgotPasswordOperation

    func confirmForgotPassword(username: String,
                               newPassword: String,
                               confirmationCode: String,
                               options: AuthConfirmForgotPasswordOperation.Request.Options?,
                               listener: AuthConfirmForgotPasswordOperation.EventListener?) ->
    AuthConfirmForgotPasswordOperation

    func changePassword(currentPassword: String,
                        newPassword: String,
                        options: AuthChangePasswordOperation.Request.Options?,
                        listener: AuthChangePasswordOperation.EventListener?) -> AuthChangePasswordOperation
}
