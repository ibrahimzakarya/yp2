//
//  CommnetController.swift
//  authPackageDescription
//
//  Created by Ibrahim Zakarya on 1/12/18.
//


final class CommentController {
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes(to drop: Droplet) {
        let commentGroup = drop.grouped("comment")
//        commentGroup.post("all", handler: self.getAllc)
        commentGroup.get("all", handler: self.getCommentsView)
        commentGroup.post("create", handler: self.addComment)
        commentGroup.post("delete", ":id", handler: self.deleteComment)
        commentGroup.get(":place_id", handler: self.getPlaceComments)
        
    }
    
    func getCommentsView(_ req: Request) throws -> ResponseRepresentable  {
        let comments = try Comment.all()
        return try drop.view.make("comments", ["commnets": comments.makeNode(in: nil), "commentsActive": true])
    }
    
    func addComment(_ req: Request) throws -> ResponseRepresentable {
        guard let userId = req.data["userId"]?.int, let placeId = req.data["placeId"]?.int else {
            return Response(status: .badRequest)
        }
        guard try User.find(userId) != nil, try Place.find(placeId) != nil else {
            return Response(status: .badRequest)
        }
        guard let commentText = req.data["text"]?.string else {
            return Response(status: .badRequest)
        }
        let comment = Comment(text: commentText, userId: userId, placeId: placeId)
        try comment.save()
        
        return Response(status: .ok)
    }
    
    func deleteComment(_ req: Request) throws -> ResponseRepresentable {
        guard let commentId = req.parameters["id"]?.int else { return Response(status: .badRequest) }
        guard let comment = try Comment.find(commentId) else { return Response(status: .badRequest) }
        try comment.delete()
        
        return Response(redirect: "/comment/all")
    }
    
    func getPlaceComments(_ req: Request) throws -> ResponseRepresentable {
        guard let placeId = req.parameters["place_id"]?.int else {
            return Response(status: .badRequest)
        }
        guard let place = try Place.find(placeId) else { return Response(status: .badRequest)}
//        let placeComments =  try place.makeCommentsJSON()
        
        return try place.makeCommentsJSON()
    }

}

