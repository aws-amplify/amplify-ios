//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify

extension StorageGetURLRequest.Options {

    /// Convenience for passing in a custom key resolver in the request options
    ///
    /// - Parameter resolver: used to resolve the final key of the request
    /// - Returns: Request.Options object
    public static func customKeyResolver(_ resolver: AWSS3PluginCustomKeyResolver) -> StorageGetURLRequest.Options {
        let pluginOptions = AWSS3PluginOptions(customKeyResolver: resolver)
        return StorageGetURLRequest.Options(pluginOptions: pluginOptions)
    }
}

extension StorageDownloadDataRequest.Options {

    /// Convenience for passing in a custom key resolver in the request options
    ///
    /// - Parameter resolver: used to resolve the final key of the request
    /// - Returns: Request.Options object
    public static func customKeyResolver(_ resolver: AWSS3PluginCustomKeyResolver) ->
    StorageDownloadDataRequest.Options {
        let pluginOptions = AWSS3PluginOptions(customKeyResolver: resolver)
        return StorageDownloadDataRequest.Options(pluginOptions: pluginOptions)
    }
}

extension StorageDownloadFileRequest.Options {

    /// Convenience for passing in a custom key resolver in the request options
    ///
    /// - Parameter resolver: used to resolve the final key of the request
    /// - Returns: Request.Options object
    public static func customKeyResolver(_ resolver: AWSS3PluginCustomKeyResolver) ->
    StorageDownloadFileRequest.Options {
        let pluginOptions = AWSS3PluginOptions(customKeyResolver: resolver)
        return StorageDownloadFileRequest.Options(pluginOptions: pluginOptions)
    }
}

extension StorageUploadDataRequest.Options {

    /// Convenience for passing in a custom key resolver in the request options
    ///
    /// - Parameter resolver: used to resolve the final key of the request
    /// - Returns: Request.Options object
    public static func customKeyResolver(_ resolver: AWSS3PluginCustomKeyResolver) ->
    StorageUploadDataRequest.Options {
        let pluginOptions = AWSS3PluginOptions(customKeyResolver: resolver)
        return StorageUploadDataRequest.Options(pluginOptions: pluginOptions)
    }
}

extension StorageUploadFileRequest.Options {

    /// Convenience for passing in a custom key resolver in the request options
    ///
    /// - Parameter resolver: used to resolve the final key of the request
    /// - Returns: Request.Options object
    public static func customKeyResolver(_ resolver: AWSS3PluginCustomKeyResolver) ->
    StorageUploadFileRequest.Options {
        let pluginOptions = AWSS3PluginOptions(customKeyResolver: resolver)
        return StorageUploadFileRequest.Options(pluginOptions: pluginOptions)
    }
}

extension StorageRemoveRequest.Options {

    /// Convenience for passing in a custom key resolver in the request options
    ///
    /// - Parameter resolver: used to resolve the final key of the request
    /// - Returns: Request.Options object
    public static func customKeyResolver(_ resolver: AWSS3PluginCustomKeyResolver) ->
    StorageRemoveRequest.Options {
        let pluginOptions = AWSS3PluginOptions(customKeyResolver: resolver)
        return StorageRemoveRequest.Options(pluginOptions: pluginOptions)
    }
}

extension StorageListRequest.Options {

    /// Convenience for passing in a custom key resolver in the request options
    ///
    /// - Parameter resolver: used to resolve the final key of the request
    /// - Returns: Request.Options object
    public static func customKeyResolver(_ resolver: AWSS3PluginCustomKeyResolver) ->
    StorageListRequest.Options {
        let pluginOptions = AWSS3PluginOptions(customKeyResolver: resolver)
        return StorageListRequest.Options(pluginOptions: pluginOptions)
    }
}
