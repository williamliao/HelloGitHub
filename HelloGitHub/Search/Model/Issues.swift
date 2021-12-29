//
//  Issues.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/28.
//

import Foundation

struct Issues: Codable {
    var total_count: Int
    var incomplete_results: Bool
    var items: [IssuesItems]
}

extension Issues: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(total_count)
        hasher.combine(incomplete_results)
        hasher.combine(items)
    }

    static func == (lhs: Issues, rhs: Issues) -> Bool {
        return lhs.total_count == rhs.total_count && lhs.incomplete_results == rhs.incomplete_results && lhs.items == rhs.items
    }
}

struct Assignee: Codable {
}

struct Closed_at: Codable {
}

struct Creator: Codable {
    let login: String
    let id: Int
    let node_id: String
    let avatar_url: String
    let gravatar_id: String
    let url: String
    let html_url: String
    let followers_url: String
    let following_url: String
    let gists_url: String
    let starred_url: String
    let subscriptions_url: String
    let organizations_url: String
    let repos_url: String
    let events_url: String
    let received_events_url: String
    let type: String
    let site_admin: Bool
}

struct IssuesItems: Codable {
    let url: String
    let repository_url: String
    let labels_url: String
    let comments_url: String
    let events_url: String
    let html_url: String
    let id: Int
    let node_id: String
    let number: Int
    let title: String
    let user: User
    let labels: [Labels]
    let state: String
    let assignee: Assignee
    let milestone: Milestone?
    let comments: Int
    let created_at: String
    let updated_at: String
    let closed_at: Closed_at
    let pull_request: Pull_request?
    let body: String?
    let score: Int
    let locked: Bool
    let author_association: String
}

extension IssuesItems: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: IssuesItems, rhs: IssuesItems) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Labels: Codable {
    let id: Int
    let node_id: String
    let url: String
    let name: String
    let color: String
}

struct Milestone: Codable {
    let url: String?
    let html_url: String?
    let labels_url: String?
    let id: Int
    let node_id: String
    let number: Int
    let state: String
    let title: String
    let description: String?
    let creator: Creator
    let open_issues: Int?
    let closed_issues: Int?
    let created_at: Date
    let updated_at: String?
    let closed_at: String?
    let due_on: String?
}

struct Pull_request: Codable {
    let url: String
    let html_url: String
    let diff_url: String
    let patch_url: String
}

struct User: Codable {
    let login: String
    let id: Int
    let node_id: String
    let avatar_url: String
    let gravatar_id: String
    let url: String
    let html_url: String
    let followers_url: String
    let following_url: String
    let gists_url: String
    let starred_url: String
    let subscriptions_url: String
    let organizations_url: String
    let repos_url: String
    let events_url: String
    let received_events_url: String
    let type: String
    let site_admin: Bool
}
