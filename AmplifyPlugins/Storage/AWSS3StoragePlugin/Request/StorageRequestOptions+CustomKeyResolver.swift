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
    public static func customPrefixResolver(
        _ resolver: AWSS3PluginCustomPrefixResolver) -> StorageGetURLRequest.Options {
        let pluginOptions = AWSS3PluginOptions(customPrefixResolver: resolver)
        return StorageGetURLRequest.Options(pluginOptions: pluginOptions)
    }
}

extension StorageDownloadDataRequest.Options {

    /// Convenience for passing in a custom key resolver in the request options
    ///
    /// - Parameter resolver: used to resolve the final key of the request
    /// - Returns: Request.Options object
    public static func customKeyResolver(_ resolver: AWSS3PluginCustomPrefixResolver) ->
    StorageDownloadDataRequest.Options {
        let pluginOptions = AWSS3PluginOptions(customPrefixResolver: resolver)
        return StorageDownloadDataRequest.Options(pluginOptions: pluginOptions)
    }
}

extension StorageDownloadFileRequest.Options {

    /// Convenience for passing in a custom key resolver in the request options
    ///
    /// - Parameter resolver: used to resolve the final key of the request
    /// - Returns: Request.Options object
    public static func customKeyResolver(_ resolver: AWSS3PluginCustomPrefixResolver) ->
    StorageDownloadFileRequest.Options {
        let pluginOptions = AWSS3PluginOptions(customPrefixResolver: resolver)
        return StorageDownloadFileRequest.Options(pluginOptions: pluginOptions)
    }
}

extension StorageUploadDataRequest.Options {

    /// Convenience for passing in a custom key resolver in the request options
    ///
    /// - Parameter resolver: used to resolve the final key of the request
    /// - Returns: Request.Options object
    public static func customKeyResolver(_ resolver: AWSS3PluginCustomPrefixResolver) ->
    StorageUploadDataRequest.Options {
        let pluginOptions = AWSS3PluginOptions(customPrefixResolver: resolver)
        return StorageUploadDataRequest.Options(pluginOptions: pluginOptions)
    }
}

extension StorageUploadFileRequest.Options {

    /// Convenience for passing in a custom key resolver in the request options
    ///
    /// - Parameter resolver: used to resolve the final key of the request
    /// - Returns: Request.Options object
    public static func customKeyResolver(_ resolver: AWSS3PluginCustomPrefixResolver) ->
    StorageUploadFileRequest.Options {
        let pluginOptions = AWSS3PluginOptions(customPrefixResolver: resolver)
        return StorageUploadFileRequest.Options(pluginOptions: pluginOptions)
    }
}

extension StorageRemoveRequest.Options {

    /// Convenience for passing in a custom key resolver in the request options
    ///
    /// - Parameter resolver: used to resolve the final key of the request
    /// - Returns: Request.Options object
    public static func customKeyResolver(_ resolver: AWSS3PluginCustomPrefixResolver) ->
    StorageRemoveRequest.Options {
        let pluginOptions = AWSS3PluginOptions(customPrefixResolver: resolver)
        return StorageRemoveRequest.Options(pluginOptions: pluginOptions)
    }
}

extension StorageListRequest.Options {

    /// Convenience for passing in a custom key resolver in the request options
    ///
    /// - Parameter resolver: used to resolve the final key of the request
    /// - Returns: Request.Options object
    public static func customKeyResolver(_ resolver: AWSS3PluginCustomPrefixResolver) ->
    StorageListRequest.Options {
        let pluginOptions = AWSS3PluginOptions(customPrefixResolver: resolver)
        return StorageListRequest.Options(pluginOptions: pluginOptions)
    }
}
