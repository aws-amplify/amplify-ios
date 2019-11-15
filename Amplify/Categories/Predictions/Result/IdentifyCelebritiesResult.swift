//
//  IdentifyFacesResult.swift
//  Amplify
//
//  Created by Stone, Nicki on 11/8/19.
//

public struct IdentifyCelebritiesResult: IdentifyResult {
    public let celebrities: [Celebrity]

    public init(celebrities: [Celebrity]) {
        self.celebrities = celebrities
    }
}
