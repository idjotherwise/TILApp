import Vapor
import Fluent

struct CategoriesController: RouteCollection {
	func boot(routes: RoutesBuilder) throws {
		let categoryRoutes = routes.grouped("api", "categories")
		categoryRoutes.post(use: createHandler)
		categoryRoutes.get(use: getAllHandler)
		categoryRoutes.get(":categoryID", use: getHandler)
		// categoryRoutes.put(":categoryID", use: updateHandler)
		// categoryRoutes.delete(":categoryID", use: deleteHandler)
		// categoryRoutes.get("search", use: searchHandler)
		// categoryRoutes.get("first", use: getFirstHandler)
		// categoryRoutes.get("sorted", use: sortedHandler)
		// categoryRoutes.get(":categoryID", "acronyms", use: getAcronymsHandler)
		
	}
	
	// func getAcronymsHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
	//   Category.find(req.parameters.get("categoryID"), on: req.db)
	//     .unwrap(or: Abort(.notFound))
	//     .flatMap { category in
	//       category.$acronyms.get(on: req.db)
	//     }
	// }
	
	func createHandler(_ req: Request) throws -> EventLoopFuture<Category> {
		let category = try req.content.decode(Category.self)
		return category.save(on: req.db).map { category }
	}
	func getAllHandler(_ req: Request) -> EventLoopFuture<[Category]> {
		Category.query(on: req.db).all()
	}
	func getHandler(_ req: Request) -> EventLoopFuture<Category> {
		Category.find(req.parameters.get("categoryID"), on: req.db).unwrap(or: Abort(.notFound))
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
