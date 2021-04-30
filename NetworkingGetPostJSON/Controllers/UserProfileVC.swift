//
//  UserProfileVC.swift
//  NetworkingGetPostJSON
//
//  Created by Никита Коголенок on 27.04.21.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class UserProfileVC: UIViewController {
    // MARK: - Variable
    private var provider: String?
    private var currentUser: CurrentUser?
    // MARK: - Outlet
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // MARK: - FacebookLogin Button
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 32,
                              y: view.frame.height - 172,
                              width: view.frame.width - 64,
                              height: 50)
        button.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return button
    }()
    // MARK: - Life cycle
    /// MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        self.userNameLabel.isHidden = true
        setupViews()
    }
    /// MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchingUserData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        view.addSubview(logoutButton)
    }
}

// MARK: - Facebook SDK LoginViewController: LoginButtonDelegate
extension UserProfileVC {
    
    private func openLoginViewController() {
        do {
            try Auth.auth().signOut()
            
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(loginViewController, animated: true)
                return
            }
        } catch let error {
            print("Failed to sign out with error", error.localizedDescription)
        }
    }
    
    private func fetchingUserData() {
        
        if Auth.auth().currentUser != nil {
            if let userName = Auth.auth().currentUser?.displayName {
                activityIndicator.stopAnimating()
                userNameLabel.isHidden = false
                userNameLabel.text = getProviderData(with: userName)
            } else {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Database.database().reference()
                    .child("users")
                    .child(uid)
                    .observeSingleEvent(of: .value) { (snapshot) in
                        
                        guard let userData = snapshot.value as? [String: Any] else { return }
                        self.currentUser = CurrentUser(uid: uid, data: userData)
                        
                        self.activityIndicator.stopAnimating()
                        self.userNameLabel.isHidden = false
                        self.userNameLabel.text = self.getProviderData(with: self.currentUser?.name ?? "Noname")
                        
                    } withCancel: { (error) in
                        print(error)
                    }
            }
        }
    }
    
    @objc func signOut() {
        
        if let providerData = Auth.auth().currentUser?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                case "facebook.com":
                    LoginManager().logOut()
                    print("User did log out of facebook")
                    openLoginViewController()
                case "google.com":
                    GIDSignIn.sharedInstance()?.signOut()
                    print("User did log out of google")
                    openLoginViewController()
                case "password":
                    try! Auth.auth().signOut()
                    print("User did sign out")
                    openLoginViewController()
                default:
                    print("User is signed in with \(userInfo.providerID)")
                }
            }
        }
    }
    
    private func getProviderData(with user: String) -> String {
        
        var greetings = ""
        
        if let providerData = Auth.auth().currentUser?.providerData {
            for userInfo in providerData {
                
                switch userInfo.providerID {
                case "facebook.com":
                    provider = "Facebook"
                case "google.com":
                    provider = "Google"
                case "password":
                    provider = "Email"
                default:
                    break
                }
            }
            
            greetings = "\(user) Logged in with \(provider!)"
        }
        return greetings
    }
}
