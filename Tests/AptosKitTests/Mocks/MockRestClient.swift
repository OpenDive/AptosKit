//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/17/23.
//

import Foundation
import SwiftyJSON
@testable import AptosKit

public struct MockRestClient: AptosKitProtocol {
    func getDecodedData<T: Decodable>(_ type: T.Type = T.self, with jsonData: String) async throws -> T {
        guard let url = Bundle.test.url(forResource: jsonData, withExtension: "json") else {
            throw NSError(domain: "Getting Url for bundle has failed.", code: -1)
        }

        guard let data = try? Data(contentsOf: url) else {
            throw NSError(domain: "Setting data using contents of url has failed.", code: -1)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        guard let result = try? decoder.decode(T.self, from: data) else {
            throw NSError(domain: "Decoding data has failed.", code: -1)
        }

        return result
    }
    
    public func account(_ accountAddress: AccountAddress, ledgerVersion: Int? = nil) async throws -> AccountResponse {
        if accountAddress.address.hexEncodedString() == "9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d" {
            return AccountResponse(sequenceNumber: "1", authenticationKey: "0x9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d")
        } else {
            throw NSError(domain: "Incorrect Formatting for AccountAddress.", code: -1)
        }
    }
    
    public func accountBalance(_ accountAddress: AccountAddress, _ ledgerVersion: Int? = nil) async throws -> Int {
        if accountAddress.address.hexEncodedString() == "9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d" {
            return 647362
        } else {
            throw NSError(domain: "Incorrect Formatting for AccountAddress.", code: -1)
        }
    }
    
    public func accountSequenceNumber(_ accountAddress: AccountAddress, _ ledgerVersion: Int? = nil) async throws -> Int {
        if accountAddress.address.hexEncodedString() == "9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d" {
            return 1
        } else {
            throw NSError(domain: "Incorrect Formatting for AccountAddress.", code: -1)
        }
    }
    
    public func accountResource(_ accountAddress: AccountAddress, _ resourceType: String, _ ledgerVersion: Int? = nil) async throws -> JSON {
        return try await getDecodedData(with: "AccountResource") as JSON
    }
    
    public func getTableItem(_ handle: String, _ keyType: String, _ valueType: String, _ key: any EncodingProtocol, _ ledgerVersion: Int? = nil) async throws -> JSON {
        guard let key = key as? String else {
            throw NSError(domain: "Key is not a string value.", code: -1)
        }
        
        if key == "0x619dc29a0aac8fa146714058e8dd6d2d0f3bdf5f6331907bf91f3acd81e6935" {
            return 102994413849650711
        } else {
            throw NSError(domain: "Incorrect Formatting for Key.", code: -1)
        }
    }
    
    public func aggregatorValue(_ accountAddress: AccountAddress, _ resourceType: String, _ aggregatorPath: [String]) async throws -> Int {
        throw NSError(domain: "Not implemented.", code: -1)
    }
}
