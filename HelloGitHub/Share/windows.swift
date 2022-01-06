//
//  windows.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/3.
//

import UIKit
import AuthenticationServices

extension UIWindow: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // UIWindow 本來就有遵守 ASPresentationAnchor，所以可以直接回傳 self。
        return self
    }
    
    func getWindowsFromScene() -> UIWindow? {
        let foregroundedScenes = UIApplication.shared.connectedScenes.filter { $0.activationState == .foregroundActive }
        let window = foregroundedScenes.map { $0 as? UIWindowScene }.compactMap { $0 }.first?.windows.filter { $0.isKeyWindow }.first
      
        guard let window = window else {
            return nil
        }
        
        return window
    }
}
