//
//  File.swift
//  GroceryServer
//
//  Created by Rajveer Mann on 08/11/25.
//

import Fluent
import Vapor

struct CreateUserTableMigrations : AsyncMigration {
    
    func prepare(on database: any Database) async throws {
     try await database.schema("users")
            .id()
            .field("username",.string,.required)
            .field("password",.string,.required)
            .unique(on: "username")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("users")
            .delete()
    }
}
