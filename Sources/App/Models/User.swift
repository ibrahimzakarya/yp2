import Vapor
import FluentProvider
import AuthProvider

final class User: Model {
  var storage = Storage()
  var email: String
  var password: String
  var username: String
  var fullname: String
  var isActive: UInt8
  var isAdmin: UInt8
//  var favorites: [Place]?

  init(email: String, password: String, username: String, fullname: String) {
    self.email = email
    self.password = password
    self.username = username
    self.fullname = fullname
    self.isActive = 1
    self.isAdmin = 0
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set("email", email)
    try row.set("password", password)
    try row.set("fullname", fullname)
    try row.set("username", username)
    try row.set("is_active", isActive)
    try row.set("is_admin", isAdmin)
    return row
  }
  
  init(row: Row) throws {
    self.email = try row.get("email")
    self.password = try row.get("password")
    self.username = try row.get("username")
    self.fullname = try row.get("fullname")
    self.isActive = try row.get("is_active")
    self.isAdmin = try row.get("is_admin")
  }
}

// MARK: Fluent Preparation

extension User: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) { builder in
      builder.id()
      builder.string("email")
      builder.string("password")
      builder.string("username")
      builder.string("fullname")
      builder.int("is_active")
      builder.int("is_admin")
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

// MARK: Node

extension User: NodeRepresentable {
  func makeNode(in context: Context?) throws -> Node {
    var node = Node(context)
    try node.set("id", id)
    try node.set("email", email)
    try node.set("password", password)
    try node.set("fullname", fullname)
    try node.set("username", username)
    try node.set("is_active", isActive)
    try node.set("is_admin", isAdmin)
    try node.set("commnets", try comments.all())
    try node.set("messages", try messages.all())
    return node
  }
}

extension User {
    var comments: Children<User, Comment> {
        return children()
    }
}

extension User {
    var favorites: Children<User, Favorite> {
        return children()
    }
}

extension User {
    var messages: Children<User, Message> {
        return children()
    }
}

extension User {
    var ratings: Children<User, Rating> {
        return children()
    }
}

extension User: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", email)
        try json.set("username", username)
        return json
    }
    
    func makeFavoritesJSON() throws -> JSON {
        var json = JSON()
        try json.set("favorites", favorites.all())
        return json
    }
}

extension User: PasswordAuthenticatable { }
extension User: SessionPersistable { }
extension User: Timestampable { }
