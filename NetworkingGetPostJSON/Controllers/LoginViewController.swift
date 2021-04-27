//
//  LoginViewController.swift
//  NetworkingGetPostJSON
//
//  Created by Никита Коголенок on 27.04.21.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    let gradient = CAGradientLayer()
    // MARK - FacebookLogin Button
    lazy var fbLoginButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: 320, width: view.frame.width - 64, height: 50)
        loginButton.delegate = self
        return loginButton
    }()
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        if AccessToken.isCurrentAccessTokenActive {
            print("The user is logged in ")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        view.addSubview(fbLoginButton)
    }
}
// MARK: - LoginViewController
extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if error != nil {
            print(error)
            return
        }
        print("Successfully logged in with faceook...")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        print("Did log out of facebook")
    }
    
    
}
