//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify

public class AWSAuthRememberDeviceOperation: AmplifyOperation<AuthRememberDeviceRequest,
    Void,
    Void,
    AuthError>,
AuthRememberDeviceOperation {

    let deviceService: AuthDeviceServiceBehavior

    init(_ request: AuthRememberDeviceRequest,
         deviceService: AuthDeviceServiceBehavior,
         listener: EventListener?) {

        self.deviceService = deviceService
        super.init(categoryType: .auth,
                   eventName: HubPayload.EventName.Auth.rememberDevice,
                   request: request,
                   listener: listener)
    }

    override public func main() {
        if isCancelled {
            finish()
            return
        }

        deviceService.rememberDevice(request: request) { [weak self] result in
            guard let self = self else { return }

            defer {
                self.finish()
            }
            switch result {
            case .failure(let error):
                self.dispatch(error)
            case .success:
                self.dispatchSuccess()
            }
        }
    }

    private func dispatchSuccess() {
        let asyncEvent = AsyncEvent<Void, Void, AuthError>.completed(())
        dispatch(event: asyncEvent)
    }

    private func dispatch(_ error: AuthError) {
        let asyncEvent = AsyncEvent<Void, Void, AuthError>.failed(error)
        dispatch(event: asyncEvent)
    }
}
