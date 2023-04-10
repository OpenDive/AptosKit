//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public protocol AuthenticatorProtocol: KeyProtocol {
    func verify(_ data: Data) throws -> Bool
    
    func isEqualTo(_ rhs: any AuthenticatorProtocol) -> Bool
}
