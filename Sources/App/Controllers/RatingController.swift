//
//  RatingController.swift
//  App
//
//  Created by Ibrahim Zakarya on 1/12/18.
//

final class RatingController {
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes(to drop: Droplet) {
        let ratingGroup = drop.grouped("rating")
        ratingGroup.post("add", handler: self.addRating)
        
    }
    
    func addRating(_ req: Request) throws -> ResponseRepresentable {
        
        guard let userId = req.data["userId"]?.int, let placeId = req.data["placeId"]?.int else {
            return Response(status: .badRequest)
        }
        
        guard let user = try User.find(userId), try Place.find(placeId) != nil else {
            return Response(status: .badRequest)
        }
        
        guard let rating = req.data["rating"]?.double else {
            return Response(status: .badRequest)
        }
        // check if the user rate this place before
        if let userRating = try user.ratings.filter("place_id", placeId).first() {
            userRating.rating = rating
            try userRating.save()
        } else {
            let userRating = Rating(rating: rating, userId: userId, placeId: placeId)
            try userRating.save()
        }
        
        return try PlaceController.calculatePlaceRating(placeId: placeId)
    }
    
}
