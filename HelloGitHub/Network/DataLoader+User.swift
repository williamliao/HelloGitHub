//
//  DataLoader+User.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/3.
//

import Foundation

extension DataLoader {
    // MARK: Private Constants
    private static let accessTokenKey = "accessToken"
    private static let refreshTokenKey = "refreshToken"
    private static let usernameKey = "username"
    private static let expiresKey = "expires"
    private static let refreshExpiresKey = "refreshExpires"
    private static let tokenKey = "token"
    private static let tryKey = "try"

    // MARK: Properties
    static var accessToken: String? {
        get {
          UserDefaults.standard.string(forKey: accessTokenKey)
        }
        set {
          UserDefaults.standard.setValue(newValue, forKey: accessTokenKey)
        }
    }

    static var refreshToken: String? {
        get {
          UserDefaults.standard.string(forKey: refreshTokenKey)
        }
        set {
          UserDefaults.standard.setValue(newValue, forKey: refreshTokenKey)
        }
    }

    static var username: String? {
        get {
          UserDefaults.standard.string(forKey: usernameKey)
        }
        set {
          UserDefaults.standard.setValue(newValue, forKey: usernameKey)
        }
    }
    
    static var expires: Double? {
        get {
          UserDefaults.standard.double(forKey: expiresKey)
        }
        set {
          UserDefaults.standard.setValue(newValue, forKey: expiresKey)
        }
    }
    
    static var refreshExpires: Double? {
        get {
          UserDefaults.standard.double(forKey: refreshExpiresKey)
        }
        set {
          UserDefaults.standard.setValue(newValue, forKey: refreshExpiresKey)
        }
    }
    
    static var token: TokenResponse? {
        get {
            try? UserDefaults.standard.getObject(forKey: tokenKey, castTo: TokenResponse.self)
        }
        set {
            do {
                try UserDefaults.standard.setObject(newValue, forKey: tokenKey)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    static var giveATry: String? {
        get {
          UserDefaults.standard.string(forKey: tryKey)
        }
        set {
          UserDefaults.standard.setValue(newValue, forKey: tryKey)
        }
    }
    
    
}
