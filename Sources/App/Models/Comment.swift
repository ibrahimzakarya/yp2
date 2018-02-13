//
//  Comment.swift
//  authPackageDescription
//
//  Created by Ibrahim Zakarya on 1/12/18.
//


import Vapor
import FluentProvider
import AuthProvider


final class Comment: Model {
    var storage = Storage()
    var text: String
    let userId: Int
    let placeId: Int
    
    init(text: String, userId: Int, placeId: Int) {
        self.text = text
        self.userId = userId
        self.placeId = placeId
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("text", text)
        try row.set(User.foreignIdKey, userId)
        try row.set(Place.foreignIdKey, placeId)
        return row
    }
    
    init(row: Row) throws {
        self.text = try row.get("text")
        self.userId = try row.get(User.foreignIdKey)
        self.placeId = try row.get(Place.foreignIdKey)
    }
    
}

extension Comment: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("text")
            builder.foreignId(for: User.self)
            builder.foreignId(for: Place.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Comment: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("id", id)
        try node.set("text", text)
        try node.set("created", createdAt)
        guard let user = try User.find(userId) else { return Node(context) }
        guard let place = try Place.find(placeId) else { return Node(context) }
        try node.set("user_fullname", user.fullname)
        try node.set("place_name", place.name)
        
        return node
    }
}

extension Comment: PasswordAuthenticatable { }
extension Comment: SessionPersistable { }
extension Comment: Timestampable { }

