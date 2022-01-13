//
//  LoginView.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/3.
//

import UIKit

class LoginView: UIView {
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(onTapLogin), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Try", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(onTapTry), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func layoutSubviews() {
        tryButton.layer.cornerRadius = tryButton.frame.height/2
        loginButton.layer.cornerRadius = loginButton.frame.height/2
    }
    
    func configureView() {
        self.addSubview(loginButton)
        self.addSubview(tryButton)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            loginButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            loginButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -22),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            
            tryButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            tryButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            tryButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -84),
            tryButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    var viewModel: LoginViewModel
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        configureView()
        configureConstraints()
    }
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onTapTry() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tab = mainStoryboard.instantiateViewController(withIdentifier: "TabBarCtrl") as? UITabBarController
        guard let tab = tab, let window = self.getCurrentWindow() else {
            return
        }
        
        DataLoader.giveATry = "YES"
        
        window.rootViewController = tab
        window.makeKeyAndVisible()
        self.setRootViewController(window: window, options: [.transitionFlipFromLeft])
    }
    
    @objc private func onTapLogin() {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tab = mainStoryboard.instantiateViewController(withIdentifier: "TabBarCtrl") as? UITabBarController
        guard let tab = tab, let window = self.getCurrentWindow() else {
            return
        }
        
        viewModel.authorize(in: window) { token in
            
            DataLoader.accessToken = token.access_token
            DataLoader.refreshToken = token.refresh_token
            DataLoader.expires = token.expires_in
            DataLoader.refreshExpires = token.refresh_token_expires_in
            
            if UserDefaults.standard.object(forKey: "try") != nil {
                UserDefaults.standard.removeObject(forKey: "try")
                UserDefaults.standard.synchronize()
            }
            
            DispatchQueue.main.async {
                
                window.rootViewController = tab
                window.makeKeyAndVisible()
                self.setRootViewController(window: window, options: [.transitionFlipFromLeft])
            }
        }
    }
}
