//
//  Error.swift
//  LittlinkRouterPerfect
//
//  Created by Brent Royal-Gordon on 12/3/16.
//
//

import Foundation

public protocol PGConversionParsingState {
    var localizedStateDescription: String { get }
}

public enum PGConversionError: Error {
    case invalidNumber(String)
    
    case invalidDate(Error, at: String.Index, in: String, during: PGConversionParsingState)
    case unexpectedCharacter(Character)
    case invalidTimeZoneOffset(Int)
    case earlyTermination
    
    case invalidInterval(Error, at: String.Index, in: String, during: PGConversionParsingState)
    case redundantQuantity(oldValue: Int, newValue: Int, for: PGInterval.Component)
    case unitlessQuantity(Int)
}
