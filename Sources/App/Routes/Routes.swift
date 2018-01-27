import Vapor
import AuthProvider
import Sessions

extension Droplet {
  func setupRoutes() throws {

  	let homeController = HomeController(drop: self)
  	get("home", handler: homeController.getHomeView)
    get("", handler: homeController.getHomeView)
    
    let userController = UserController(drop: self)
    userController.addRoutes(to: self)

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
    placeController.addRoutes(to: self)
    
    
    let commentController = CommentController(drop: self)
    commentController.addRoutes(to: self)
    
    let ratingController = RatingController(drop: self)
    ratingController.addRoutes(to: self)
    
    let messageController = MessageController(drop: self)
    messageController.addRoutes(to: self)
    
  }
}
