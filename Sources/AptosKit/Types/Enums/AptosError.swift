//
//  AptosError.swift
//  
//
//  Created by Marcus Arnett on 4/9/23.
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
    case keysCountOutOfRange(min: Int, max: Int)
    case thresholdOutOfRange(min: Int, max: Int)
    case noContentInKey
    case notImplemented
}
