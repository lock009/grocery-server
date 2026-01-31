import Vapor
import Fluent
import JWT
import GroceryAppSharedModels

struct UserController: RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api")
        api.post("register", use: register)
        api.post("login", use: login)
    }
    
    // MARK: - Login
    func login(req: Request) async throws -> LoginResponse {
        
        let userInput = try req.content.decode(User.self)
        
        guard let existingUser = try await User.query(on: req.db)
            .filter(\.$username == userInput.username)
            .first()
        else {
            return LoginResponse(error: true ,message: "the username does not exist")
        }
        
        let isPasswordValid = try await req.password.async.verify(
            userInput.password,
            created: existingUser.password
        )
        
        if !isPasswordValid {
            return LoginResponse(error: true,message: "password is not valid")
        }
        
        let payload = try AuthPayload(
            subject: .init(value: try existingUser.requireID().uuidString),
            expiration: .init(value: .distantFuture),userId:  existingUser.requireID()
        )
        
        let token = try await req.jwt.sign(payload)
        
        return LoginResponse(
            error: false,
            message: "Login successful.",
            token: token,
            userId: try existingUser.requireID()
        )
    }
    
    
    func register(req: Request) async throws -> RegisterResponse {
        
        try User.validate(content: req)
        
        let user = try req.content.decode(User.self)
        
        if try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() != nil
        {
            return RegisterResponse(error: true, username: user.username, message: "the username is already present in the database")        }
        
        user.password = try await req.password.async.hash(user.password)
        
        try await user.save(on: req.db)
        
        return RegisterResponse(
            error: false, username: user.username,
            message: "User created successfully."
        )
    }
}
