//
//  UserAccount.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/3.
//

import Foundation

struct UserAccount: Codable {
    let login: String
    let id: Int
    let node_id: String
    let avatar_url: String?
    let gravatar_id: String?
    let url: String?
    let html_url: String?
    let followers_url: String?
    let following_url: String?
    let subscriptions_url: String?
    let organizations_url: String?
    let repos_url: String?
    let received_events_url: String?
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
    let private_gists: Int?
    let total_private_repos: Int?
    let owned_private_repos: Int?
    let disk_usage: Double?
    let collaborators: Int?
    let two_factor_authentication: Bool?
    let plan: Plan?
}

struct Plan: Codable {
    let name: String?
    let space: Double
    let private_repos: Int
    let collaborators: Int
}

extension Plan: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(space)
        hasher.combine(private_repos)
        hasher.combine(collaborators)
    }

    static func == (lhs: Plan, rhs: Plan) -> Bool {
        return lhs.name == rhs.name && lhs.space == rhs.space && lhs.private_repos == rhs.private_repos && lhs.collaborators == rhs.collaborators
    }
}

extension UserAccount: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UserAccount, rhs: UserAccount) -> Bool {
        return lhs.id == rhs.id
    }
}
