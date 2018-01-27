import AuthProvider

final class HomeController {
  let drop: Droplet
  
  init(drop: Droplet) {
    self.drop = drop
  }

  func getHomeView(_ req: Request) throws -> ResponseRepresentable {
  	return try drop.view.make("home", ["homeActive": true])
  }
}
