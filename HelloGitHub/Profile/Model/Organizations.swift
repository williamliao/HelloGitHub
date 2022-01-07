//
//  Organizations.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/7.
//

import Foundation

struct OrganizationsResponse: Codable {
    let organizations: [Organizations]
}

struct Organizations: Codable {
    let login: String
    let id: Int
    let node_id: String
    let url: String
    let repos_url: String
    let events_url: String
    let hooks_url: String
    let issues_url: String
    let members_url: String
    let public_members_url: String
    let avatar_url: String
    let description: String?
}

extension Organizations: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Organizations, rhs: Organizations) -> Bool {
        return lhs.id == rhs.id
    }
}
