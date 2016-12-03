//
//  Error.swift
//  LittlinkRouterPerfect
//
//  Created by Brent Royal-Gordon on 12/3/16.
//
//

import Foundation

public protocol PGConversionErrorParsingState {
    
}

public enum PGConversionError: Error {
    case invalidNumber(String)
    
    case invalidDate(underlying: Error, at: String.Index, in: String)
    case unexpectedDateCharacter(Character, during: PGConversionErrorParsingState)
    case nonexistentDate(DateComponents)
    case unexpectedCharacter(Character, during: PGConversionErrorParsingState)
    case invalidTimeZoneOffset(Int)
    case earlyTermination(during: PGConversionErrorParsingState)
    
    case invalidInterval(Error, at: String.Index, in: String, during: PGConversionErrorParsingState)
    case redundantQuantity(oldValue: Int, newValue: Int, for: PGInterval.Component)
    case unitlessQuantity(Int)
}
