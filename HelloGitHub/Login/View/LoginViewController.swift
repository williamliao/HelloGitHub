//
//  LoginViewController.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/3.
//

import UIKit

class LoginViewController: UIViewController {
    
    var loginView: LoginView!
    var viewModel: LoginViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        renderView()
    }
    

    func renderView() {
       
        viewModel = LoginViewModel(oauthClient: RemoteOAuthClient())
        
        viewModel.showError = { [weak self] error in
            self?.showErrorToast(error: error)
        }
        
        self.title = "Login"
        loginView = LoginView(viewModel: viewModel)
        loginView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(loginView)
        
        NSLayoutConstraint.activate([
            loginView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            loginView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            loginView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
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
