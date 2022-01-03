//
//  LoginViewModel.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/3.
//

import Foundation
import AuthenticationServices

class LoginViewModel {
    
    var showError: ((_ error:NetworkError) -> Void)?
   
    private func retrieveCode (
        
        // 用來顯示的視窗
        in window: UIWindow,
        // 在 App 後台裡新增的 redirect URI
        redirectURI: String,
        // 這是用來在行動裝置 app 上補強 Authorization Code flow 的叫做 PKCE 的機制，用一個臨時產生的隨機字串（code verifier）來當 client secret，在請求 authorization code 跟請求 token 時各傳送一次給授權伺服器檢查，以避免 authorization code 在用瀏覽器傳輸時遭到中間人攔截。
        codeVerifier: String,
        completionHandler: @escaping (String) -> Void
    ) {
        // 取出建構好的 URL
        let url = LoginEndPoint.login(redirect: redirectURI, state: codeVerifier).url!
        
        var session: ASWebAuthenticationSession?
        // 依據在 app 後台新增的 Redirect URI，填入相對應的 url scheme
        session = ASWebAuthenticationSession(url: url, callbackURLScheme: "helloGitHub") { url, error in
            session = nil
            // 抽取 authorization code
            guard let url = url else { return }
            guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else { return }
            guard let code = queryItems.first(where: { $0.name == "code" })?.value else { return }
            // 回傳 code 並結束第一步驟
            completionHandler(code)
        }
        session?.presentationContextProvider = window
        session?.prefersEphemeralWebBrowserSession = true
        session?.start()
    }
    
    private func retrieveToken(
        code: String,
        redirectURI: String,
        codeVerifier: String,
        completionHandler: @escaping (TokenResponse?, NetworkError?) -> Void
    ) {
        let endPoint = LoginEndPoint.accessToken(received: code, redirect: redirectURI, state: codeVerifier)
        let dataLoader = DataLoader()
        
        Task {
            let result = try await dataLoader.fetchToken(endPoint, decode: { json -> TokenResponse? in
                guard let feedResult = json as? TokenResponse else { return  nil }
                return feedResult
            })
            
            switch result {
                case .success(let token):
                    completionHandler(token, nil)
                
                case .failure(let error):
                    print("retrieveToken error \(error)")
                    completionHandler(nil, error)
            }
        }
    }
    
    func authorize(in window: UIWindow, completionHandler: @escaping (TokenResponse) -> Void) {
        // 產生一個長度 128 的隨機字串
        let codeVerifier = String(
            String(repeating: "a", count: 128).compactMap { _ in
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()
            }
        )
        // 在 app 後台中的資訊
        let redirectURI = "helloGitHub://login"
        // 1. 使用 ASWebAuthenticationSession 獲取 authorization code
        retrieveCode(in: window, redirectURI: redirectURI, codeVerifier: codeVerifier) { code in
            // 2. 使用 URLSession 拿 authorization code 去交換 access token
            self.retrieveToken(code: code, redirectURI: redirectURI, codeVerifier: codeVerifier) { token, error in
                // 3. 回傳 access token
                
                guard error == nil else {
                    if let error = error {
                        self.showError?(error)
                        return
                    }
                    return
                }
                
                guard let token = token else {
                    self.showError?(NetworkError.invalidToken)
                    return
                }
            
                completionHandler(token)
            }
        }
    }
}
