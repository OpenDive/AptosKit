//
//  PoseidonUtilities.swift
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
import BigInt

public struct PoseidonUtilities {
    public static let BYTES_PACKED_PER_SCALAR = 31
    public static let MAX_NUM_INPUT_SCALARS = 16

    public static let MAX_NUM_INPUT_BYTES =
        (Self.MAX_NUM_INPUT_SCALARS - 1) * Self.BYTES_PACKED_PER_SCALAR

    private static let poseidonNumToHashFN: [any Poseidon] = [
        Poseidon1(),
        Poseidon2(),
        Poseidon3(),
        Poseidon4(),
        Poseidon5(),
        Poseidon6(),
        Poseidon7(),
        Poseidon8(),
        Poseidon9(),
        Poseidon10(),
        Poseidon11(),
        Poseidon12(),
        Poseidon13(),
        Poseidon14(),
        Poseidon15(),
        Poseidon16()
    ]

    public static func poseidonHash(inputs: [BigInt]) throws -> BigInt {
        let idx = inputs.count - 1
        guard (idx >= 0 && idx < (poseidonNumToHashFN.count - 1)) else {
            if inputs.count <= 32 {
                let hash1 = try Self.poseidonHash(inputs: Array(inputs.prefix(upTo: 16)))
                let hash2 = try Self.poseidonHash(inputs: Array(inputs.suffix(from: 16)))
                return try Self.poseidonHash(inputs: [hash1, hash2])
            }
            throw AptosError.notImplemented
        }
        let hashFN = Self.poseidonNumToHashFN[inputs.count - 1]
        return try hashFN.poseidon(inputs: inputs)
    }

    /// Function to hash a string to a field element via Poseidon
    public static func hashStrToField(_ str: String, maxSizeBytes: Int) throws -> BigInt {
        let strBytes = Array(str.utf8)
        return try Self.hashBytesWithLen(bytes: strBytes, maxSizeBytes: maxSizeBytes)
    }

    public static func hashBytesWithLen(bytes: [UInt8], maxSizeBytes: Int) throws -> BigInt {
        try PoseidonUtilities.checkByteLength(withInputtedLength: bytes.count, andMaximum: maxSizeBytes)
        let packed = try PoseidonUtilities.padAndPackBytesWithLen(bytes: bytes, maxSizeBytes: maxSizeBytes)
        return try Self.poseidonHash(inputs: packed)
    }

    public static func padAndPackBytesNoLen(bytes: [UInt8], maxSizeBytes: Int) throws -> [BigInt] {
        try Self.checkByteLength(withInputtedLength: bytes.count, andMaximum: maxSizeBytes)
        let paddedStrBytes = try Self.padUint8ArrayWithZeros(inputArray: bytes, paddedSize: maxSizeBytes)
        return try Self.packBytes(bytes: paddedStrBytes)
    }

    public static func padAndPackBytesWithLen(bytes: [UInt8], maxSizeBytes: Int) throws -> [BigInt] {
        try Self.checkByteLength(withInputtedLength: bytes.count, andMaximum: maxSizeBytes)
        return try Self.padAndPackBytesNoLen(bytes: bytes, maxSizeBytes: maxSizeBytes) + [BigInt(bytes.count)]
    }

    public static func packBytes(bytes: [UInt8]) throws -> [BigInt] {
        if bytes.count > MAX_NUM_INPUT_BYTES {
            throw AptosError.packedBytesExceeded(length: bytes.count, maximum: Self.MAX_NUM_INPUT_BYTES)
        }
        return Self.chunkUint8Array(array: bytes, chunkSize: BYTES_PACKED_PER_SCALAR).map { Self.bytesToBigIntLE(bytes: $0) }
    }

    public static func chunkUint8Array(array: [UInt8], chunkSize: Int) -> [[UInt8]] {
        var result: [[UInt8]] = []
        for i in stride(from: 0, to: array.count, by: chunkSize) {
            let end = min(i + chunkSize, array.count)
            result.append(Array(array[i..<end]))
        }
        return result
    }

    public static func bytesToBigIntLE(bytes: [UInt8]) -> BigInt {
        var result = BigInt(0)
        for byte in bytes.reversed() {
            result = (result << 8) | BigInt(byte)
        }
        return result
    }

    public static func bigIntToBytesLE(value: BigInt, length: Int) -> [UInt8] {
        var result = value
        var bytes = [UInt8](repeating: 0, count: length)
        for i in 0..<length {
            bytes[i] = UInt8(result & 0xff)
            result >>= 8
        }
        return bytes
    }

    public static func padUint8ArrayWithZeros(inputArray: [UInt8], paddedSize: Int) throws -> [UInt8] {
        if paddedSize < inputArray.count {
            throw AptosError.padSizeError(expectedMoreThan: inputArray.count, actual: paddedSize)
        }

        var paddedArray = [UInt8](repeating: 0, count: paddedSize)
        for i in 0..<inputArray.count {
            paddedArray[i] = inputArray[i]
        }
        return paddedArray
    }

    private static func checkByteLength(withInputtedLength input: Int, andMaximum max: Int) throws {
        guard input <= max else {
            throw AptosError.byteSizeExceeded(length: input, maximum: max)
        }
    }
}
