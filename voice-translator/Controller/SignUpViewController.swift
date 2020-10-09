//
//  SignUpViewController.swift
//  voice-translator
//
//  Created by user178116 on 8/17/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
//import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var logCategory = "Sign up"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpNavigationBarAndItems()
        setUpElements()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func setUpNavigationBarAndItems() {
        
        // Set the screen title
        self.navigationController?.navigationBar.isTranslucent = false
        let attributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 17)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.navigationItem.title = Constants.Storyboard.signUpScreenTitle
        
        // Hide the back button to avoid navigating back to login screen
        self.navigationItem.hidesBackButton = true
        
    }
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the UI elements
        Utilities.styleTextField(firstNameText)
        Utilities.styleTextField(lastNameText)
        Utilities.styleTextField(emailText)
        Utilities.styleTextField(passwordText)
        Utilities.styleFilledButton(signUpButton)
        
        // Disable autofill accessory to save password
        firstNameText.textContentType = .oneTimeCode
        lastNameText.textContentType = .oneTimeCode
        emailText.textContentType = .oneTimeCode
        passwordText.textContentType = .oneTimeCode
        
    }
    
    // Validate the input fields
    // If valid, returns nil
    // If invalid, return an error string
    func validateFields() -> String? {
        
        // Ensure that all mandatory fields are filled in
        if firstNameText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
            || lastNameText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
            || emailText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
            || passwordText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        
        // Check email is valid
        let cleanEmail = emailText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isValidEmail(cleanEmail) == false {
            
            // Email is invalid
            return "Please enter a valid email address"
        }
        
        // Check password is secure
        let cleanPassword = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isValidPassword(cleanPassword) == false {
            
            // Password does not meet the criteria
            return "Please ensure your password is atleast 8 characters, contains an alphabet, a number and a special character"
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        if let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.loginViewController) as? LoginViewController {
            navigationController?.pushViewController(loginViewController, animated: true)
        }
        
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        // Validate the input
        let error = validateFields()
        
        if error != nil {
            // Input is not valid
            showError(error!)
            
        } else {
            
            // Create clean versions of input data
            let firstName = firstNameText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Save email for later use
            SharedData.instance.userName = email
            
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                // Check for errors
                if err != nil {
                    let error = err! as NSError
//                  print(error.code)
                    Log(self).error("Error creating the user : \(err!.localizedDescription)")
                    // There's an error while creating user
//                  self.showError("Error creating user")
                    switch error.code {
                    case AuthErrorCode.wrongPassword.rawValue:
                        self.showError("Wrong password")
                    case AuthErrorCode.invalidEmail.rawValue:
                        self.showError("Invalid email")
                    case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
                        self.showError("AccountExistsWithDifferentCredential")
                    case AuthErrorCode.emailAlreadyInUse.rawValue: //<- Your Error
                        self.showError("Email is already in use")
                    default:
                        self.showError("Unknown error: \(error.localizedDescription)")
                    }
                    
                } else {
                    SharedData.instance.userFirstName = firstName
                    SharedData.instance.userLastName = lastName
                    UserDefaults.standard.set(email, forKey: Constants.Setup.kEmail)
                    UserDefaults.standard.set(firstName, forKey: Constants.Setup.kFirstName)
                    UserDefaults.standard.set(lastName, forKey: Constants.Setup.kLastName)
                    UserDefaults.standard.set(result!.user.uid, forKey: Constants.Setup.kUid)
                    
                    let actionCodeSettings = Utilities.generateActionCodeSettings(email: email)
                    
                    result?.user.sendEmailVerification(with: actionCodeSettings, completion: { error in
                        if let error = error as NSError? {
                            Log(self).error("Error while sending verification email to \(email): \(error.localizedDescription)")
                            self.showError(error.localizedDescription)
                        } else {
                            // inform user about sending verification email
                            let title = "Account verification"
                            let message = "Verification link sent to your email \(email). Please check your email and complete sign up."
                            Log(self).info(message)
                            self.showSuccessAlert(title: title, message: message)
                        }
                    })
                }
            }
        }
    }
    
    func showSuccessAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.emailText.text = ""
            self.passwordText.text = ""
            self.firstNameText.text = ""
            self.lastNameText.text = ""
            
//          self.loginTapped(self)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
