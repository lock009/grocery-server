import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import JWT

public func configure(_ app: Application) async throws {

    // MARK: - PostgreSQL for Render
    if let databaseURL = Environment.get("DATABASE_URL") {
        // Render provides a full connection URL
        try app.databases.use(.postgres(url: databaseURL), as: .psql)
    } else {
        // Local development fallback
        app.databases.use(.postgres(configuration: SQLPostgresConfiguration(hostname: "localhost", username: "postgres", password: "", database: "grocerydb", tls: .prefer(try .init(configuration: .clientDefault)))), as: .psql)

    }

    // MARK: - Migrations
    app.migrations.add(CreateUserTableMigrations())
    app.migrations.add(FixQuantityType())
    app.migrations.add(CreateGroceryCategoryTableMigration())
    app.migrations.add(CreateGroceryItemTableMigration())
    try await app.autoMigrate()
    // MARK: - Controllers
    try app.register(collection: UserController())
    try app.register(collection: GroceryController())
    
    // MARK: - JWT
    await app.jwt.keys.add(hmac: "secretkey", digestAlgorithm: .sha256)


    // MARK: - Routes
    try routes(app)
}
