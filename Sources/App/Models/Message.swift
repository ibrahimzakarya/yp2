//
//  Message.swift
//  authPackageDescription
//
//  Created by Ibrahim Zakarya on 1/12/18.
//


import Vapor
import FluentProvider
import AuthProvider


final class Message: Model {
    var storage = Storage()
    var text: String
    var subject: String
    let userId: Int
    
    init(text: String, userId: Int, subject: String) {
        self.text = text
        self.userId = userId
        self.subject = subject
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("text", text)
        try row.set(User.foreignIdKey, userId)
        try row.set("subject", subject)
        return row
    }
    
    init(row: Row) throws {
        self.text = try row.get("text")
        self.subject = try row.get("subject")
        self.userId = try row.get(User.foreignIdKey)
    }
    
}

extension Message: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("text")
            builder.string("subject")
            builder.foreignId(for: User.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Message: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("id", id)
        try node.set("text", text)
        try node.set("subject", subject)
        try node.set("user_id", userId)
        
        return node
    }
}

extension Message: PasswordAuthenticatable { }
extension Message: SessionPersistable { }
extension Message: Timestampable { }


