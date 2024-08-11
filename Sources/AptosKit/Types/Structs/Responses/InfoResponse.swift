//
//  InfoResponse.swift
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

/// The API response to Get Info REST endpoint
public struct InfoResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case chainId = "chain_id"
        case epoch
        case ledgerVersion = "ledger_version"
        case oldestLedgerVersion = "oldest_ledger_version"
        case ledgerTimestamp = "ledger_timestamp"
        case nodeRole = "node_role"
        case oldestBlockHeight = "oldest_block_height"
        case blockHeight = "block_height"
        case gitHash = "git_hash"
    }

    /// Chain ID of the current chain
    let chainId: Int

    /// A string containing a 64-bit unsigned integer.
    let epoch: String

    /// A string containing a 64-bit unsigned integer.
    let ledgerVersion: String

    /// A string containing a 64-bit unsigned integer.
    let oldestLedgerVersion: String

    /// A string containing a 64-bit unsigned integer.
    let ledgerTimestamp: String

    let nodeRole: String

    /// A string containing a 64-bit unsigned integer.
    let oldestBlockHeight: String

    /// A string containing a 64-bit unsigned integer.
    let blockHeight: String

    /// Git hash of the build of the API endpoint. Can be used to determine the exact software version used by the API endpoint.
    let gitHash: String
}
