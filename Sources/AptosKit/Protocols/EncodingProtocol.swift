//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/14/23.
//

import Foundation
import UInt256

public protocol EncodingProtocol { }

extension UInt8: EncodingProtocol { }
extension UInt16: EncodingProtocol { }
extension UInt32: EncodingProtocol { }
extension UInt64: EncodingProtocol { }
extension UInt128: EncodingProtocol { }
extension UInt256: EncodingProtocol { }
extension Int: EncodingProtocol { }
extension UInt: EncodingProtocol { }

extension Bool: EncodingProtocol { }
extension String: EncodingProtocol { }
extension Data: EncodingProtocol { }
