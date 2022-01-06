//
//  UIView+Window.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/6.
//

import UIKit

extension UIView {

    func getCurrentWindow() -> UIWindow? {
        guard let window = self.window, let window = window.getWindowsFromScene()  else {
            return nil
        }
        
        return window
    }
    
    func setRootViewController(window: UIWindow, animated: Bool = true, options: UIView.AnimationOptions) {
        
        guard animated else {
            return
        }
        
        UIView.transition(with: window,
                          duration: 0.3,
                          options: options,
                          animations: {},
                          completion: nil)
    }

}
