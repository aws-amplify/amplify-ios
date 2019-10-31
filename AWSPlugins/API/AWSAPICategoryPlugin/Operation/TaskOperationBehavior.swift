//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

/// Methods to interact with the underlying operation triggered on task callbacks
/// TODO: Possible renaming/refactoring
protocol TaskOperationBehavior {

    /// Get the operation's unique identifier
    func getOperationId() -> UUID

    /// Signal the operation on progress of new data from the data task
    func updateProgress(_ data: Data)

    /// Signal on completion of the data task
    func complete(with error: Error?)

    /// Signal the operation to be cancelled when the task is terminateds
    func cancelOperation()
}
