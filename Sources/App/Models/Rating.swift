//
//  Rating.swift
//  App
//
//  Created by Ibrahim Zakarya on 1/12/18.
//


import Vapor
import FluentProvider
import AuthProvider


final class Rating: Model {
    var storage = Storage()
    var rating: Double
    let userId: Int
    let placeId: Int
    
    init(rating: Double, userId: Int, placeId: Int) {
        self.rating = rating
        self.userId = userId
        self.placeId = placeId
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("rating", rating)
        try row.set(User.foreignIdKey, userId)
        try row.set(Place.foreignIdKey, placeId)
        return row
    }
    
    init(row: Row) throws {
        self.rating = try row.get("rating")
        self.userId = try row.get(User.foreignIdKey)
        self.placeId = try row.get(Place.foreignIdKey)
    }
    
}

extension Rating: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("rating")
            builder.foreignId(for: User.self)
            builder.foreignId(for: Place.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Rating: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("id", id)
        try node.set("text", rating)
        try node.set("user_id", userId)
        try node.set("place_id", placeId)
        
        return node
    }
}

extension Rating: PasswordAuthenticatable { }
extension Rating: SessionPersistable { }
extension Rating: Timestampable { }


