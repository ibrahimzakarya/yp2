import Vapor
import FluentProvider
import AuthProvider

final class Place: Model {
    var storage = Storage()
    var name: String
    var longitude: Double
    var latitude: Double
    var rating: Double
    var address: String
    var phone: String
    var mobile: String?
    var openTime: String?
    var closeTime: String?
    var details: String?
    var website: String?
    var logo: String?
    var isActive: UInt8
    
    init(name: String, longitude: Double, latitude: Double, address: String, phone: String, mobile: String?, rating:  Double, openTime: String?, closeTime: String?, details: String?, website: String?, logo: String?) {
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
        self.rating = rating
        self.address = address
        self.phone = phone
        self.mobile = mobile
        self.closeTime = closeTime
        self.openTime = openTime
        self.details = details
        self.website = website
        self.logo = logo
        self.isActive = 1
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("longitude", longitude)
        try row.set("latitude", latitude)
        try row.set("rating", rating)
        try row.set("is_active", isActive)
        try row.set("address", address)
        try row.set("phone", phone)
        try row.set("mobile", mobile)
        try row.set("open_time", openTime)
        try row.set("close_time", closeTime)
        try row.set("details", details)
        try row.set("website", website)
        try row.set("logo", logo)
        return row
    }
    
    init(row: Row) throws {
        self.name = try row.get("name")
        self.longitude = try row.get("longitude")
        self.latitude = try row.get("latitude")
        self.rating = try row.get("rating")
        self.isActive = try row.get("is_active")
        self.address = try row.get("address")
        self.phone = try row.get("phone")
        self.mobile = try row.get("mobile")
        self.openTime = try row.get("open_time")
        self.closeTime = try row.get("close_time")
        self.details = try row.get("details")
        self.website = try row.get("website")
        self.logo = try row.get("logo")
    }
}

// MARK: Fluent Preparation

extension Place: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.double("longitude")
            builder.double("latitude")
            builder.double("rating")
            builder.int("is_active")
            builder.string("address")
            builder.string("phone")
            builder.string("mobile", optional: true)
            builder.string("details", optional: true)
            builder.string("website", optional: true)
            builder.string("logo", optional: true)
            builder.string("open_time", optional: true)
            builder.string("close_time", optional: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: Node

extension Place: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("id", id)
        try node.set("name", name)
        try node.set("longitude", longitude)
        try node.set("latitude", latitude)
        try node.set("rating", rating)
        try node.set("address", address)
        try node.set("is_active", isActive)
        try node.set("phone", phone)
        try node.set("mobile", mobile)
        try node.set("details", details)
        try node.set("website", website)
        try node.set("logo", logo)
        try node.set("open_time", openTime)
        try node.set("close_time", closeTime)
        try node.set("commnets", try comments.all())
        try node.set("ratings", try ratings.all())
        
        return node
    }
}

extension Place {
    var comments: Children<Place, Comment> {
        return children()
    }
    
}

extension Place {
    var ratings: Children<Place, Rating> {
        return children()
    }
}

extension Place: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("address", address)
        try json.set("rate", rating)
        try json.set("logo", logo)
        return json
    }
    
    func makePlaceJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("address", address)
        try json.set("rate", rating)
        try json.set("open_time", openTime)
        try json.set("close_time", closeTime)
        try json.set("details", details)
        try json.set("website", website)
        try json.set("phone", phone)
        try json.set("mobile", mobile)
        try json.set("longitude", longitude)
        try json.set("latitude", latitude)
        try json.set("logo", logo)
        try json.set("comments", comments.all())
        
        return json
    }
    
    func makeCommentsJSON() throws -> JSON {
        var json = JSON()
        try json.set("comments", comments.all())
        return json
    }
    
}

extension Place: PasswordAuthenticatable { }
extension Place: SessionPersistable { }
extension Place: Timestampable { }

