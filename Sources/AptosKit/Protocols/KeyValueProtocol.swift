//
//  File.swift
//  
//
//  Created by Marcus Arnett on 3/18/24.
//

import Foundation

/// Represents what type of type the key's data is going to be,
public protocol KeyValueProtocol {
    /// Get the type of data used for the key's data.
    /// - Returns: A `DataType` enum.
    func getType() -> DataType
}

/// Represents generic `Data` object.
extension Data: KeyValueProtocol {
    public func getType() -> DataType { return .data }
}

extension Array: KeyValueProtocol {
    public func getType() -> DataType { return .multisig }
}

/// `DataType` represents the type of data being dealt with.
///
/// - `data`: Represents generic data.
/// - `secKey`: Represents a security key.
public enum DataType {
    /// Represents generic `Data` object.
    case data

    /// Represents a multisig key.
    case multisig
}
