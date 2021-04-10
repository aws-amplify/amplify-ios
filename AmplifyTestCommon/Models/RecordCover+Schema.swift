//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

// swiftlint:disable all
import Foundation
import Amplify

extension RecordCover {
  // MARK: - CodingKeys
   public enum CodingKeys: String, ModelKey {
    case id
    case artist
    case createdAt
    case updatedAt
  }

  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema

  public static let schema = defineSchema { model in
    let recordCover = RecordCover.keys

    model.pluralName = "RecordCovers"

    model.fields(
        .id(),
        .field(recordCover.artist, is: .required, ofType: .string),
        .field(recordCover.createdAt, is: .optional, access: .readOnly, ofType: .dateTime),
        .field(recordCover.updatedAt, is: .optional, access: .readOnly, ofType: .dateTime)
        )
    }
}
