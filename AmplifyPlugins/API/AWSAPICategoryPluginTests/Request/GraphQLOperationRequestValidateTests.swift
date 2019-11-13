//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import Amplify
@testable import AWSAPICategoryPlugin

class GraphQLOperationRequestValidateTests: XCTestCase {

    let testApiName = "testApiName"
    let testDocument = "testDocument"

    func testGraphQLOperationRequestValidate() {
        let graphQLOperationRequest = GraphQLOperationRequest(apiName: testApiName,
                                                     operationType: .mutation,
                                                     document: testDocument,
                                                     responseType: String.self,
                                                     options: GraphQLOperationRequest.Options())
        let result = graphQLOperationRequest.validate()

        XCTAssertNil(result)
    }
}
