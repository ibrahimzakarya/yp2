//
//  Favorite.swift
//  authPackageDescription
//
//  Created by Ibrahim Zakarya on 2/16/18.
//


import Vapor
import FluentProvider
import AuthProvider


final class Favorite: Model {
    var storage = Storage()
    let userId: Int
    let placeId: Int
    
    init(userId: Int, placeId: Int) {
        self.userId = userId
        self.placeId = placeId
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.foreignIdKey, userId)
        try row.set(Place.foreignIdKey, placeId)
        return row
    }
    
    init(row: Row) throws {
        self.userId = try row.get(User.foreignIdKey)
        self.placeId = try row.get(Place.foreignIdKey)
    }
    
}

extension Favorite: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.foreignId(for: User.self)
            builder.foreignId(for: Place.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Favorite: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
//        try node.set("id", id)
//        try node.set("created", createdAt)
//        guard let user = try User.find(userId) else { return Node(context) }
        guard let place = try Place.find(placeId) else { return Node(context) }
//        try node.set("user_fullname", user.fullname)
        try node.set("place", place)
        
        return node
    }
}

extension Favorite: PasswordAuthenticatable { }
extension Favorite: SessionPersistable { }
extension Favorite: Timestampable { }

