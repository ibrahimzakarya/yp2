//
//  MessageController.swift
//  App
//
//  Created by Ibrahim Zakarya on 1/12/18.
//

final class MessageController {
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func sendMessage(_ req: Request) throws -> ResponseRepresentable {
//        guard let userId = req.data["user_id"]?.int else {
//            return Response(status: .badRequest)
//        }
        let userId =  req.data["user_id"]?.int
//        guard try User.find(userId) != nil else {
//            return Response(status: .badRequest)
//        }
        guard let messageText = req.data["message"]?.string, let messageSubject = req.data["subject"]?.string, let userEmail = req.data["email"]?.string else {
            return Response(status: .badRequest)
        }
        let message = Message(text: messageText, userId: userId, subject: messageSubject, email: userEmail)
        try message.save()
        
        return Response(status: .ok)
    }
    
    func getMessagesView(_ req: Request) throws -> ResponseRepresentable  {
        let messages = try Message.all()
        return try drop.view.make("messages", ["messages": try messages.makeNode(in: nil), "messagesActive": true])
    }
}
