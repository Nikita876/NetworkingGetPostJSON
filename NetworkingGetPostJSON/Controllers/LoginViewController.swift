//
//  LoginViewController.swift
//  NetworkingGetPostJSON
//
//  Created by Никита Коголенок on 27.04.21.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    // MARK: - Variable
    var userProfile: UserProfile?
    // MARK - FacebookLogin Button
    lazy var fbLoginButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: 360, width: view.frame.width - 64, height: 50)
        loginButton.delegate = self
        
        return loginButton
    }()
    lazy var customFBLoginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        loginButton.setTitle("Login with Facebook", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.frame = CGRect(x: 32, y: 360 + 80, width: view.frame.width - 64, height: 50)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        
        return loginButton
    }()
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        setupViews()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        view.addSubview(fbLoginButton)
        view.addSubview(customFBLoginButton)
    }
}
// MARK: - Facebook SDK LoginViewController: LoginButtonDelegate
extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if error != nil {
            print(error)
            return
        }
        guard AccessToken.isCurrentAccessTokenActive else { return }
        
        print("Successfully logged in with faceook...")
        singIntoFirebase()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        print("Did log out of facebook")
    }
    
    private func openMainViewController() {
        dismiss(animated: true)
    }
    
    @objc private func handleCustomFBLogin() {
        LoginManager().logIn(permissions: ["email", "public_profile"], from: self) { (result, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let result = result else { return }
            if result.isCancelled { return }
            else {
                self.singIntoFirebase()
            }
        }
    }
    
    private func singIntoFirebase() {
        let accessToken = AccessToken.current
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        Auth.auth().signIn(with: credentials) { (user, error) in
            
            if let error = error {
                print("Something went wrong with our facebook user: ", error)
                return
            }
            
            print("Successfully logged in with our FB user: ")
            
            self.fetchFacebookFields()
        }
    }
    
    private func fetchFacebookFields() {
        GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start { (_, result, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            if let userData = result as? [String: Any] {
                self.userProfile = UserProfile(data: userData)
                print(userData)
                print("Name is", self.userProfile?.name ?? nil)
                print("Email is", self.userProfile?.email ?? nil)
                
                self.saveIntoFirebase()
            }
        }
    }
    
    private func saveIntoFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userData = ["name": userProfile?.name, "email": userProfile?.email] as [String : Any]
        let values = [uid: userData]
        
        Database.database().reference().child("users").updateChildValues(values) { (error, _) in
            if let error = error {
                print(error)
                return
            }
            print("Seccessfully saved into firebase database")
            self.openMainViewController()
        }
        
    }
}
