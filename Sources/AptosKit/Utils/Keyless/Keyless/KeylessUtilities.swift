//
//  KeylessUtilities.swift
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

public struct KeylessUtilities {
    public static let EPK_HORIZON_SECS = 10000000
    public static let MAX_AUD_VAL_BYTES = 120
    public static let MAX_UID_KEY_BYTES = 30
    public static let MAX_UID_VAL_BYTES = 330
    public static let MAX_ISS_VAL_BYTES = 120
    public static let MAX_EXTRA_FIELD_BYTES = 350
    public static let MAX_JWT_HEADER_B64_BYTES = 300
    public static let MAX_COMMITED_EPK_BYTES = 93

    public static func computeIdCommitment(
        _ uidkey: String,
        _ uidVal: String,
        _ aud: String,
        _ pepper: Data
    ) throws -> Data {
        let fields = try [
            PoseidonUtilities.bytesToBigIntLE(bytes: pepper.bytes),
            PoseidonUtilities.hashStrToField(aud, maxSizeBytes: Self.MAX_AUD_VAL_BYTES),
            PoseidonUtilities.hashStrToField(uidVal, maxSizeBytes: Self.MAX_UID_VAL_BYTES),
            PoseidonUtilities.hashStrToField(uidkey, maxSizeBytes: Self.MAX_UID_KEY_BYTES)
        ]
        return try Data(
            PoseidonUtilities.bigIntToBytesLE(
                value: PoseidonUtilities.poseidonHash(inputs: fields),
                length: KeylessPublicKey.ID_COMMITMENT_LENGTH
            )
        )
    }
}
