//
//  AptosError.swift
//  AptosKit
//
//  Copyright (c) 2023 OpenDive
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

public enum AptosError: Swift.Error {
    case other(String)
    case invalidDataValue(supportedType: String)
    case doesNotConformTo(protocolType: String)
    case unexpectedValue(value: String)
    case stringToDataFailure(value: String)
    case stringToUInt256Failure(value: String)
    case unexpectedLargeULEB128Value(value: String)
    case unexpectedEndOfInput(requested: String, found: String)
    case invalidLength
    case lengthMismatch
    case invalidPublicKey
    case invalidSeedLength
    case keysCountOutOfRange(min: Int, max: Int)
    case thresholdOutOfRange(min: Int, max: Int)
    case noContentInKey
    case notImplemented
    case invalidTransactionType
    case invalidVariant
    case invalidUrl(url: String)
    case seedModeIncompatibleWithEd25519Bip32BasedSeeds(seedMode: String)
    case invalidAddressLength
    case aggregatorPathNotFound(path: String)
    case couldNotDecodeKey(key: String)
    case invalidSequenceNumber
    case transactionTimedOut(hash: String)
}
