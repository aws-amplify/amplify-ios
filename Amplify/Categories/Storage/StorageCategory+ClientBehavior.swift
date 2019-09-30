//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension StorageCategory: StorageCategoryClientBehavior {
    public func getURL(key: String,
                       options: StorageGetURLRequest.Options? = nil,
                       onEvent: StorageGetURLOperation.EventListener?) -> StorageGetURLOperation {
        return plugin.getURL(key: key, options: options, onEvent: onEvent)
    }

    public func getData(key: String,
                        options: StorageGetDataRequest.Options? = nil,
                        onEvent: StorageGetDataOperation.EventListener?) -> StorageGetDataOperation {
        return plugin.getData(key: key, options: options, onEvent: onEvent)
    }

    public func downloadFile(key: String,
                             local: URL,
                             options: StorageDownloadFileRequest.Options? = nil,
                             onEvent: StorageDownloadFileOperation.EventListener?) -> StorageDownloadFileOperation {
        return plugin.downloadFile(key: key, local: local, options: options, onEvent: onEvent)
    }

    public func put(key: String,
                    data: Data,
                    options: StoragePutRequest.Options? = nil,
                    onEvent: StoragePutOperation.EventListener?) -> StoragePutOperation {
        return plugin.put(key: key, data: data, options: options, onEvent: onEvent)
    }

    public func put(key: String,
                    local: URL,
                    options: StoragePutRequest.Options? = nil,
                    onEvent: StoragePutOperation.EventListener?) -> StoragePutOperation {
        return plugin.put(key: key, local: local, options: options, onEvent: onEvent)
    }

    public func remove(key: String,
                       options: StorageRemoveRequest.Options? = nil,
                       onEvent: StorageRemoveOperation.EventListener?) -> StorageRemoveOperation {
        return plugin.remove(key: key, options: options, onEvent: onEvent)
    }

    public func list(options: StorageListRequest.Options? = nil,
                     onEvent: StorageListOperation.EventListener?) -> StorageListOperation {
        return plugin.list(options: options, onEvent: onEvent)
    }
}
