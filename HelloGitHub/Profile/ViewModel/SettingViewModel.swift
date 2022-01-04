//
//  SettingViewModel.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/4.
//

import Foundation

class SettingViewModel {
    
    private let dataLoader: DataLoader
    private(set) var isFetching = false
    
    var user: UserAccount!
    
    var reloadData: (() -> Void)?
    var showError: ((_ error:NetworkError) -> Void)?
    
    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }
}

extension SettingViewModel {
    func fetchUser() async {
        
        dataLoader.decoder.dateDecodingStrategy = .iso8601
        
        do {
            let result = try await dataLoader.fetch(EndPoint.fetchUsers(), decode: {json -> UserAccount? in
                guard let feedResult = json as? UserAccount else { return  nil }
                return feedResult
            })
            
            isFetching = false
            switch result {
                case .success(let user):
                
                    self.user = user
                    reloadData?()
            
                case .failure(let error):
                    showError?(error)
            }
            
        }  catch  {
            print("searchRepositories error \(error)")
            showError?(error as? NetworkError ?? NetworkError.unKnown)
        }
    }
}
