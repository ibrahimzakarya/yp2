import AuthProvider

final class HomeController {
  let drop: Droplet
  
  init(drop: Droplet) {
    self.drop = drop
  }

  func getHomeView(_ req: Request) throws -> ResponseRepresentable {
//    do {
//        let user: User = try req.auth.assertAuthenticated()
//    } catch  {
//        return Response(redirect: "/login")
//    }
//    
////    let user: User = try req.auth.assertAuthenticated()
    
  	return try drop.view.make("home", ["homeActive": true])
  }
}
