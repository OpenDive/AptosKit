//
//  KeylessConfiguration.swift
//  AptosKit
//
//  Copyright (c) 2024 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import SwiftyJSON

/// A class which represents the on-chain configuration for how Keyless accounts work
public struct KeylessConfiguration {
    /// The verification key used to verify Groth16 proofs on chain
    public var verificationKey: Groth16VerificationKey

    /// The maximum lifespan of an ephemeral key pair.  This is configured on chain.
    public var maxExpHorizonSecs: Int

    public init(verificationKey: Groth16VerificationKey, maxExpHorizonSecs: Int) {
        self.verificationKey = verificationKey
        self.maxExpHorizonSecs = maxExpHorizonSecs
    }

    public static func create(verificationKey: JSON, maxExpHorizonSecs: Int) throws -> KeylessConfiguration {
        return try KeylessConfiguration(
            verificationKey: Groth16VerificationKey(
                alphaG1: G1Bytes(data: verificationKey["alpha_g1"].rawData()),
                betaG2: G2Bytes(data: verificationKey["beta_g2"].rawData()),
                deltaG2: G2Bytes(data: verificationKey["delta_g2"].rawData()),
                gammaAbcG1: verificationKey["gamma_abc_g1"].arrayValue.map {
                    try G1Bytes(data: $0.rawData())
                },
                gammaG2: G2Bytes(data: verificationKey["gamma_g2"].rawData())
            ),
            maxExpHorizonSecs: maxExpHorizonSecs
        )
    }
}
