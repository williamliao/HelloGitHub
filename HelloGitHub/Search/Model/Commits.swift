//
//  Commits.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/28.
//

import Foundation

struct Commits: Codable {
    var total_count: Int
    var incomplete_results: Bool
    var items: [CommitItem]
    
    enum CodingKeys: String, CodingKey {
        case total_count
        case incomplete_results
        case items
    }
}

extension Commits: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(total_count)
        hasher.combine(incomplete_results)
        hasher.combine(items)
    }

    static func == (lhs: Commits, rhs: Commits) -> Bool {
        return lhs.total_count == rhs.total_count && lhs.incomplete_results == rhs.incomplete_results && lhs.items == rhs.items
    }
}

struct CommitItem: Codable {
    let url: String?
    let sha: String?
    let html_url: String?
    let comments_url: String?
    let commit: Commit
    let author: Author?
    let committer: Committer?
    let parents: [Parents]
    let repository: Repository
    let score: Int?
    let node_id: String?
}

extension CommitItem: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(sha)
        hasher.combine(node_id)
    }

    static func == (lhs: CommitItem, rhs: CommitItem) -> Bool {
        return lhs.sha == rhs.sha && lhs.node_id == rhs.node_id
    }
}

struct Commit: Codable {
    let url: String?
    let author: AuthorCommit
    let committer: AuthorCommitter
    let message: String
    let tree: Tree
}

struct AuthorCommit:Codable {
    let date: String?
    let name: String
    let email: String
    let comment_count: Int?
}

struct AuthorCommitter: Codable {
    let date: String?
    let name: String
    let email: String
}

struct Committer: Codable {
    
}

struct Parents: Codable {
    let url: String?
    let sha: String?
    let html_url: String?
}

struct Tree: Codable {
    let url: String
    let sha: String
}

struct Author: Codable {
    let login: String
    let node_id: String
    let id: Int
    let avatar_url: String?
    let gravatar_id: String?
    let url: String?
    let html_url: String?
    let followers_url: String?
    let following_url: String?
    let gists_url: String?
    let starred_url: String?
    let subscriptions_url: String?
    let organizations_url: String?
    let repos_url: String?
    let events_url: String?
    let received_events_url: String?
    let type: String
    let site_admin: Bool
}

struct Repository: Codable {
    let id: Int
    let node_id: String
    let name: String
    let full_name: String
    let owner: Owner
    let private_repo: Bool
    let html_url: String?
    let description: String?
    let fork: Bool
    let url: String?
    let created_at: Date?
    let updated_at: Date?
    let pushed_at: Date?
    let homepage: String?
    let size: Int?
    let stargazers_count: Int?
    let watchers_count: Int?
    let language: String?
    let forks_count: Int?
    let open_issues_count: Int?
    let master_branch: String?
    let default_branch: String?
    let score: Int?
    let archive_url: String?
    let assignees_url: String?
    let blobs_url: String?
    let branches_url: String?
    let collaborators_url: String?
    let comments_url: String?
    let commits_url: String?
    let compare_url: String?
    let contents_url: String?
    let contributors_url: String?
    let deployments_url: String?
    let downloads_url: String?
    let events_url: String?
    let forks_url: String?
    let git_commits_url: String?
    let git_refs_url: String?
    let git_tags_url: String?
    let git_url: String?
    let issue_comment_url: String?
    let issue_events_url: String?
    let issues_url: String?
    let keys_url: String?
    let labels_url: String?
    let languages_url: String?
    let merges_url: String?
    let milestones_url: String?
    let notifications_url: String?
    let pulls_url: String?
    let releases_url: String?
    let ssh_url: String?
    let stargazers_url: String?
    let statuses_url: String?
    let subscribers_url: String?
    let subscription_url: String?
    let tags_url: String?
    let teams_url: String?
    let trees_url: String?
    let clone_url: String?
    let mirror_url: String?
    let hooks_url: String?
    let svn_url: String?
    let forks: Int?
    let open_issues: Int?
    let watchers: Int?
    let has_issues: Bool?
    let has_projects: Bool?
    let has_pages: Bool?
    let has_wiki: Bool?
    let has_downloads: Bool?
    let archived: Bool?
    let disabled: Bool?
    let visibility: String?
    
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
