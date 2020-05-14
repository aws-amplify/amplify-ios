//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension AuthCategory: AuthCategoryDeviceBehavior {

    public func fetchDevices(
        options: AuthFetchDevicesOperation.Request.Options? = nil,
        listener: AuthFetchDevicesOperation.EventListener?) -> AuthFetchDevicesOperation {
        return plugin.fetchDevices(options: options,
                                   listener: listener)
    }

    public func forget(
        device: AuthDevice? = nil,
        options: AuthForgetDeviceOperation.Request.Options? = nil,
        listener: AuthForgetDeviceOperation.EventListener?) -> AuthForgetDeviceOperation {
        return plugin.forget(device: device,
                             options: options,
                             listener: listener)
    }

    public func rememberDevice(
        options: AuthRememberDeviceOperation.Request.Options? = nil,
        listener: AuthRememberDeviceOperation.EventListener?) -> AuthRememberDeviceOperation {
        plugin.rememberDevice(options: options, listener: listener)
    }

}
