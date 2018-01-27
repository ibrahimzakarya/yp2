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
    
    func addRoutes(to drop: Droplet) {
        let messageGroup = drop.grouped("message")
        messageGroup.post("send", handler: self.sendMessage)
        messageGroup.get("all", handler: self.getMessagesView)
    }
    
    func sendMessage(_ req: Request) throws -> ResponseRepresentable {
        
        guard let userId = req.data["userId"]?.int else {
            return Response(status: .badRequest)
        }
        
        guard try User.find(userId) != nil else {
            return Response(status: .badRequest)
        }
        
        guard let messageText = req.data["message"]?.string, let messageSubject = req.data["subject"]?.string else {
            return Response(status: .badRequest)
        }
        
        let message = Message(text: messageText, userId: userId, subject: messageSubject)
        try message.save()
        
        return Response(status: .ok)
    }
    
    func getMessagesView(_ req: Request) throws -> ResponseRepresentable  {
        let messages = try Message.all()
        return try drop.view.make("messages", ["messages": try messages.makeNode(in: nil), "messagesActive": true])
    }
}
