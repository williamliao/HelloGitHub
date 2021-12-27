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

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = SearchViewModel(dataLoader: DataLoader())
        searchView = SearchView(viewModel: viewModel)
        searchView.createView()
        searchView.configureCollectionView()
        searchView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(searchView)
        
        NSLayoutConstraint.activate([
            searchView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            searchView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            searchView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])
        
        viewModel.querySearch(query: "tetris")
    }
}
