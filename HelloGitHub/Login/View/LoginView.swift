//
//  LoginView.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/3.
//

import UIKit

class LoginView: UIView {

    private lazy var userAccountTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textColor = .label
        textField.font = UIFont.systemFont(ofSize: 12)
        textField.textAlignment = .left
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var userPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textColor = .label
        textField.font = UIFont.systemFont(ofSize: 12)
        textField.textAlignment = .left
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(onTapLogin), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func configureView() {
        self.addSubview(userAccountTextField)
        self.addSubview(userPasswordTextField)
        self.addSubview(loginButton)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            
            userAccountTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            userAccountTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            userAccountTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 22),
            userAccountTextField.heightAnchor.constraint(equalToConstant: 44),
            
            userPasswordTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            userPasswordTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            userPasswordTextField.topAnchor.constraint(equalTo: userAccountTextField.bottomAnchor, constant: 5),
            userPasswordTextField.heightAnchor.constraint(equalToConstant: 44),

            loginButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        if #available(iOS 15.0, *) {
            let buttonTop = self.keyboardLayoutGuide.topAnchor.constraint(equalToSystemSpacingBelow: loginButton.bottomAnchor, multiplier: 1.0)
            buttonTop.identifier = "buttonTop"
            self.keyboardLayoutGuide.setConstraints([buttonTop], activeWhenAwayFrom: .top)

            let buttonBottom = loginButton.topAnchor.constraint(equalToSystemSpacingBelow: self.keyboardLayoutGuide.bottomAnchor, multiplier: 1.0)
            buttonBottom.identifier = "buttonBottom"
            self.keyboardLayoutGuide.setConstraints([buttonBottom], activeWhenNearEdge: .top)
            
        } else {
            let buttonTop = loginButton.topAnchor.constraint(equalTo: userPasswordTextField.bottomAnchor, constant: 5)
            NSLayoutConstraint.activate([buttonTop])
        }
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
    
    }
}
