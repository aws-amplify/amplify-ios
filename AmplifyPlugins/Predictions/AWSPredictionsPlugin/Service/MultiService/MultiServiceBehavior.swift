//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify

protocol MultiServiceBehavior: class {

    associatedtype ServiceResult

    /// Fetch the result from the offline service
    /// - Parameter callback: Result is send back to the caller
    func fetchOfflineResult(callback: @escaping (PredictionsEvent<ServiceResult, PredictionsError>) -> Void)

    /// Fetch the result from the online service
    /// - Parameter callback: Result is send back to the caller
    func fetchOnlineResult(callback: @escaping (PredictionsEvent<ServiceResult, PredictionsError>) -> Void)

    /// Fetch the result with multi service.
    /// - Parameter callback: Result is send back to the caller
    func fetchMultiServiceResult(callback: @escaping (PredictionsEvent<ServiceResult, PredictionsError>) -> Void)

    func combineResults(offlineResult: ServiceResult?,
                        onlineResult: ServiceResult?,
                        callback:  @escaping (PredictionsEvent<ServiceResult, PredictionsError>) -> Void)

}

extension MultiServiceBehavior {

    func fetchMultiServiceResult(callback: @escaping (PredictionsEvent<ServiceResult, PredictionsError>) -> Void) {

        invokeMultiServiceCalls { multiServiceEvent in
            switch multiServiceEvent {
            case .success(let mutliRespose):
                combineResults(offlineResult: mutliRespose.offlineResult,
                               onlineResult: mutliRespose.onlineResult,
                               callback: callback)
            case .failure(let error):
                callback(.failed(error))
            }
        }
    }

    /// Method that fetch result from offline and online service
    func invokeMultiServiceCalls(callback: (Result<MultiServiceResponse<ServiceResult>, PredictionsError>) -> Void) {

        // Use dispatch group to synchronize two parallel calls for offline and online service
        let dispatchGroup = DispatchGroup()

        var offlineResult: ServiceResult?
        var offlineError: PredictionsError?
        var onlineResult: ServiceResult?
        var onlineError: PredictionsError?

        dispatchGroup.enter()
        fetchOfflineResult { event in
            switch event {
            case .completed(let result):
                offlineResult = result
            case .failed(let error):
                offlineError = error
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        fetchOnlineResult { event in
            switch event {
            case .completed(let result):
                onlineResult = result
            case .failed(let error):
                onlineError = error
            }
            dispatchGroup.leave()
        }
        dispatchGroup.wait()

        //TODO: Define what error to send back if both service returned an error
        if offlineError != nil && onlineError != nil {
            callback(.failure(onlineError!))
        }
        let multiResponse = MultiServiceResponse(onlineResult: onlineResult, offlineResult: offlineResult)
        callback(.success(multiResponse))
    }

}

struct MultiServiceResponse<ServiceResult> {
    let onlineResult: ServiceResult?
    let offlineResult: ServiceResult?
}
