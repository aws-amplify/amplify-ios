//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify

extension AuthConfirmSignUpRequest {

    func validate() -> AmplifyAuthError? {
        guard !username.isEmpty else {
            return AmplifyAuthError.validation(AuthPluginErrorConstants.confirmSignUpUsernameError.field,
                                               AuthPluginErrorConstants.confirmSignUpUsernameError.errorDescription,
                                               AuthPluginErrorConstants.confirmSignUpUsernameError.recoverySuggestion)
        }

        guard !code.isEmpty else {
            return AmplifyAuthError.validation(AuthPluginErrorConstants.confirmSignUpCodeError.field,
                                               AuthPluginErrorConstants.confirmSignUpCodeError.errorDescription,
                                               AuthPluginErrorConstants.confirmSignUpCodeError.recoverySuggestion)
        }

        return nil
    }
}
