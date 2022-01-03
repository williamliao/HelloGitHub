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
        button.layer.cornerRadius = button.frame.height/2
        button.addTarget(self, action: #selector(onTapLogin), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func configureView() {
        self.addSubview(loginButton)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            loginButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            loginButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -22),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
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
    
    @objc private func onTapLogin() {
        viewModel.userDidTapLogin()
    }
}