//
//  SettingViewController.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/4.
//

import UIKit

class SettingViewController: UIViewController {
    
    var settingView: SettingView!
    var viewModel: SettingViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = SettingViewModel(dataLoader: DataLoader())
        viewModel.showError = { [weak self] error in
            self?.showErrorToast(error: error)
        }
        viewModel.reloadData = { [weak self] in
            self?.settingView.applyInitialSnapshots()
        }
        renderView()
    }
    

    func renderView() {
        self.title = "Setting"
        settingView = SettingView(viewModel: viewModel)
        settingView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(settingView)
        
        NSLayoutConstraint.activate([
            settingView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            settingView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            settingView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            settingView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])
        
        Task {
            await viewModel.fetchUser()
        }
    }

    func showErrorToast(error: NetworkError) {
        switch error {
            case .statusCodeError(let code):
                print(code)
            default:
                print(error)
        }
    }
}
