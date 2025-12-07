//
//  File.swift
//  GroceryServer
//
//  Created by Rajveer Mann on 18/11/25.
//

import Foundation
import Vapor
import GroceryAppSharedModels

extension GroceryCategoryResponse : Content ,@unchecked Sendable{
    init?( _ groceryCategory : GroceryCategory) {
        guard let id = groceryCategory.id else {
            return nil
        }
        
        self.init(id : id,title : groceryCategory.title,colorCode : groceryCategory.colorCode)
    }
}
