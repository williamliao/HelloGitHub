//
//  Users.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/29.
//

import Foundation

struct Users: Codable {
    var total_count: Int
    var incomplete_results: Bool
    var items: [UsersItems]
}

extension Users: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(total_count)
        hasher.combine(incomplete_results)
        hasher.combine(items)
    }

    static func == (lhs: Users, rhs: Users) -> Bool {
        return lhs.total_count == rhs.total_count && lhs.incomplete_results == rhs.incomplete_results && lhs.items == rhs.items
    }
}

struct UsersItems: Codable {
    let login: String
    let id: Int
    let node_id: String
    let avatar_url: URL?
    let gravatar_id: String?
    let url: String?
    let html_url: String?
    let followers_url: String?
    let following_url: String?
    let subscriptions_url: String?
    let organizations_url: String?
    let repos_url: String?
    let received_events_url: String?
    let score: Int?
    let type: String
    let gists_url: String?
    let starred_url: String?
    let events_url: String?
    let site_admin: Bool
}

extension UsersItems: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UsersItems, rhs: UsersItems) -> Bool {
        return lhs.id == rhs.id
    }
}

struct UsersInfo: Codable {
    let login: String
    let id: Int
    let node_id: String
    let avatar_url: URL?
    let gravatar_id: String?
    let url: String?
    let html_url: String?
    let followers_url: String?
    let following_url: String?
    let subscriptions_url: String?
    let organizations_url: String?
    let repos_url: String?
    let received_events_url: String?
    let score: Int?
    let type: String
    let gists_url: String?
    let starred_url: String?
    let events_url: String?
    let site_admin: Bool
    let name: String?
    let company: String?
    let blog: String?
    let location: String?
    let email: String?
    let hireable: Bool?
    let bio: String?
    let twitter_username: String?
    let public_repos: Int
    let public_gists: Int
    let followers: Int
    let following: Int
    let created_at: Date
    let updated_at: Date
}

extension UsersInfo: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UsersInfo, rhs: UsersInfo) -> Bool {
        return lhs.id == rhs.id
    }
}

struct UserInfoRespone {
    let users: [Users]
    let info: [UsersInfo]
}


