//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import AWSS3
import Amplify

public typealias UploadTaskCreatedHandler = (AWSTask<AWSS3TransferUtilityUploadTask>) -> Any?

extension AWSS3StorageService {

    func upload(serviceKey: String,
                uploadSource: StoragePutRequest.Source,
                contentType: String?,
                metadata: [String: String]?,
                onEvent: @escaping StorageServiceUploadEventHandler) {

        let uploadTaskCreatedHandler = AWSS3StorageService.makeUploadTaskCreatedHandler(onEvent: onEvent)
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = AWSS3StorageService.makeOnUploadProgressHandler(onEvent: onEvent)

        if let metadata = metadata {
            for (key, value) in metadata {
                expression.setValue(value, forRequestHeader: key)
            }
        }

        // TODO: Implement tagging functionality, got 403 on tagging using below code
        //expression.setValue("Project=blue&Classification=confidential", forRequestHeader: "x-amz-tagging")

        let onUploadCompletedHandler = AWSS3StorageService.makeUploadCompletedHandler(onEvent: onEvent)

        switch uploadSource {
        case .data(let data):
            transferUtility.uploadData(data: data,
                                       bucket: bucket,
                                       key: serviceKey,
                                       contentType: contentType ?? "application/octet-stream",
                                       expression: expression,
                                       completionHandler: onUploadCompletedHandler)
                .continueWith(block: uploadTaskCreatedHandler)
        case .local(let fileURL):
            transferUtility.uploadFile(fileURL: fileURL,
                                       bucket: bucket,
                                       key: serviceKey,
                                       contentType: contentType ?? "application/octet-stream",
                                       expression: expression,
                                       completionHandler: onUploadCompletedHandler)
                .continueWith(block: uploadTaskCreatedHandler)
        }
    }

    private static func makeUploadTaskCreatedHandler(
        onEvent: @escaping StorageServiceUploadEventHandler) -> UploadTaskCreatedHandler {

        let block: UploadTaskCreatedHandler = { (task: AWSTask<AWSS3TransferUtilityUploadTask>) -> Any? in
            guard task.error == nil else {
                let error = task.error! as NSError
                let storageErrorString = StorageErrorHelper.mapTransferUtilityError(error)
                onEvent(StorageEvent.failed(StorageError.service(storageErrorString.errorDescription,
                                                                    storageErrorString.recoverySuggestion)))

                return nil
            }

            guard let uploadTask = task.result else {
                onEvent(StorageEvent.failed(StorageError.unknown("No ContinuationBlock data", "")))
                return nil
            }

            onEvent(StorageEvent.initiated(StorageTaskReference(uploadTask)))
            return nil
        }

        return block
    }

    private static func makeOnUploadProgressHandler(
        onEvent: @escaping StorageServiceUploadEventHandler) -> AWSS3TransferUtilityProgressBlock {
            let block: AWSS3TransferUtilityProgressBlock = {(task, progress) in
                onEvent(StorageEvent.inProcess(progress))
            }

            return block
    }

    private static func makeUploadCompletedHandler(onEvent: @escaping StorageServiceUploadEventHandler)
        -> AWSS3TransferUtilityUploadCompletionHandlerBlock {

        let block: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (task, error ) -> Void in
            guard let response = task.response else {
                onEvent(StorageEvent.failed(StorageError.unknown("Missing HTTP Status", "")))
                return
            }

            guard response.statusCode == 200 else {
                //StorageErrorHelper.mapHttpResponse(response.statusCode)
                onEvent(StorageEvent.failed(StorageError.httpStatusError(
                    "status code \(response.statusCode)", "Check the status code")))
                return
            }

            guard error == nil else {
                let error = error! as NSError
                onEvent(StorageEvent.failed(StorageError.unknown("Error with code: \(error.code) ", "")))
                return
            }

            onEvent(StorageEvent.completed(()))
        }

        return block
    }
}
