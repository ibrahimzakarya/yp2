import AuthProvider
import Foundation

final class PlaceController {
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes(to drop: Droplet) {
        
    }
    
    func getPlacesView(_ req: Request) throws -> ResponseRepresentable  {
        let places = try Place.all()
        return try drop.view.make("places", ["places": try places.makeNode(in: nil), "placesActive": true])
    }
    
    func getAddPlaceView(_ req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("add_place", ["placesActive": true])
    }
    
    func getEditView(_ req: Request) throws -> ResponseRepresentable {
        guard let placeId = req.parameters["id"]?.int else {
            return Response(status: .badRequest)
        }
        guard let place = try Place.find(placeId) else { return Response(status: .badRequest) }
        
        let isActive = String(place.isActive)
        return try drop.view.make("edit_place", ["place": try place.makeNode(in: nil), "is_active": isActive, "placesActive": true])
    }
    
    func getPlaceInfo(_ req: Request) throws -> ResponseRepresentable {
        guard let placeId = req.parameters["id"]?.int else {
            return Response(status: .badRequest)
        }
        guard let place = try Place.find(placeId) else { return Response(status: .badRequest) }
        return try place.makePlaceJSON()
    }
    
    func getAllPlaces(_ req: Request) throws -> ResponseRepresentable {
        let list = try Place.makeQuery().filter("is_active", .equals, 1).all()
        return try list.makeJSON()
    }
    
    func addPlace(_ req: Request) throws -> ResponseRepresentable {
        guard
            let placeName = req.data["name"]?.string,
            let placeAddress = req.data["address"]?.string,
            let longitude = req.data["longitude"]?.double,
            let latitude = req.data["latitude"]?.double,
            let phone = req.data["phone"]?.string,
            let classification = req.data["classification"]?.string
        else {
            return Response(status: .badGateway)
        }
        let logo = req.data["logo"]?.string
        let details = req.data["details"]?.string
        let openTime = req.data["open_time"]?.string
        let closeTime = req.data["close_time"]?.string
        let website = req.data["website"]?.string
        let mobile = req.data["mobile"]?.string
        
        
        let place = Place(name: placeName, longitude: longitude, latitude: latitude, address: placeAddress, phone: phone, classification: classification, mobile: mobile, rating: 0.0, openTime: openTime, closeTime: closeTime, details: details, website: website, logo: logo)
        
        do {
            try place.save()
        }
        catch  {
            print("faild to save place")
            return Response(status: .badRequest)
        }
        return Response(redirect: "/place/all")
    }
    
    func editPlace(_ req: Request) throws -> ResponseRepresentable{
        guard let placeId = req.parameters["id"]?.int else {
            return Response(status: .badRequest)
        }
        guard let place = try Place.find(placeId) else { return Response(status: .badRequest) }
        
        guard
            let placeName = req.data["name"]?.string,
            let placeAddress = req.data["address"]?.string,
            let longitude = req.data["longitude"]?.double,
            let latitude = req.data["latitude"]?.double,
            let isActive = req.data["is_active"]?.uint,
            let phone = req.data["phone"]?.string,
            let classification = req.data["classification"]?.string
        else {
            return Response(status: .badGateway)
        }
        let logo = req.data["logo"]?.string
        let details = req.data["details"]?.string
        let openTime = req.data["open_time"]?.string
        let closeTime = req.data["close_time"]?.string
        let website = req.data["website"]?.string
        let mobile = req.data["mobile"]?.string
        
        place.name = placeName
        place.address = placeAddress
        place.classification = classification
        place.longitude = longitude
        place.latitude = latitude
        place.phone = phone
        place.logo = logo
        place.details = details
        place.openTime = openTime
        place.closeTime = closeTime
        place.website = website
        place.mobile = mobile
        place.isActive = UInt8(isActive)
        
        try place.save()
        return Response(redirect: "/place/all")
    }
    
    func deletePlace(_ req: Request) throws -> ResponseRepresentable {
        guard let placeId = req.parameters["id"]?.int else {
            return Response(status: .badRequest)
        }
        guard let place = try Place.find(placeId) else { return Response(status: .badRequest) }
        try place.delete()
        return Response(redirect: "/place/all")
    }
    
    func searchForPlace(_ req: Request) throws -> ResponseRepresentable {
        guard let text = req.data["query"]?.string else { return Response(status: .badRequest)}
        
        let places = try Place
            .makeQuery()
            .filter("name", .contains, text)
            .and { andGroup in
                try andGroup.filter("is_active", .equals, 1)
            }
            .all()
        return try places.makeJSON()
        
        
    }
    
    func getPlaceLocation(_ req: Request) throws -> ResponseRepresentable {
        guard let placeId = req.parameters["id"]?.int else {
            return Response(status: .badRequest)
        }
        guard let place = try Place.find(placeId) else { return Response(status: .badRequest) }
        
        var json = JSON()
        try json.set("longitude", place.longitude)
        try json.set("latitude", place.latitude)
        return json
    }
    
    static func calculatePlaceRating(placeId: Int) throws -> ResponseRepresentable {
        guard let place = try Place.find(placeId) else { return Response(status: .badRequest) }
        let ratings = try place.ratings.all()
        print(ratings)
        var sum = 0.0
        for rating in ratings {
            sum = sum + rating.rating
        }
        sum = sum / Double(ratings.count)
        place.rating = sum
        try place.save()
        print(sum)
        return Response(status: .ok)
    }
}
