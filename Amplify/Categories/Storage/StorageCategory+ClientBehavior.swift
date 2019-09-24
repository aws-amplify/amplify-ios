//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//
import Foundation
extension StorageCategory: StorageCategoryClientBehavior {
    private func plugin(from selector: StoragePluginSelector) -> StorageCategoryPlugin {
        guard let key = selector.selectedPluginKey else {
            preconditionFailure(
                """
                \(String(describing: selector)) did not set `selectedPluginKey` for the function `\(#function)`
                """)
        }
        guard let plugin = try? getPlugin(for: key) else {
            preconditionFailure(
                """
                \(String(describing: selector)) set `selectedPluginKey` to \(key) for the function `\(#function)`,
                but there is no plugin added for that key.
                """)
        }
        return plugin
    }

    public func getURL(key: String,
                       options: StorageGetURLOptions?,
                       onEvent: StorageGetURLEventHandler?) -> StorageGetURLOperation {

        switch pluginOrSelector {
        case .plugin(let plugin):
            return plugin.getURL(key: key, options: options, onEvent: onEvent)
        case .selector(let selector):
            return plugin(from: selector).getURL(key: key, options: options, onEvent: onEvent)
        }
    }

    public func getURL(key: String) -> StorageGetURLOperation {
        return getURL(key: key, options: nil, onEvent: nil)
    }

    public func getURL(key: String, options: StorageGetURLOptions?) -> StorageGetURLOperation {
        return getURL(key: key, options: options, onEvent: nil)
    }

    public func getURL(key: String, onEvent: StorageGetURLEventHandler?) -> StorageGetURLOperation {
        return getURL(key: key, options: nil, onEvent: onEvent)
    }

    public func getData(key: String,
                        options: StorageGetDataOptions?,
                        onEvent: StorageGetDataEventHandler?) -> StorageGetDataOperation {

        switch pluginOrSelector {
        case .plugin(let plugin):
            return plugin.getData(key: key, options: options, onEvent: onEvent)
        case .selector(let selector):
            return plugin(from: selector).getData(key: key, options: options, onEvent: onEvent)
        }
    }

    public func getData(key: String) -> StorageGetDataOperation {
        return getData(key: key, options: nil, onEvent: nil)
    }

    public func getData(key: String, options: StorageGetDataOptions?) -> StorageGetDataOperation {
        return getData(key: key, options: options, onEvent: nil)
    }

    public func getData(key: String, onEvent: StorageGetDataEventHandler?) -> StorageGetDataOperation {
        return getData(key: key, options: nil, onEvent: onEvent)
    }

    public func downloadFile(key: String,
                             local: URL,
                             options: StorageDownloadFileOptions?,
                             onEvent: StorageDownloadFileEventHandler?) -> StorageDownloadFileOperation {

        switch pluginOrSelector {
        case .plugin(let plugin):
            return plugin.downloadFile(key: key, local: local, options: options, onEvent: onEvent)
        case .selector(let selector):
            return plugin(from: selector).downloadFile(key: key, local: local, options: options, onEvent: onEvent)
        }
    }

    public func downloadFile(key: String, local: URL) -> StorageDownloadFileOperation {
        downloadFile(key: key, local: local, options: nil, onEvent: nil)
    }

    public func downloadFile(key: String, local: URL, options: StorageDownloadFileOptions?)
        -> StorageDownloadFileOperation {
        downloadFile(key: key, local: local, options: options, onEvent: nil)
    }

    public func downloadFile(key: String, local: URL, onEvent: StorageDownloadFileEventHandler?)
        -> StorageDownloadFileOperation {
            downloadFile(key: key, local: local, options: nil, onEvent: onEvent)
    }

    public func putData(key: String,
                        data: Data,
                        options: StoragePutDataOptions?,
                        onEvent: StoragePutDataEventHandler?) -> StoragePutOperation {

        switch pluginOrSelector {
        case .plugin(let plugin):
            return plugin.putData(key: key, data: data, options: options, onEvent: onEvent)
        case .selector(let selector):
            return plugin(from: selector).putData(key: key, data: data, options: options, onEvent: onEvent)
        }
    }

    public func putData(key: String, data: Data) -> StoragePutDataOperation {
        return putData(key: key, data: data, options: nil, onEvent: nil)
    }

    public func putData(key: String, data: Data, options: StoragePutDataOptions?) -> StoragePutDataOperation {
        return putData(key: key, data: data, options: options, onEvent: nil)
    }

    public func putData(key: String, data: Data, onEvent: StoragePutDataEventHandler?) -> StoragePutDataOperation {
        return putData(key: key, data: data, options: nil, onEvent: onEvent)
    }

    public func uploadFile(key: String,
                           local: URL,
                           options: StorageUploadFileOptions?,
                           onEvent: StorageUploadFileEventHandler?) -> StoragePutOperation {

        switch pluginOrSelector {
        case .plugin(let plugin):
            return plugin.uploadFile(key: key, local: local, options: options, onEvent: onEvent)
        case .selector(let selector):
            return plugin(from: selector).uploadFile(key: key, local: local, options: options, onEvent: onEvent)
        }
    }

    public func uploadFile(key: String, local: URL) -> StorageUploadFileOperation {
        return uploadFile(key: key, local: local, options: nil, onEvent: nil)
    }

    public func uploadFile(key: String, local: URL, options: StorageUploadFileOptions?) -> StorageUploadFileOperation {
        return uploadFile(key: key, local: local, options: options, onEvent: nil)
    }

    public func uploadFile(key: String, local: URL, onEvent: StorageUploadFileEventHandler?) -> StorageUploadFileOperation {
        return uploadFile(key: key, local: local, options: nil, onEvent: onEvent)
    }

    public func remove(key: String,
                       options: StorageRemoveOptions?,
                       onEvent: StorageRemoveEventHandler?) -> StorageRemoveOperation {

        switch pluginOrSelector {
        case .plugin(let plugin):
            return plugin.remove(key: key, options: options, onEvent: onEvent)
        case .selector(let selector):
            return plugin(from: selector).remove(key: key, options: options, onEvent: onEvent)
        }
    }

    public func remove(key: String) -> StorageRemoveOperation {
        return remove(key: key, options: nil, onEvent: nil)
    }

    public func remove(key: String, options: StorageRemoveOptions?) -> StorageRemoveOperation {
        return remove(key: key, options: options, onEvent: nil)
    }

    public func remove(key: String, onEvent: StorageRemoveEventHandler?) -> StorageRemoveOperation {
        return remove(key: key, options: nil, onEvent: onEvent)
    }

    public func list(options: StorageListOptions?, onEvent: StorageListEventHandler?) -> StorageListOperation {

        switch pluginOrSelector {
        case .plugin(let plugin):
            return plugin.list(options: options, onEvent: onEvent)
        case .selector(let selector):
            return plugin(from: selector).list(options: options, onEvent: onEvent)
        }
    }

    public func list() -> StorageListOperation {
        return list(options: nil, onEvent: nil)
    }

    public func list(options: StorageListOptions?) -> StorageListOperation {
        return list(options: options, onEvent: nil)
    }

    public func list(onEvent: StorageListEventHandler?) -> StorageListOperation {
        return list(options: nil, onEvent: onEvent)
    }
}
