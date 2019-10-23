//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify

final public class AWSAPIGetOperation: AmplifyOperation<APIGetRequest,
    Void,
    Data,
    APIError
    >,
APIGetOperation {

    static let timeout = TimeInterval(120)

    var task: HTTPTransportTask?

    init(request: APIGetRequest,
         httpTransport: HTTPTransport,
         listener: AWSAPIGetOperation.EventListener?) {
        super.init(categoryType: .api,
                   eventName: HubPayload.EventName.API.get,
                   request: request,
                   listener: listener)

    }

    func get(using httpTransport: HTTPTransport) {
//        let urlRequest = URLRequest(url: request.url,
//                                    cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData,
//                                    timeoutInterval: AWSAPIGetOperation.timeout)
    }
}

/// Maps APIOperations to HTTPTransportTasks, providing convenience methods for accessing them
struct OperationTaskMapper {
}

//extension AWSAPICategoryPlugin: HTTPTransportTaskDelegate {
//    func task(_ httpTransportTask: HTTPTransportTask, didReceiveData data: Data) {
//        let event = Event.completed(data)
//        dispatch(event: event)
//    }
//}
//
//extension AWSAPICategoryPlugin {
//    func getURL(for request: APIGetRequest) {
//
//    }
//}
