//
//  File.swift
//  GroceryServer
//
//  Created by Rajveer Mann on 18/11/25.
//


import Vapor
import GroceryAppSharedModels
import Fluent

struct GroceryController : RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api","user",":userId").grouped(JSONWebTokenAuthenticator())
        
        api.post("grocery-categories", use: saveGroceryCategory)
        api.get("grocery-categories", use: getGroceryCategoryByUser)
        api.delete("grocery-categories",":groceryCategoryId", use: deleteGroceryCategory)
        api.post("grocery-categories",":groceryCategoryId","grocery-items", use: saveGroceryItem)
        api.get("grocery-categories",":groceryCategoryId","grocery-items", use: getGroceryItemsByGroceryCategory)
        api.delete("grocery-categories",":groceryCategoryId","grocery-items",":groceryItemId", use: deleteGroceryItem)
        
    }
    func deleteGroceryItem(req : Request) async throws -> GroceryItemResponse {
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self),
              let groceryItemId = req.parameters.get("groceryItemId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound)
        }
        
        guard let groceryItem = try await GroceryItems.query(on: req.db)
            .filter(\.$id == groceryItemId)
            .filter(\.$groceryCategory.$id == groceryCategory.id!)
            .first() else {
            throw Abort(.notFound)
        }
        try await groceryItem.delete(on: req.db)
        guard let response = GroceryItemResponse(groceryItem) else {
            throw Abort(.internalServerError)
        }
        return response
    }
    
    
    func getGroceryItemsByGroceryCategory(req : Request) async throws -> [GroceryItemResponse] {
        guard let userId = req.parameters.get("userId",as : UUID.self),let groceryCategoryId  = req.parameters.get("groceryCategoryId" , as : UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let _ = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound)
        }
        
      return try await  GroceryItems.query(on: req.db)
            .filter(\.$groceryCategory.$id == groceryCategoryId)
            .all()
            .compactMap(GroceryItemResponse.init)
    }
    
    
    func getGroceryCategoryByUser(req : Request) async throws -> [GroceryCategoryResponse] {
        guard let userId = req.parameters.get("userId",as : UUID.self) else {
            throw Abort(.badRequest)
        }
       return  try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .all()
            .compactMap(GroceryCategoryResponse.init)
    }
    
    
    func deleteGroceryCategory(req : Request) async throws -> GroceryCategoryResponse {
        guard let userId = req.parameters.get("userId",as : UUID.self),let groceryCategoryId  = req.parameters.get("groceryCategoryId" , as : UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first()
        else {
          throw  Abort(.notFound)
        }
        
         try await groceryCategory.delete(on: req.db)
        guard let groceryCategoryResponse = GroceryCategoryResponse(groceryCategory) else {
            throw Abort(.internalServerError)
        }
        return groceryCategoryResponse
    }
    
    
    func saveGroceryItem(req : Request) async throws  -> GroceryItemResponse {
        
        guard let userId = req.parameters.get("userId",as : UUID.self) ,let groceryCategoryId = req.parameters.get("groceryCategoryId" , as : UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let _ = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound)
        }
        
         let groceryRequest = try req.content.decode(GroceryItemRequest.self)
        let groceryItem = GroceryItems(title: groceryRequest.title, price: groceryRequest.price, quantity: groceryRequest.quantity, groceryCategoryId: groceryCategory.id!)
        try await groceryItem.save(on: req.db)
        
        guard let groceryItemResponse = GroceryItemResponse(groceryItem) else {
            throw Abort(.internalServerError)
        }
        return  groceryItemResponse
    }
    
    
    func saveGroceryCategory(req : Request) async throws -> GroceryCategoryResponse {
        
        guard let userId = req.parameters.get("userId" , as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        let groceryCategoryRequest = try req.content.decode(GroceryCategoryRequest.self)
        
        let groceryCategory = GroceryCategory(title: groceryCategoryRequest.title, colorCode: groceryCategoryRequest.colorCode, userId: userId)
        
        try await groceryCategory.save(on: req.db)
        
        guard let groceryCategoryResponse = GroceryCategoryResponse(groceryCategory
        ) else {
            throw Abort(.internalServerError)
        }
        return groceryCategoryResponse
    }
}


