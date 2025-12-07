//
//  File.swift
//  GroceryServer
//
//  Created by Rajveer Mann on 26/11/25.
//


import Fluent
import Vapor


struct CreateGroceryItemTableMigration : AsyncMigration {
    
    func prepare(on dataBase: any Database) async throws {
        try await dataBase.schema("grocery_items")
            .id()
            .field("title",.string,.required)
            .field("price",.double,.required)
            .field("quantity",.int,.required)
            .field("grocery_category_id",.uuid,.required,.references("grocery_categories", "id",onDelete: .cascade))
            .create()
    }
    
    func revert(on dataBase : any Database) async throws{
        try await dataBase.schema("grocery_items")
            .delete()
    }
}



struct FixQuantityType: AsyncMigration {
    
    func prepare(on database: any Database)  async throws {
       database.schema("grocery_items")
            .updateField("quantity", .int)
    }

    func revert(on database: any Database)  async throws {
         database.schema("grocery_items")
            .updateField("quantity", .double)
    }
}
