//
//  SignUpViewController.swift
//  NetworkingGetPostJSON
//
//  Created by Никита Коголенок on 30.04.21.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    // MARK: - Variables
    var activityIndicator: UIActivityIndicatorView!
    /// MARK: - continueButton
    lazy var continueButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        button.center = CGPoint(x: view.center.x, y: view.frame.height - 100)
        button.backgroundColor = .white
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(secondaryColor, for: .normal)
        button.layer.cornerRadius = 4
        button.alpha = 0.5
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        return button
    }()
    // MARK: - Outlet
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        view.addSubview(continueButton)
        setContinueButton(enable: false)
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = secondaryColor
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = continueButton.center
        view.addSubview(activityIndicator)
        
        userNameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillApear),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    }
    // MARK: - Methods
    private func setContinueButton(enable: Bool) {
        if enable {
            continueButton.alpha = 1.0
            continueButton.isEnabled = true
        } else {
            continueButton.alpha = 0.5
            continueButton.isEnabled = false
        }
    }
    
    @objc private func textFieldChanged() {
        
        guard let userName = userNameTextField.text, let email = emailTextField.text,
              let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text
        else { return }
        
        let formFilled = !(userName.isEmpty) && !(email.isEmpty) && !(password.isEmpty) && confirmPassword == password
        
        setContinueButton(enable: formFilled)
    }
    
    @objc private func keyboardWillApear(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        continueButton.center = CGPoint(x: view.center.x,
                                        y: view.frame.height - keyboardFrame.height - 16.0 - continueButton.frame.height / 2)
        
        activityIndicator.center = continueButton.center
    }
    
    @objc private func handleSignUp() {
        setContinueButton(enable: false)
        continueButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let userName = userNameTextField.text
        else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                print(error.localizedDescription)
                
                self.setContinueButton(enable: true)
                self.continueButton.setTitle("Continue", for: .normal)
                self.activityIndicator.stopAnimating()
                
                return
            }
            print("Successfully logged into Firebase with User Email")
            
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                changeRequest.displayName = userName
                changeRequest.commitChanges { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                        
                        self.setContinueButton(enable: true)
                        self.continueButton.setTitle("Continue", for: .normal)
                        self.activityIndicator.stopAnimating()
                    }
                    print("User display name changed!")
                    
                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    // MARK: - Action
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
