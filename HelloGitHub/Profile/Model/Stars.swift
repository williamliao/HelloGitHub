//
//  Stars.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/6.
//

import Foundation

struct StarsResponse: Codable {
    let id: Int
    let node_id: String
    let name: String
    let full_name: String
    let isPrivate: Bool
    let owner: Owner
    let html_url: String
    let description: String?
    let fork: Bool
    let url: String
    let forks_url: String
    let keys_url: String
    let collaborators_url: String
    let teams_url: String
    let hooks_url: String
    let issue_events_url: String
    let events_url: String
    let assignees_url: String
    let branches_url: String
    let tags_url: String
    let blobs_url: String
    let git_tags_url: String
    let git_refs_url: String
    let trees_url: String
    let statuses_url: String
    let languages_url: String
    let stargazers_url: String
    let contributors_url: String
    let subscribers_url: String
    let subscription_url: String
    let commits_url: String
    let git_commits_url: String
    let comments_url: String
    let issue_comment_url: String
    let contents_url: String
    let compare_url: String
    let merges_url: String
    let archive_url: String
    let downloads_url: String
    let issues_url: String
    let pulls_url: String
    let milestones_url: String
    let notifications_url: String
    let labels_url: String
    let releases_url: String
    let deployments_url: String
    let created_at: String
    let updated_at: String
    let pushed_at: String
    let git_url: String
    let ssh_url: String
    let clone_url: String
    let svn_url: String
    let homepage: String?
    let size: Int
    let stargazers_count: Int
    let watchers_count: Int
    let language: String?
    let has_issues: Bool
    let has_projects: Bool
    let has_downloads: Bool
    let has_wiki: Bool
    let has_pages: Bool
    let forks_count: Int
    let mirror_url: Mirror_url?
    let archived: Bool
    let disabled: Bool
    let open_issues_count: Int
    let license: License?
    let allow_forking: Bool
    let is_template: Bool
    let topics: [String]
    let visibility: String
    let forks: Int
    let open_issues: Int
    let watchers: Int
    let default_branch: String
    
    private enum CodingKeys : String, CodingKey {
        case id
        case node_id
        case name
        case full_name
        case isPrivate = "private"
        case owner
        case html_url
        case description
        case fork
        case url
        case forks_url
        case keys_url
        case collaborators_url
        case teams_url
        case hooks_url
        case issue_events_url
        case events_url
        case assignees_url
        case branches_url
        case tags_url
        case blobs_url
        case git_tags_url
        case git_refs_url
        case trees_url
        case statuses_url
        case languages_url
        case stargazers_url
        case contributors_url
        case subscribers_url
        case subscription_url
        case commits_url
        case git_commits_url
        case comments_url
        case issue_comment_url
        case contents_url
        case compare_url
        case merges_url
        case archive_url
        case downloads_url
        case issues_url
        case pulls_url
        case milestones_url
        case notifications_url
        case labels_url
        case releases_url
        case deployments_url
        case created_at
        case updated_at
        case pushed_at
        case git_url
        case ssh_url
        case clone_url
        case svn_url
        case homepage
        case size
        case stargazers_count
        case watchers_count
        case language
        case has_issues
        case has_projects
        case has_downloads
        case has_wiki
        case has_pages
        case forks_count
        case mirror_url
        case archived
        case disabled
        case open_issues_count
        case license
        case allow_forking
        case is_template
        case topics
        case visibility
        case forks
        case open_issues
        case watchers
        case default_branch
    }
}

extension StarsResponse: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: StarsResponse, rhs: StarsResponse) -> Bool {
        return lhs.id == rhs.id
    }
}
