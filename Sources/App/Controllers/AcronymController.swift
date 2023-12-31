import Vapor
import Fluent

struct AcronymsController: RouteCollection {
	func boot(routes: RoutesBuilder) throws {
		let acronymsRoutes = routes.grouped("api", "acronyms")
		acronymsRoutes.get(use: getAllHandler)
		acronymsRoutes.post(use: createHandler)
		acronymsRoutes.get(":acronymID", use: getHandler)
		acronymsRoutes.put(":acronymID", use: updateHandler)
		acronymsRoutes.delete(":acronymID", use: deleteHandler)
		acronymsRoutes.get(":acronymID", "user", use: getUserHandler)
		acronymsRoutes.get("search", use: searchHandler)
		acronymsRoutes.get("first", use: getFirstHandler)
		acronymsRoutes.get("sorted", use: sortedHandler)
		acronymsRoutes.get(":acronymID", "categories", ":categoryID", use: addCategoriesHandler)
		acronymsRoutes.get(":acronymID", "categories", use: getCategoriesHandler)
		acronymsRoutes.delete(":acronymID", "categories", ":cateogryID", use: getCategoriesHandler)
		
	}
	func removeCateogoriesHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
		let acronymQuery = Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
		let categoryQuery = Category.find(req.parameters.get("categoryID"), on: req.db).unwrap(or: Abort(.notFound))
		
		return acronymQuery.and(categoryQuery).flatMap { acronym, category in
			acronym.$categories.detach(category, on: req.db).transform(to: .noContent)}
	}
	
	
	func addCategoriesHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
		let acronymQuery =
		Acronym.find(req.parameters.get("acronymID"), on: req.db)
			.unwrap(or: Abort(.notFound))
		let categoryQuery =
		Category.find(req.parameters.get("categoryID"), on: req.db)
			.unwrap(or: Abort(.notFound))
		return acronymQuery.and(categoryQuery)
			.flatMap { acronym, category in
				acronym
					.$categories
					.attach(category, on: req.db)
					.transform(to: .created)
			}
		
	}
	
	func getCategoriesHandler(_ req: Request) -> EventLoopFuture<[Category]> {
		Acronym.find(req.parameters.get("acronymID"), on: req.db)
			.unwrap(or: Abort(.notFound))
			.flatMap { acronym in
				acronym.$categories.query(on: req.db).all()
			}
	}
	
	func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
		let data = try req.content.decode(CreateAcronymData.self)
		let acronym = Acronym(
			short: data.short,
			long: data.long,
			userID: data.userID
		)
		return acronym.save(on: req.db).map { acronym }
	}
	func getAllHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
		Acronym.query(on: req.db).all()
	}
	func getHandler(_ req: Request) -> EventLoopFuture<Acronym> {
		Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
	}
	func getFirstHandler(_ req: Request) -> EventLoopFuture<Acronym> {
		Acronym.query(on: req.db).first().unwrap(or: Abort(.notFound))
	}
	func sortedHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
		Acronym.query(on: req.db)
			.sort(\.$short, .ascending)
			.all()
	}
	
	func getUserHandler(_ req: Request) -> EventLoopFuture<User> {
		Acronym.find(req.parameters.get("acronymID"), on: req.db)
			.unwrap(or: Abort(.notFound))
			.flatMap { acronym in
				acronym.$user.get(on: req.db)
			}
	}
	
	func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
		let updatedAcronym = try req.content.decode(CreateAcronymData.self)
		return Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap {
			acronym in
			acronym.short = updatedAcronym.short
			acronym.long = updatedAcronym.long
			acronym.$user.id = updatedAcronym.userID
			return acronym.save(on: req.db).map {
				acronym
			}
		}
	}
	func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
		Acronym.find(req.parameters.get("acronymID"), on: req.db)
			.unwrap(or: Abort(.notFound))
			.flatMap { acronym in
				acronym.delete(on: req.db).transform(to: .noContent)
			}
	}
	func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
		guard let searchTerm = req.query[String.self, at: "term"] else {
			throw Abort(.badRequest)
		}
		return Acronym.query(on: req.db).group(.or) {
			or in
			or.filter(\.$short == searchTerm)
			or.filter(\.$long == searchTerm)
		}.all()
	}
}

struct CreateAcronymData: Content {
	let short: String
	let long: String
	let userID: UUID
}
