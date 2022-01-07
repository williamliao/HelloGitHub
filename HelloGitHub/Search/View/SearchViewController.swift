//
//  SearchViewController.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/27.
//

import UIKit

class SearchViewController: UIViewController {
    
    var searchView: SearchView!
    var viewModel: SearchViewModel!
    var repo: Item!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sessionConfiguration = URLSessionConfiguration.default
        
        if let token = DataLoader.accessToken {
            sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(token)"
            ]
        }
        sessionConfiguration.waitsForConnectivity = true

        let session = URLSession(configuration: sessionConfiguration)
        
        viewModel = SearchViewModel(dataLoader: DataLoader(session: session))
        renderView()
    }
    
    func renderView() {
        self.title = "Search GitHub"
        searchView = SearchView(viewModel: viewModel, navItem: self.navigationItem)
        searchView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(searchView)
        
        NSLayoutConstraint.activate([
            searchView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            searchView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            searchView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])
    }
    
    func showErrorToast(error: NetworkError) {
        switch error {
            case .statusCodeError(let code):
                print(code)
            case .queryTimeLimit:
                print("queryTimeLimit")
            default:
                print(error)
        }
    }
}
