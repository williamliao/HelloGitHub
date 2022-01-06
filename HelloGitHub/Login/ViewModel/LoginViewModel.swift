//
//  LoginViewModel.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/3.
//

import Foundation
import AuthenticationServices

protocol OAuthClient {
    
    func retrieveCode (
        in window: UIWindow,
        redirectURI: String,
        codeVerifier: String,
        completionHandler: @escaping (String, NetworkError?) -> Void
    )
    
    func retrieveToken(
        code: String,
        redirectURI: String,
        codeVerifier: String,
        completionHandler: @escaping (TokenResponse?, NetworkError?) -> Void
    )
    
    func refreshToken<T: Decodable>(
        url: URL,
        decodingType: T.Type,
        completionHandler: @escaping (Decodable?, NetworkError?) -> Void
    )
}

class LoginViewModel {
    
    var showError: ((_ error:NetworkError) -> Void)?
    private let oauthClient: OAuthClient
    
    init(oauthClient: OAuthClient) {
        self.oauthClient = oauthClient
    }
   
    func authorize(in window: UIWindow, completionHandler: @escaping (TokenResponse) -> Void) {
        // 產生隨機字串
        let codeVerifier = UUID().uuidString
        
        // 在 app 後台中的資訊
        let redirectURI = "helloGitHub://login"
        // 1. 使用 ASWebAuthenticationSession 獲取 authorization code
        oauthClient.retrieveCode(in: window, redirectURI: redirectURI, codeVerifier: codeVerifier) { [weak self] code, error in
            
            if let showError = error {
                self?.showError?(showError)
                return
            }
            
            // 2. 使用 URLSession 拿 authorization code 去交換 access token
            self?.oauthClient.retrieveToken(code: code, redirectURI: redirectURI, codeVerifier: codeVerifier) { token, error in
                // 3. 回傳 access token
                
                guard error == nil else {
                    if let error = error {
                        self?.showError?(error)
                        return
                    }
                    return
                }
                
                guard let token = token else {
                    self?.showError?(NetworkError.invalidToken)
                    return
                }
            
                completionHandler(token)
            }
        }
    }
}
