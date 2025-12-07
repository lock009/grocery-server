//
//  File.swift
//  GroceryServer
//
//  Created by Rajveer Mann on 29/11/25.
//

import Foundation
import Vapor
import GroceryAppSharedModels

extension GroceryItemResponse : Content,@unchecked Sendable {
    init?(_ groceryItems : GroceryItems) {
        guard let groceryItemId = groceryItems.id else {
            return nil
        }
        
        self.init(id : groceryItemId , title: groceryItems.title,price: groceryItems.price,quantity: groceryItems.quantity)
    }
}


