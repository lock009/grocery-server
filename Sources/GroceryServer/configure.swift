import Fluent
import FluentPostgresDriver
import Vapor
import JWT

public func configure(_ app: Application) async throws {

    // MARK: - PostgreSQL
    if let databaseURL = Environment.get("DATABASE_URL") {
        try app.databases.use(
            .postgres(
                url: databaseURL,
                maxConnectionsPerEventLoop: 1
            ),
            as: .psql
        )
    } else {
        app.databases.use(
            .postgres(
                hostname: "localhost",
                port: 5432,
                username: "postgres",
                password: "",
                database: "grocerydb"
            ),
            as: .psql
        )
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
