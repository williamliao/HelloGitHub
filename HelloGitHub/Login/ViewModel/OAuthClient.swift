//
//  OAuthClient.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/3.
//

import Foundation

import UIKit
import AuthenticationServices

class RemoteOAuthClient: OAuthClient {
    
    var session: ASWebAuthenticationSession?
    
    func retrieveCode (
        
        // 用來顯示的視窗
        in window: UIWindow,
        // 在 App 後台裡新增的 redirect URI
        redirectURI: String,
        // 這是用來在行動裝置 app 上補強 Authorization Code flow 的叫做 PKCE 的機制，用一個臨時產生的隨機字串（code verifier）來當 client secret，在請求 authorization code 跟請求 token 時各傳送一次給授權伺服器檢查，以避免 authorization code 在用瀏覽器傳輸時遭到中間人攔截。
        codeVerifier: String,
        completionHandler: @escaping (String, NetworkError?) -> Void
    ) {
        // 取出建構好的 URL
        let url = LoginEndPoint.login(redirect: redirectURI, state: codeVerifier).url!
        
        // 依據在 app 後台新增的 Redirect URI，填入相對應的 url scheme
        session = ASWebAuthenticationSession(url: url, callbackURLScheme: "helloGitHub") { [weak self] url, error in
            
            // 抽取 authorization code
            guard let url = url else { return }
            guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else { return }
            guard let code = queryItems.first(where: { $0.name == "code" })?.value else { return }
            guard let state = queryItems.first(where: { $0.name == "state" })?.value else { return }
            
            guard error == nil else {
                if let error = error {
                    print("retrieveCode error \(error)")
                    completionHandler("", error as? NetworkError)
                }
                return
            }
            
            if state == codeVerifier {
                // 回傳 code 並結束第一步驟
                self?.session = nil
                completionHandler(code, nil)
            } else {
                //Something Happended,this may not expect
                //If the states don't match, then a third party created the request, and you should abort the process
                self?.session?.cancel()
            }
        }
        session?.presentationContextProvider = window
        session?.prefersEphemeralWebBrowserSession = true
        session?.start()
    }
    
    func retrieveToken(
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
    
    func refreshToken<T: Decodable>(
        session: URLSession,
        url: URL,
        decodingType: T.Type,
        completionHandler: @escaping (Decodable?, NetworkError?) -> Void
    ) {

        let dataLoader = DataLoader(session: session)
        
        Task {
            do {
                let result = try await dataLoader.fetchWithContinuation(url, decode: { json -> T? in
                    guard let feedResult = json as? T else { return  nil }
                    return feedResult
                })
                
                completionHandler(result, nil)
                
            } catch  {
                completionHandler(nil, error as? NetworkError)
            }
        }
    }
}
