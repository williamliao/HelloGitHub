//
//  Repositories.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/27.
//

import Foundation

struct Repositories: Codable {
    let total_count: Int
    let incomplete_results: Bool
    let items: [Item]
    let license: License
}

extension Repositories: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(total_count)
        hasher.combine(incomplete_results)
        hasher.combine(items)
        hasher.combine(license)
    }

    static func == (lhs: Repositories, rhs: Repositories) -> Bool {
        return lhs.total_count == rhs.total_count && lhs.incomplete_results == rhs.incomplete_results && lhs.items == rhs.items && lhs.license == rhs.license
    }
}

struct Item: Codable {
    let id: String
    let node_id: String
    let name: String
    let full_name: String
    let owner: Owner
    let private_repo: Bool
    let html_url: URL
    let description: String
    let fork: Bool
    let url: URL
    let created_at: Date
    let updated_at: Date
    let pushed_at: Date
    let homepage: URL
    let size: Int
    let stargazers_count: Int
    let watchers_count: Int
    let language: String
    let forks_count: Int
    let open_issues_count: Int
    let master_branch: String
    let default_branch: String
    let score: Int
    let archive_url: URL
    let assignees_url: URL
    let blobs_url: URL
    let branches_url: URL
    let collaborators_url: URL
    let comments_url: URL
    let commits_url: URL
    let compare_url: URL
    let contents_url: URL
    let contributors_url: URL
    let deployments_url: URL
    let downloads_url: URL
    let events_url: URL
    let forks_url: URL
    let git_commits_url: URL
    let git_refs_url: URL
    let git_tags_url: URL
    let git_url: URL
    let issue_comment_url: URL
    let issue_events_url: URL
    let issues_url: URL
    let keys_url: URL
    let labels_url: URL
    let languages_url: URL
    let merges_url: URL
    let milestones_url: URL
    let notifications_url: URL
    let pulls_url: URL
    let releases_url: URL
    let ssh_url: URL
    let stargazers_url: URL
    let statuses_url: URL
    let subscribers_url: URL
    let subscription_url: URL
    let tags_url: URL
    let teams_url: URL
    let trees_url: URL
    let clone_url: URL
    let mirror_url: URL
    let hooks_url: URL
    let svn_url: URL
    let forks: Int
    let open_issues: Int
    let watchers: Int
    let has_issues: Bool
    let has_projects: Bool
    let has_pages: Bool
    let has_wiki: Bool
    let has_downloads: Bool
    let archived: Bool
    let disabled: Bool
    let visibility: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case node_id
        case name
        case full_name
        case owner
        case private_repo = "private"
        case html_url
        case description
        case fork
        case url
        case created_at
        case updated_at
        case pushed_at
        case homepage
        case size
        case stargazers_count
        case watchers_count
        case language
        case forks_count
        case open_issues_count
        case master_branch
        case default_branch
        case score
        case archive_url
        case assignees_url
        case blobs_url
        case branches_url
        case collaborators_url
        case comments_url
        case commits_url
        case compare_url
        case contents_url
        case contributors_url
        case deployments_url
        case downloads_url
        case events_url
        case forks_url
        case git_commits_url
        case git_refs_url
        case git_tags_url
        case git_url
        case issue_comment_url
        case issue_events_url
        case issues_url
        case keys_url
        case labels_url
        case languages_url
        case merges_url
        case milestones_url
        case notifications_url
        case pulls_url
        case releases_url
        case ssh_url
        case stargazers_url
        case statuses_url
        case subscribers_url
        case subscription_url
        case tags_url
        case teams_url
        case trees_url
        case clone_url
        case mirror_url
        case hooks_url
        case svn_url
        case forks
        case open_issues
        case watchers
        case has_issues
        case has_projects
        case has_pages
        case has_wiki
        case has_downloads
        case archived
        case disabled
        case visibility
    }
}

extension Item: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Owner: Codable {
    let login: String
    let id: String
    let node_id: String
    let avatar_url: URL
    let gravatar_id: String
    let url: URL
    let received_events_url: URL
    let type: String
    let html_url: URL
    let followers_url: URL
    let following_url: URL
    let gists_url: URL
    let starred_url: URL
    let subscriptions_url: URL
    let organizations_url: URL
    let repos_url: URL
    let events_url: URL
    let site_admin: Bool
}

extension Owner: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Owner, rhs: Owner) -> Bool {
        return lhs.id == rhs.id
    }
}

struct License: Codable {
    let key: String
    let name: String
    let url: URL
    let spdx_id: String
    let node_id: String
    let html_url: URL
}

extension License: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }

    static func == (lhs: License, rhs: License) -> Bool {
        return lhs.key == rhs.key
    }
}
