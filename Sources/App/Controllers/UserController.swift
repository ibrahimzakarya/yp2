import AuthProvider
import Sessions

final class UserController {
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes(to drop: Droplet) {
        let userGroup = drop.grouped("user")
//        userGroup.get("user", "register", handler: self.getRegisterView)
        userGroup.post("register", handler: self.addUser)
        userGroup.get("login", handler: self.getLoginView)
//        userGroup.get("edit", ":id", handler: self.getEditView)
//        userGroup.post("edit", ":id", handler: self.editUser)
//        userGroup.get("all", handler: self.getUsersView)
//        userGroup.post("delete", ":id", handler: self.deleteUser)
        
        let persistMW = PersistMiddleware(User.self)
        let memory = MemorySessions()
        let sessionMW = SessionsMiddleware(memory)
        let loginRoute = drop.grouped([sessionMW, persistMW])
    
        loginRoute.post("login", handler: self.postLogin)
        loginRoute.get("login", handler: self.getLoginView)
        loginRoute.get("logout", handler: self.logout)
	
        let passwordMW = PasswordAuthenticationMiddleware(User.self)
        let authRoute = drop.grouped([sessionMW, persistMW, passwordMW])
        
        
        authRoute.get("user", "profile", handler: self.getProfileView)
        authRoute.post("user", "edit", handler: self.editUser)
        authRoute.get("user", "edit", ":id", handler: self.getEditView)
        authRoute.post("user", "edit", ":id", handler: self.editUser)
        authRoute.get("user", "all", handler: self.getUsersView)
        authRoute.post("user", "delete", ":id", handler: self.deleteUser)
    }
    
//    func getRegisterView(_ req: Request) throws -> ResponseRepresentable  {
//        return try drop.view.make("register")
//    }
    
    func getLoginView(_ req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("login")
    }
    
    func getUsersView(_ req: Request) throws -> ResponseRepresentable {
        let users = try User.all()
        return try drop.view.make("users", ["users": try users.makeNode(in: nil), "usersActive": true])
    }
    
    func getEditView(_ req: Request) throws -> ResponseRepresentable {
        guard let userId = req.parameters["id"]?.int else {
            return Response(status: .badRequest)
        }
        guard let user = try User.find(userId) else { return Response(status: .badRequest) }
        
        let isActive = String(user.isActive)
        let isAdmin = String(user.isAdmin)
        return try drop.view.make("edit_user", ["user": try user.makeNode(in: nil), "is_active": isActive, "is_admin": isAdmin])
    }
    
    func getProfileView(_ req: Request) throws -> ResponseRepresentable {

        // returns user from session
        let user: User = try req.auth.assertAuthenticated()
        return try drop.view.make("profile", ["user": try user.makeNode(in: nil)])
    }
    
    func getAllUsers(_ req: Request) throws -> ResponseRepresentable {
        let list = try User.all()
        return try list.makeJSON()
    }
    
    func addUser(_ req: Request) throws -> ResponseRepresentable {
        guard
            let email = req.data["email"]?.string,
            let password = req.data["password"]?.string,
            let fullname = req.data["fullname"]?.string,
            let username = req.data["username"]?.string
            else {
                return "ether email or password is missing"
        }
        guard
            try User.makeQuery().filter("email", email).first() == nil
            else {
                return "email already exists"
        }
        
        let user = User(email: email, password: password, username: username, fullname: fullname)
        try user.save()
        
        return Response(status: .ok)
    }
    
    func postLogin(_ req: Request) throws -> ResponseRepresentable {
        guard
            let email = req.formURLEncoded?["email"]?.string,
            let password = req.formURLEncoded?["password"]?.string
            else {
                return "either email or password is missing"
        }
        let credentials = Password(username: email, password: password)
        
        // returns matching user (throws error if user doesn't exist)
        let user = try User.authenticate(credentials)
        
        // persists user and creates a session cookie
        req.auth.authenticate(user)
        
        return Response(redirect: "/profile")
    }
    
    func logout(_ req: Request) throws -> ResponseRepresentable {
        try req.auth.unauthenticate()
        return Response(redirect: "/login")
    }
    
    func editUser(_ req: Request) throws -> ResponseRepresentable{
//        let user: User = try req.auth.assertAuthenticated()
        
        //        guard let userId = req.parameters["id"]?.int else {
        //            return Response(status: .badRequest)
        //        }
        //        guard let user = try User.find(userId) else { return Response(status: .badRequest) }
        guard let userId = req.parameters["id"]?.int else {
            return Response(status: .badRequest)
        }
        guard let user = try User.find(userId) else { return Response(status: .badRequest) }
        guard
            let username = req.data["username"]?.string,
            let email = req.data["email"]?.string,
            let password = req.data["password"]?.string,
            let fullname = req.data["fullname"]?.string,
            let isActive = req.data["is_active"]?.uint,
            let isAdmin = req.data["is_admin"]?.uint
            else {
                return Response(status: .badGateway)
        }
        user.username = username
        user.email = email
        user.password = password
        user.fullname = fullname
        user.isActive = UInt8(isActive)
        user.isAdmin = UInt8(isAdmin)
        
        try user.save()
        return Response(redirect: "/user/all")
    }
    
    func deleteUser(_ req: Request) throws -> ResponseRepresentable {
        guard let userId = req.parameters["id"]?.int else {
            return Response(status: .badRequest)
        }
        guard let user = try User.find(userId) else { return Response(status: .badRequest) }
        try user.delete()
        return Response(redirect: "/user/all")
    }
    
}
