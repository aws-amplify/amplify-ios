//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSPluginsCore

class AuthHubEventHandler: AuthHubEventBehavior {

    var lastSendEventName: HubPayloadEventName?

    init() {
        setupHubEvents()
    }

    func sendUserSignedInEvent() {
        dispatchAuthEvent(HubPayload.EventName.Auth.signedIn)
    }

    func sendUserSignedOutEvent() {
        dispatchAuthEvent(HubPayload.EventName.Auth.signedOut)
    }

    func sendSessionExpiredEvent() {
        dispatchAuthEvent(HubPayload.EventName.Auth.sessionExpired)
    }

    private func setupHubEvents() {

        _ = Amplify.Hub.listen(to: .auth) {[weak self] payload in
            switch payload.eventName {

            case HubPayload.EventName.Auth.signIn:
                guard let event = payload.data as? AWSAuthSignInOperation.OperationResult,
                    case let .success(result) = event else {
                        return
                }
                self?.handleSignInEvent(result)

            case HubPayload.EventName.Auth.confirmSignIn:
                guard let event = payload.data as? AWSAuthConfirmSignInOperation.OperationResult,
                    case let .success(result) = event else {
                        return
                }
                self?.handleSignInEvent(result)

            case HubPayload.EventName.Auth.signOut:
                guard let event = payload.data as? AWSAuthSignOutOperation.OperationResult,
                    case .success(_) = event else {
                        return
                }
                self?.sendUserSignedOutEvent()

            case HubPayload.EventName.Auth.fetchSession:
                guard let event = payload.data as? AWSAuthFetchSessionOperation.OperationResult,
                    case let .success(result) = event else {
                        return
                }
                self?.handleSessionEvent(result)

            default:
                break
            }
        }
    }

    private func handleSignInEvent(_ signInResult: AuthSignInResult) {
        guard signInResult.isSignedIn else {
            return
        }
        sendUserSignedInEvent()
    }

    private func handleSessionEvent(_ sessionResult: AuthSession) {
        guard let tokensProvider = sessionResult as? AuthCognitoTokensProvider,
            case let .failure(authError) = tokensProvider.getCognitoTokens() else {
                return
        }

        guard case let .service(_, _, cognitoError as AWSCognitoAuthError) = authError,
            cognitoError == .sessionExpired else {
                return
        }

        sendSessionExpiredEvent()
    }

    private func dispatchAuthEvent(_ eventName: String) {
        if eventName != lastSendEventName {
            lastSendEventName = eventName
            Amplify.Hub.dispatch(to: .auth, payload: HubPayload(eventName: eventName))
        }
    }

}
