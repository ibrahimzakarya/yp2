import AuthProvider

final class HomeController {
  let drop: Droplet
  
  init(drop: Droplet) {
    self.drop = drop
  }

  func getHomeView(_ req: Request) throws -> ResponseRepresentable {

    
  	return try drop.view.make("home", ["homeActive": true])
  }
    
    func getLoginView(_ req: Request) throws -> ResponseRepresentable {
        
        return Response(redirect: "/login")
    }
    
    func tryMyApp(_ req: Request) throws -> ResponseRepresentable {
        return Response(redirect: "https://appetize.io/app/p4ey3btmt43mp34nwexyw2ttdc?device=iphone8plus&scale=75&orientation=portrait&osVersion=11.1")
    }
}
