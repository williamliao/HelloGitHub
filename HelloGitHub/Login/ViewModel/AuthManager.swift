//
//  AuthManager.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/4.
//

import Foundation

actor AuthManager {

    enum AuthError: Error {
        case missingToken
    }

    private var refreshTask: Task<TokenResponse, Error>?

    func validToken() async throws -> TokenResponse {
        if let handle = refreshTask {
            return try await handle.value
        }
    
        guard let token = DataLoader.token else {
            throw AuthError.missingToken
        }
    
        if token.isValid {
            return token
        }
    
        return try await refreshToken()
    }

    func refreshToken() async throws -> TokenResponse {
        if let refreshTask = refreshTask {
            return try await refreshTask.value
        }
      
        let task = Task { () throws -> TokenResponse in
            defer { refreshTask = nil }
    
            // Normally you'd make a network call here. Could look like this:
            let dataLoader = DataLoader()
            let token = try await dataLoader.refreshToken(withRefreshToken: DataLoader.refreshToken ?? "")
            
            DataLoader.accessToken = token.access_token
            DataLoader.refreshToken = token.refresh_token
            DataLoader.expires = token.expires_in
            DataLoader.refreshExpires = token.refresh_token_expires_in
            DataLoader.token = token
            
            return token
    
            // I'm just generating a dummy token
//            let tokenExpiresAt = Date().addingTimeInterval(10)
//            let newToken = Token(validUntil: tokenExpiresAt, id: UUID())
//            currentToken = newToken
//
//            return newToken
        }
    
        self.refreshTask = task
    
        return try await task.value
    }
}
