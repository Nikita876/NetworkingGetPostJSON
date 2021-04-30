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
import GoogleSignIn

class LoginViewController: UIViewController {
    // MARK: - Variables
    var userProfile: UserProfile?
    /// MARK: - FacebookLogin Button
    lazy var fbLoginButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: 360, width: view.frame.width - 64, height: 50)
        loginButton.delegate = self
        
        return loginButton
    }()
    /// MARK: - CustomFBLoginButton
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
    /// MARK: - GoogleLoginButton
    lazy var googleLoginButton: GIDSignInButton = {
        let loginButton = GIDSignInButton()
        loginButton.frame = CGRect(x: 32, y: 360 + 160, width: view.frame.width - 64, height: 50)
        
        return loginButton
    }()
    /// MARK: - customGoogleLoginButton
    lazy var customGoogleLoginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.frame = CGRect(x: 32, y: 360 + 240, width: view.frame.width - 64, height: 50)
        loginButton.backgroundColor = .white
        loginButton.setTitle("Login with Google", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(handleCustomGoogleLogin), for: .touchUpInside)
        
        return loginButton
    }()
    /// MARK: - signInWithEmail
    lazy var signInWithEmail: UIButton = {
        let loginButton = UIButton()
        loginButton.frame = CGRect(x: 32, y: 360 + 320, width: view.frame.width - 64, height: 50)
        loginButton.setTitle("Sign In with Email", for: .normal)
        loginButton.addTarget(self, action: #selector(openSignInVC), for: .touchUpInside)
        
        return loginButton
    }()
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        setupViews()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().presentingViewController = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        view.addSubview(fbLoginButton)
        view.addSubview(customFBLoginButton)
        view.addSubview(googleLoginButton)
        view.addSubview(customGoogleLoginButton)
        view.addSubview(signInWithEmail)
    }
    
    private func openMainViewController() {
        dismiss(animated: true)
    }
    
    @objc private func openSignInVC() {
        performSegue(withIdentifier: "SignIn", sender: self)
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
            print("Successfully saved into firebase database")
            self.openMainViewController()
        }
    }
}
// MARK: - Google SDK LoginViewController: GIDSignInDelegate
extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print("Failsed to log into Google: ", error)
            return
        }
        print("Successfully logged into Google")
        
        if let userName = user.profile.name, let userEmail = user.profile.email {
            let userData = ["name": userName, "email": userEmail]
            userProfile = UserProfile(data: userData)
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            
            if let error = error {
                print("Something went wrong with our Google user: ", error)
                return
            }
            print("Successfully logged into Firebase with Google")
            self.saveIntoFirebase()
        }
    }
    
    @objc private func handleCustomGoogleLogin() {
        GIDSignIn.sharedInstance()?.signIn()
    }
}
