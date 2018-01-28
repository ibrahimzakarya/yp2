import Vapor
import AuthProvider
import Sessions

extension Droplet {
  func setupRoutes() throws {

  	let homeController = HomeController(drop: self)
  	get("home", handler: homeController.getHomeView)
    get("", handler: homeController.getHomeView)
    
    let userController = UserController(drop: self)
    let userGroup = self.grouped("user")
//        userGroup.get("user", "register", handler: self.getRegisterView)
        userGroup.post("register", handler: userController.addUser)
        userGroup.get("login", handler: userController.getLoginView)
//        userGroup.get("edit", ":id", handler: self.getEditView)
//        userGroup.post("edit", ":id", handler: self.editUser)
//        userGroup.get("all", handler: self.getUsersView)
//        userGroup.post("delete", ":id", handler: self.deleteUser)
        
        let persistMW = PersistMiddleware(User.self)
        let memory = MemorySessions()
        let sessionMW = SessionsMiddleware(memory)
        let loginRoute = self.grouped([sessionMW, persistMW])
    
        loginRoute.post("login", handler: userController.postLogin)
        loginRoute.get("login", handler: userController.getLoginView)
        loginRoute.get("logout", handler: userController.logout)
	
        let passwordMW = PasswordAuthenticationMiddleware(User.self)
        let authRoute = self.grouped([sessionMW, persistMW, passwordMW])
        
        
        authRoute.get("user", "profile", handler: userController.getProfileView)
        authRoute.post("user", "edit", handler: userController.editUser)
        authRoute.get("user", "edit", ":id", handler: userController.getEditView)
        authRoute.post("user", "edit", ":id", handler: userController.editUser)
        authRoute.get("user", "all", handler: userController.getUsersView)
        authRoute.post("user", "delete", ":id", handler: userController.deleteUser)

//    let persistMW = PersistMiddleware(User.self)
//    let memory = MemorySessions()
//    let sessionMW = SessionsMiddleware(memory)
//    let loginRoute = grouped([sessionMW, persistMW])
//
//    loginRoute.post("login", handler: userController.postLogin)
//    loginRoute.get("logout", handler: userController.logout)
//
//    let passwordMW = PasswordAuthenticationMiddleware(User.self)
//    let authRoute = grouped([sessionMW, persistMW, passwordMW])
//    authRoute.get("user", "profile", handler: userController.getProfileView)
//    authRoute.post("user", "edit", handler: userController.editUser)
    
    
    let placeController = PlaceController(drop: self)
    let placeGroup = self.grouped("place")
        placeGroup.post("all", handler: placeController.getAllPlaces)
        placeGroup.get("all", handler: placeController.getPlacesView)
        placeGroup.get(":id", handler: placeController.getPlaceInfo)
        placeGroup.get("search", handler: placeController.searchForPlace)
        placeGroup.post("add", handler: placeController.addPlace)
        placeGroup.get("add", handler: placeController.getAddPlaceView)
        placeGroup.post("edit", ":id", handler: placeController.editPlace)
        placeGroup.get("edit", ":id", handler: placeController.getEditView)
        placeGroup.get("add", handler: placeController.getAddPlaceView)
    
    
	let commentController = CommentController(drop: self)
	let commentGroup = self.grouped("comment")
	commentGroup.get("all", handler: commentController.getCommentsView)
	commentGroup.post("create", handler: commentController.addComment)
	commentGroup.post("delete", ":id", handler: commentController.deleteComment)
	commentGroup.get(":place_id", handler: commentController.getPlaceComments)
    
    let ratingController = RatingController(drop: self)
        let ratingGroup = self.grouped("rating")
        ratingGroup.post("add", handler: ratingController.addRating)

    
    let messageController = MessageController(drop: self)
    let messageGroup = self.grouped("message")
	  messageGroup.post("send", handler: messageController.sendMessage)
	  messageGroup.get("all", handler: messageController.getMessagesView)
    
  }
}
