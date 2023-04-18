//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/12/23.
//

import Foundation

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
    
    let chainId: Int
    let epoch: String
    let ledgerVersion: String
    let oldestLedgerVersion: String
    let ledgerTimestamp: String
    let nodeRole: String
    let oldestBlockHeight: String
    let blockHeight: String
    let gitHash: String
}
