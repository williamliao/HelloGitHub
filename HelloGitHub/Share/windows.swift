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
}
