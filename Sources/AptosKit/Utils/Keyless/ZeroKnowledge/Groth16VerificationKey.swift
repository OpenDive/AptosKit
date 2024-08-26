//
//  Groth16VerificationKey.swift
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

/// A representation of the verification key stored on chain used to verify Groth16 proofs
public struct Groth16VerificationKey {
    /// The `alpha * G`, where `G` is the generator of G1
    public var alphaG1: G1Bytes

    /// The `alpha * H`, where `H` is the generator of G2
    public var betaG2: G2Bytes

    /// The `delta * H`, where `H` is the generator of G2
    public var deltaG2: G2Bytes

    /// The `gamma^{-1} * (beta * a_i + alpha * b_i + c_i) * H`, where H is the generator of G1
    public var gammaAbcG1: [G1Bytes]

    /// The `gamma * H`, where `H` is the generator of G2
    public var gammaG2: G2Bytes

    public init(
        alphaG1: G1Bytes,
        betaG2: G2Bytes,
        deltaG2: G2Bytes,
        gammaAbcG1: [G1Bytes],
        gammaG2: G2Bytes
    ) {
        self.alphaG1 = alphaG1
        self.betaG2 = betaG2
        self.deltaG2 = deltaG2
        self.gammaAbcG1 = gammaAbcG1
        self.gammaG2 = gammaG2
    }
}
