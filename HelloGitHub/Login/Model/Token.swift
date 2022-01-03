//
//  Token.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/3.
//

import Foundation

struct TokenResponse: Codable {
    var access_token: String?
    var expires_in: Int?
    var refresh_token: String?
    var refresh_token_expires_in: Int?
    var scope: String?
    var token_type: String?
}
