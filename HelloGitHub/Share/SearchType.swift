//
//  SearchType.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/28.
//

import Foundation

struct SearchResults: Codable {
    enum SearchType: Codable {
        case repositories
        case issues
        case people
        case organizations
    }
}

extension SearchResults.SearchType: CaseIterable { }

extension SearchResults.SearchType: RawRepresentable {
    typealias RawValue = String

    init?(rawValue: RawValue) {
        switch rawValue {
            case "Repositories": self = .repositories
            case "Issues & Pull": self = .issues
            case "People": self = .people
            case "Organizations": self = .organizations
            default: return nil
        }
    }

    var rawValue: RawValue {
        switch self {
            case .repositories: return "Repositories"
            case .issues: return "Issues & Pull"
            case .people: return "People"
            case .organizations: return "Organizations"
        }
    }
}
