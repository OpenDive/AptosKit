//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/19/23.
//

import Foundation

public struct AnyTransactionArgument {
    private let _encode: () throws -> Data

    public init<T: EncodingContainer>(_ base: TransactionArgument<T>) {
        _encode = base.encode
    }

    public func encode() throws -> Data {
        return try _encode()
    }
}
