import Vapor
import Fluent

struct UsersController: RouteCollection {
	func boot(routes: RoutesBuilder) throws {
		let userRoutes = routes.grouped("api", "users")
		userRoutes.get(use: getAllHandler)
		userRoutes.post(use: createHandler)
		userRoutes.get(":userID", use: getHandler)
		// userRoutes.put(":userID", use: updateHandler)
		// userRoutes.delete(":userID", use: deleteHandler)
		// userRoutes.get("search", use: searchHandler)
		// userRoutes.get("first", use: getFirstHandler)
		// userRoutes.get("sorted", use: sortedHandler)
		userRoutes.get(":userID", "acronyms", use: getAcronymsHandler)
		
	}
	
	func getAcronymsHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
		User.find(req.parameters.get("userID"), on: req.db)
			.unwrap(or: Abort(.notFound))
			.flatMap { user in 
				user.$acronyms.get(on: req.db)
			}
	}
	
	func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
		let user = try req.content.decode(User.self)
		return user.save(on: req.db).map { user }
	}
	func getAllHandler(_ req: Request) -> EventLoopFuture<[User]> {
		User.query(on: req.db).all()
	}
	func getHandler(_ req: Request) -> EventLoopFuture<User> {
		User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound))
	}
	// func getFirstHandler(_ req: Request) -> EventLoopFuture<Acronym> {
	//   Acronym.query(on: req.db).first().unwrap(or: Abort(.notFound))
	// }
	// func sortedHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
	//   Acronym.query(on: req.db)
	//     .sort(\.$short, .ascending)
	//     .all()
	// }
	// func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
	//   let updatedAcronym = try req.content.decode(Acronym.self)
	//     return Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap {
	//       acronym in
	//         acronym.short = updatedAcronym.short
	//         acronym.long = updatedAcronym.long
	//         return acronym.save(on: req.db).map {
	//           acronym
	//       }
	//   }
	// }
	// func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
	//   Acronym.find(req.parameters.get("acronymID"), on: req.db)
	//     .unwrap(or: Abort(.notFound))
	//     .flatMap { acronym in
	//           acronym.delete(on: req.db).transform(to: .noContent)
	//     }
	// }
	// func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {      
	//       guard let searchTerm = req.query[String.self, at: "term"] else {
	//           throw Abort(.badRequest)
	//       }
	//       return Acronym.query(on: req.db).group(.or) {
	//         or in
	//         or.filter(\.$short == searchTerm)
	//         or.filter(\.$long == searchTerm)
	//       }.all()
	//   }
}
