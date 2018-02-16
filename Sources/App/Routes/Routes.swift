import Vapor
import AuthProvider
import Sessions

extension Droplet {
    func setupRoutes() throws {
        
        let homeController = HomeController(drop: self)
        
        let userController = UserController(drop: self)
        try userController.addAdminUser()
        
        let userGroup = self.grouped("user")
        userGroup.post("register", handler: userController.addUser)
        userGroup.get("login", handler: userController.getLoginView)
        userGroup.post("favorite", "add", handler: userController.addToFavorite)
        userGroup.post(":user_id", "favorites", handler: userController.getUserFavorite)
        userGroup.post("favorite", "delete", handler: userController.removeFromFavorite)
        
        let placeController = PlaceController(drop: self)
        let placeGroup = self.grouped("place")
        placeGroup.post("all", handler: placeController.getAllPlaces)
        placeGroup.get(":id", handler: placeController.getPlaceInfo)
        placeGroup.post("search", handler: placeController.searchForPlace)
        
        let commentController = CommentController(drop: self)
        let commentGroup = self.grouped("comment")
        commentGroup.get(":place_id", handler: commentController.getPlaceComments)
        
        let ratingController = RatingController(drop: self)
        
        let messageController = MessageController(drop: self)
        post("message", "send", handler: messageController.sendMessage)
        
        //setup authentication
        let persistMW = PersistMiddleware(User.self)
        let memory = MemorySessions()
        let sessionMW = SessionsMiddleware(memory)
        let loginRoute = self.grouped([sessionMW, persistMW])
        loginRoute.post("login", handler: userController.postLogin)
        loginRoute.get("login", handler: userController.getLoginView)
        loginRoute.get("logout", handler: userController.logout)
        let passwordMW = PasswordAuthenticationMiddleware(User.self)
        let authRoute = self.grouped([sessionMW, persistMW, passwordMW])
        
        // Users view and operations
        authRoute.get("user", "profile", handler: userController.getProfileView)
        authRoute.post("user", "edit", handler: userController.editUser)
        authRoute.get("user", "edit", ":id", handler: userController.getEditView)
        authRoute.post("user", "edit", ":id", handler: userController.editUser)
        authRoute.get("user", "all", handler: userController.getUsersView)
        authRoute.post("user", "delete", ":id", handler: userController.deleteUser)
        // Places views and operations
        authRoute.post("place", "add", handler: placeController.addPlace)
        authRoute.post("place", "edit", ":id", handler: placeController.editPlace)
        authRoute.get("place", "all", handler: placeController.getPlacesView)
        authRoute.get("place", "add", handler: placeController.getAddPlaceView)
        authRoute.get("place", "edit", ":id", handler: placeController.getEditView)
        authRoute.post("place", "delete", ":id", handler: placeController.deletePlace)
        authRoute.post("rating", "add", handler: ratingController.addRating)
        // Comments views and operations
        authRoute.post("comment", "delete", ":id", handler: commentController.deleteComment)
        authRoute.get("comment", "all", handler: commentController.getCommentsView)
        authRoute.post("comment", "create", handler: commentController.addComment)
        // Messages views and operations
        authRoute.get("message", "all", handler: messageController.getMessagesView)

        // Home view
        authRoute.get("home", handler: homeController.getHomeView)
        get("", handler: homeController.getHomeView)

        get("trymyapp", handler: homeController.tryMyApp)

        
    }
}
