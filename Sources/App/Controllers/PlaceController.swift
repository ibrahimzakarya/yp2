import AuthProvider

final class PlaceController {
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes(to drop: Droplet) {
        let placeGroup = drop.grouped("place")
        placeGroup.post("all", handler: self.getAllPlaces)
        placeGroup.get("all", handler: self.getPlacesView)
        placeGroup.get(":id", handler: self.getPlaceInfo)
        placeGroup.get("search", handler: self.searchForPlace)
        placeGroup.post("add", handler: self.addPlace)
        placeGroup.get("add", handler: self.getAddPlaceView)
        placeGroup.post("edit", ":id", handler: self.editPlace)
        placeGroup.get("edit", ":id", handler: self.getEditView)
        placeGroup.get("add", handler: self.getAddPlaceView)
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
        return try drop.view.make("edit_place", ["place": try place.makeNode(in: nil), "is_active": isActive])
    }
    
    func getPlaceInfo(_ req: Request) throws -> ResponseRepresentable {
        guard let placeId = req.parameters["id"]?.int else {
            return Response(status: .badRequest)
        }
        guard let place = try Place.find(placeId) else { return Response(status: .badRequest) }
        return try place.makePlaceJSON()
    }
    
    func getAllPlaces(_ req: Request) throws -> ResponseRepresentable {
        let list = try Place.all()
        return try list.makeJSON()
    }
    
    func addPlace(_ req: Request) throws -> ResponseRepresentable {
        guard
            let placeName = req.data["name"]?.string,
            let placeAddress = req.data["address"]?.string,
            let longitude = req.data["longitude"]?.double,
            let latitude = req.data["latitude"]?.double,
            let phone = req.data["phone"]?.string
        else {
            return Response(status: .badGateway)
        }
        let logo = req.data["logo"]?.string
        let details = req.data["details"]?.string
        let openTime = req.data["openTime"]?.date
        let closeTime = req.data["cloasTime"]?.date
        let website = req.data["website"]?.string
        let mobile = req.data["mobile"]?.string
        
        let place = Place(name: placeName, longitude: longitude, latitude: latitude, address: placeAddress, phone: phone, mobile: mobile, rating: 0.0, openTime: openTime, closeTime: closeTime, details: details, website: website, logo: logo)
        
        do {
            try place.save()
        }
        catch  {
            print("faild to save place")
            return Response(status: .badRequest)
        }
        return Response(status: .ok)
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
            let phone = req.data["phone"]?.string
        else {
            return Response(status: .badGateway)
        }
        let logo = req.data["logo"]?.string
        let details = req.data["details"]?.string
        let openTime = req.data["openTime"]?.date
        let closeTime = req.data["cloasTime"]?.date
        let website = req.data["website"]?.string
        let mobile = req.data["mobile"]?.string
        
        place.name = placeName
        place.address = placeAddress
        place.longitude = longitude
        place.latitude = latitude
        place.phone = phone
        place.logo = logo
        place.details = details
        place.openTime = openTime
        place.closeTime = closeTime
        place.website = website
        place.mobile = mobile
        
        try place.save()
        return Response(status: .ok)
    }
    
    func deletePlace(_ req: Request) throws -> ResponseRepresentable {
        guard let placeId = req.parameters["id"]?.int else {
            return Response(status: .badRequest)
        }
        guard let place = try Place.find(placeId) else { return Response(status: .badRequest) }
        try place.delete()
        return Response(status: .ok)
    }
    
    func searchForPlace(_ req: Request) throws -> ResponseRepresentable {
        guard let text = req.data["query"]?.string else { return Response(status: .badRequest)}
        
        let places = try Place
            .makeQuery()
            .filter("name", .contains, text)
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
