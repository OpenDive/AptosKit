//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/11/23.
//

import Foundation

public protocol TransactionProtocol: KeyProtocol {
    var tyArgs: [TypeTag] { get set }
}
