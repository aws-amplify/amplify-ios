//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

/// Note that although this is public, it is intended for internal use and not consumed directly by host applications.
/// Implement dynamic access to properties of a `Model`.
///
/// ```swift
/// let id = model["id"]
/// ```
extension AnyModel {

    public subscript(_ key: String) -> Any? {
        let mirror = Mirror(reflecting: instance)
        let property = mirror.children.first { $0.label == key }
        return property?.value
    }

    public subscript(_ key: CodingKey) -> Any? {
        return self[key.stringValue]
    }

}