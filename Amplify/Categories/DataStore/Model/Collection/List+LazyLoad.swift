//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

// TODO add Combine integration: `func load() -> Future<Elements, DataStoreError>`

extension List {

    internal enum LoadState {
        case pending
        case loaded
    }

    // MARK: - Asynchronous API

    /// Trigger `DataStore` query to initialize the collection. This function always
    /// fetches data from the `DataStore.query`.
    ///
    /// - seealso: `load()`
    public func load(_ completion: DataStoreCallback<Elements>) {
        lazyLoad(completion)
    }

    internal func lazyLoad(_ completion: DataStoreCallback<Elements>) {

        // if the collection has no associated field, return the current elements
        guard let associatedId = self.associatedId,
              let associatedField = self.associatedField else {
            completion(.result(elements))
            return
        }

        // TODO resolve the correct field name in `ModelField`
        let name = "\(associatedField.name)Id"
        let predicate: QueryPredicateFactory = { field(name) == associatedId }
        Amplify.DataStore.query(Element.self, where: predicate) {
            switch $0 {
            case .result(let elements):
                self.elements = elements
                self.state = .loaded
                completion(.result(elements))
            case .error(let error):
                completion(.failure(causedBy: error))
            }
        }
    }

    // MARK: Synchronous API

    /// Trigger `DataStore` query to initialize the collection. This function always
    /// fetches data from the `DataStore.query`. However, consumers must be aware of
    /// the internal behavior which relies on `DispatchSemaphore` and will block the
    /// current `DispatchQueue` until data is ready. When operating on large result
    /// sets, prefer using the asynchronous `load(completion:)` instead.
    ///
    /// - Returns: the current instance after data was loaded.
    /// - seealso: `load(completion:)`
    public func load() -> Self {
        lazyLoad()
        return self
    }

    /// Internal function that only calls `lazyLoad()` if the `state` is not `.loaded`.
    /// - seealso: `lazyLoad()`
    internal func loadIfNeeded() {
        if state != .loaded {
            lazyLoad()
        }
    }

    /// The synchronized version of `lazyLoad(completion:)`. This function is useful so
    /// instances of `List<ModelType>` behave like any other `Collection`.
    internal func lazyLoad() {
        let semaphore = DispatchSemaphore(value: 0)
        lazyLoad {
            switch $0 {
            case .result(let elements):
                self.elements = elements
                semaphore.signal()
            case .error(let error):
                semaphore.signal()
                // TODO how to handle this failure? should it crash? just log the error?
                fatalError(error.errorDescription)
            }
        }
        semaphore.wait()
    }

}
