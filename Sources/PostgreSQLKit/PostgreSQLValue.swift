//
//  PostgreSQLValue.swift
//  LittlinkRouterPerfect
//
//  Created by Brent Royal-Gordon on 12/3/16.
//
//

import Foundation
import SQLKit
import CorePostgreSQL

protocol _PGValueConvertible {
    var anyPGValue: PGValue { get }
}

protocol PGValueConvertible: _PGValueConvertible {
    associatedtype Value: PGValue
    
    init(pgValue value: Value) throws
    var pgValue: Value { get }
}

extension PGValueConvertible {
    init(rawPGValue rawValue: PGRawValue) throws {
        let value = try Value(rawPGValue: rawValue)
        try self.init(pgValue: value)
    }
    
    var anyPGValue: PGValue {
        return pgValue
    }
}

extension SQLValue {
    static func checkPGValueCompatibility() throws {
        switch Self.self {
        case is PGValue.Type:
            return
            
        case is PGValueConvertible.Type:
            return
            
        case is SQLStringConvertible.Type:
            return
            
        default:
            throw SQLValueError.typeUnsupportedByClient(valueType: self, client: PostgreSQL.self)
        }
    }
    
    init(rawPGValueForSQLKit rawValue: PGRawValue) throws {
        switch Self.self {
        case let selfType as PGValue.Type:
            self = try selfType.init(rawPGValue: rawValue) as! Self
        
        case let valueConvertibleType as PGValueConvertible.Type:
            self = try valueConvertibleType.init(rawPGValue: rawValue) as! Self
            
        case let stringConvertibleType as SQLStringConvertible.Type:
            let string = try String(rawPGValue: rawValue)
            self = try stringConvertibleType.init(sqlLiteral: string) as! Self
            
        default:
            throw SQLValueError.typeUnsupportedByClient(valueType: Self.self, client: PostgreSQL.self)
        }
    }
    
    func toPGValueForSQLKit() throws -> PGValue {
        switch self {
        case let pgValue as PGValue:
            return pgValue
            
        case let valueConvertible as _PGValueConvertible:
            return valueConvertible.anyPGValue
        
        case let stringConvertible as SQLStringConvertible:
            return stringConvertible.sqlLiteral
            
        default:
            throw SQLValueError.typeUnsupportedByClient(valueType: Self.self, client: PostgreSQL.self)
        }
    }
}

extension Date: PGValueConvertible {
    init(pgValue value: PGTimestamp) throws {
        guard let date = Date(value) else {
            throw PostgreSQLKitError.invalidDate(value)
        }
        self = date
    }
    
    var pgValue: PGTimestamp {
        return PGTimestamp(self)
    }
}
