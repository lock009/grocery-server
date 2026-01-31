//
//  File.swift
//  GroceryServer
//
//  Created by Rajveer Mann on 06/12/25.
//

import Vapor
import JWT
import Foundation

struct JSONWebTokenAuthenticator : AsyncRequestAuthenticator {
    
    func authenticate(request : Request) async throws {
        try await request.jwt.verify(as : AuthPayload.self)
    }
}

