//
//  SQLQuery.swift
//  LittlinkRouterPerfect
//
//  Created by Brent Royal-Gordon on 10/30/16.
//
//

import Foundation

public protocol _SQLQuery: Sequence {
    associatedtype Client: SQLClient
    
    var statement: SQLStatement { get }
    var state: Client.QueryState { get }
    var rowStates: Client.RowStateSequence { get }
}

extension _SQLQuery {
    public func columnKey<Value: SQLValue>(forName name: String, as valueType: Value.Type) throws -> SQLColumnKey<Value> {
        return try Client.columnKey(forName: name, as: valueType, for: state, statement: statement)
    }
    
    public func columnKey<Value: SQLValue>(at index: Int, as valueType: Value.Type) throws -> SQLColumnKey<Value> {
        return try Client.columnKey(at: index, as: valueType, for: state, statement: statement)
    }
    
    public var count: Int {
        return Client.count(for: state)
    }
}

extension _SQLQuery {
    public func columnKey<Value: SQLValue>(forName name: String, as valueType: Value?.Type) throws -> SQLNullableColumnKey<Value> {
        let nonnull = try columnKey(forName: name, as: Value.self)
        return SQLNullableColumnKey(index: nonnull.index, name: nonnull.name)
    }
    
    public func columnKey<Value: SQLValue>(at index: Int, as valueType: Value?.Type) throws -> SQLNullableColumnKey<Value> {
        let nonnull = try columnKey(at: index, as: Value.self)
        return SQLNullableColumnKey(index: nonnull.index, name: nonnull.name)
    }
}

extension _SQLQuery where Self: Sequence {
    /// Returns the only row in the result set. Throws if there are no rows or more 
    /// than one row.
    public func only() throws -> Iterator.Element {
        switch count {
        case 0:
            throw SQLError.noRecordsFound(statement: statement)
        case 1:
            var iterator = makeIterator()
            return iterator.next()!
        default:
            throw SQLError.extraRecordsFound(statement: statement)
        }
    }
}

// WORKAROUND: #1 Swift doesn't support `where` clauses on associated types
extension _SQLQuery where Self: Collection, Client.RowStateSequence: Collection, Client.RowStateSequence.Iterator.Element == Client.RowState {
    public typealias Index = Client.RowStateSequence.Index
    
    public var startIndex: Client.RowStateSequence.Index {
        return rowStates.startIndex
    }
    
    public var endIndex: Client.RowStateSequence.Index {
        return rowStates.endIndex
    }
    
    public func index(after i: Client.RowStateSequence.Index) -> Client.RowStateSequence.Index {
        return rowStates.index(after: i)
    }
    
    public subscript(i: Client.RowStateSequence.Index) -> SQLRow<Client> {
        return SQLRow(statement: statement, state: rowStates[i])
    }
}

// WORKAROUND: #1 Swift doesn't support `where` clauses on associated types
extension _SQLQuery where Self: BidirectionalCollection, Client.RowStateSequence: BidirectionalCollection, Client.RowStateSequence.Iterator.Element == Client.RowState {
    public func index(before i: Client.RowStateSequence.Index) -> Client.RowStateSequence.Index {
        return rowStates.index(before: i)
    }
}

// WORKAROUND: #1 Swift doesn't support `where` clauses on associated types
extension _SQLQuery where Self: RandomAccessCollection, Client.RowStateSequence: RandomAccessCollection, Client.RowStateSequence.Iterator.Element == Client.RowState {
    public func index(_ i: Client.RowStateSequence.Index, offsetBy n: Client.RowStateSequence.IndexDistance) -> Client.RowStateSequence.Index {
        return rowStates.index(i, offsetBy: n)
    }
}

// WORKAROUND: #1 Swift doesn't support `where` clauses on associated types
public struct SQLQueryRandomAccessCollection<C: SQLClient>: _SQLQuery, RandomAccessCollection where C.RowStateSequence: RandomAccessCollection, C.RowStateSequence.Iterator.Element == C.RowState {
    public typealias Client = C
    
    public let statement: SQLStatement
    public var state: Client.QueryState
    public var rowStates: Client.RowStateSequence
    
    init(statement: SQLStatement, state: Client.QueryState) {
        self.statement = statement
        self.state = state
        self.rowStates = Client.makeRowStateSequence(for: state)
    }
}

// WORKAROUND: #1 Swift doesn't support `where` clauses on associated types
public struct SQLQueryBidirectionalCollection<C: SQLClient>: _SQLQuery, BidirectionalCollection where C.RowStateSequence: BidirectionalCollection, C.RowStateSequence.Iterator.Element == C.RowState {
    public typealias Client = C
    
    public let statement: SQLStatement
    public var state: Client.QueryState
    public var rowStates: Client.RowStateSequence
    
    init(statement: SQLStatement, state: Client.QueryState) {
        self.statement = statement
        self.state = state
        self.rowStates = Client.makeRowStateSequence(for: state)
    }
}

// WORKAROUND: #1 Swift doesn't support `where` clauses on associated types
public struct SQLQueryCollection<C: SQLClient>: _SQLQuery, Collection where C.RowStateSequence: Collection, C.RowStateSequence.Iterator.Element == C.RowState {
    public typealias Client = C
    
    public let statement: SQLStatement
    public var state: Client.QueryState
    public var rowStates: Client.RowStateSequence
    
    init(statement: SQLStatement, state: Client.QueryState) {
        self.statement = statement
        self.state = state
        self.rowStates = Client.makeRowStateSequence(for: state)
    }
}

// WORKAROUND: #1 Swift doesn't support `where` clauses on associated types
public struct SQLRowIterator<Client: SQLClient>: IteratorProtocol where Client.RowStateSequence.Iterator.Element == Client.RowState {
    fileprivate var statement: SQLStatement
    fileprivate var rowStateIterator: Client.RowStateSequence.Iterator
    
    public mutating func next() -> SQLRow<Client>? {
        return rowStateIterator.next().map { SQLRow(statement: statement, state: $0) }
    }
}

// WORKAROUND: #1 Swift doesn't support `where` clauses on associated types
public struct SQLQuery<C: SQLClient>: _SQLQuery, Sequence where C.RowStateSequence.Iterator.Element == C.RowState {
    public typealias Client = C
    
    public let statement: SQLStatement
    public var state: Client.QueryState
    public var rowStates: Client.RowStateSequence
    
    init(statement: SQLStatement, state: Client.QueryState) {
        self.statement = statement
        self.state = state
        self.rowStates = Client.makeRowStateSequence(for: state)
    }
    
    public func makeIterator() -> SQLRowIterator<Client> {
        return SQLRowIterator(statement: statement, rowStateIterator: rowStates.makeIterator())
    }
}
