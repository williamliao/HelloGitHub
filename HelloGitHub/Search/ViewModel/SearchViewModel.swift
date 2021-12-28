//
//  SearchViewModel.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/27.
//

import UIKit

class SearchViewModel {
    var repo: Repositories!
    private let dataLoader: DataLoader
    var reloadTableView: (() -> Void)?

    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }

    func querySearch(query: String) {
        
        dataLoader.request(EndPoint.search(matching: query)) { result in
            
            switch result {
                case .success(let repo):
                
                    self.repo = repo
                    self.reloadTableView?()
                    
                case .failure(let error):
                
                    switch error {
                        case .statusCodeError(let code):
                            print(code)
                        default:
                            print(error)
                    }
            }
        }
    }
}
