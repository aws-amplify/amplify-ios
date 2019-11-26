//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Combine

@available(iOS 13.0, *)
/// Behavior to sync mutation events to the cloud, and to subscribe to mutations from the cloud
protocol CloudSyncEngineBehavior: class {
    /// Used for testing
    typealias Factory = () -> CloudSyncEngineBehavior

    /// Start the sync process with a "delta sync" merge
    ///
    /// The order of the startup sequence is important:
    /// 1. Subscription and Mutation processing to the network are paused
    /// 1. Subscription connections are established and incoming messages are written to a queue
    /// 1. Queries are run and objects applied to the Datastore
    /// 1. Subscription processing runs off the queue and flows as normal, reconciling any items against
    ///    the updates in the Datastore
    /// 1. Mutation processor drains messages off the queue in serial and sends to the service, invoking
    ///    any local callbacks on error if necessary
    func start(api: APICategoryGraphQLBehavior, storageAdapter: StorageEngineAdapter)

    /// Submits a new mutation for synchronization to the cloud. The response will be handled by the appropriate
    /// reconciliation queue
    func submit(_ mutationEvent: MutationEvent) -> Future<MutationEvent, DataStoreError>

    /// Returns a subject used to publish mutation events received from the cloud, to downstream subscribers that
    /// publish them to the DataStore
    func asyncMutationEventSubject(for modelName: String) -> IncomingAsyncMutationEventSubject.Subject?
}
