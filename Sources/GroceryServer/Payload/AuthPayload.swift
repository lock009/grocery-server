//
//  File.swift
//  GroceryServer
//
//  Created by Rajveer Mann on 09/11/25.
//

import Foundation
import Vapor
import JWT

struct AuthPayload : JWTPayload {
    var subject : SubjectClaim
    var expiration : ExpirationClaim
    var userId : UUID
    
    func verify(using signer: JWTKit.JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
    
    
}
