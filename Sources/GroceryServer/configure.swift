import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    
     app.databases.use(.postgres(configuration: SQLPostgresConfiguration(hostname: "localhost", username: "postgres", password: "", database: "grocerydb", tls: .prefer(try .init(configuration: .clientDefault)))), as: .psql)

    
    app.migrations.add(CreateUserTableMigrations())
    app.migrations.add(FixQuantityType())
    app.migrations.add(CreateGroceryCategoryTableMigration())
    app.migrations.add(CreateGroceryItemTableMigration())
    
                       
    try app.register(collection: UserController())
    try app.register(collection: GroceryController())
    
    app.jwt.signers.use(.hs256(key: "secretkey"))
    // register routes
    try routes(app)
}
