//
//  ConfirmPasswordViewController.swift
//  voice-translator
//
//  Created by Hima Devisetti on 10/6/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ConfirmPasswordViewController: UIViewController, Loggable {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmPasswordText: UITextField!
    @IBOutlet weak var confirmPasswordButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var logCategory = "ResetPassword"
    
    var email: String?
    var actionCode: String? // oobCode from reset password link
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Text fields should be setup in viewDidLayoutSubviews() instead of viewDidLoad() in order to adjust width according to device size
        Utilities.styleTextField(emailText)
        Utilities.styleTextField(passwordText)
        Utilities.styleTextField(confirmPasswordText)
    }

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
        self.navigationItem.title = Constants.Storyboard.confirmPasswordScreenTitle
        
        // Hide the back button to avoid navigating back to login screen
        self.navigationItem.hidesBackButton = true
        
    }
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the UI Elements
        Utilities.styleFilledButton(confirmPasswordButton)
        emailText.text = email
        
        emailText.textContentType = .oneTimeCode
        passwordText.textContentType = .oneTimeCode
        confirmPasswordText.textContentType = .oneTimeCode
        
    }
    
    // Validate the input fields
    // If valid, returns nil
    // If invalid, return an error string
    func validateFields() -> String? {
        
        // Ensure that all mandatory fields are filled in
        if emailText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
            || passwordText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || confirmPasswordText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
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
        
        // Check passwords match
        let cleanConfirmPassword = confirmPasswordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanConfirmPassword != cleanPassword {
            
            // Passwords do not match
            return "Your passwords do not match. Please check"
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    @IBAction func confirmPasswordTapped(_ sender: Any) {
        
        // Validate the input
        let error = validateFields()
        
        if error != nil {
            // Input is not valid
            showError(error!)
            
        } else {
            
            // Create clean versions of input data
            let email = emailText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Save email for later use
            SharedData.instance.userName = email
            
            // Confirm using oobCode and change password for the user
            Auth.auth().confirmPasswordReset(withCode: actionCode!, newPassword: password) { (err) in
                if let err = err {
                    let error = err as NSError
                    // There's an error while validating the action code for password reset
                    switch error.code {
                    case AuthErrorCode.expiredActionCode.rawValue:
                        Log(self).error("Code expired. Click 'Sign In' -> 'Forgot password' and get the password reset link sent again")
                        self.showError("Code expired. Click 'Sign In' -> 'Forgot password' and get the password reset link sent again")
                    case AuthErrorCode.invalidActionCode.rawValue:
                        Log(self).error("Invalid code. Code is expired or has already been used")
                        self.showError("Invalid code. Code is expired or has already been used")
                    default:
                        Log(self).error("Unknown error: \(error.localizedDescription)")
                        self.showError("Unknown error: \(error.localizedDescription)")
                    }
                } else {
                    
                    // Fetch user's firstname and lastname from database to display on profile page
                    let db = Firestore.firestore()
                    db.collection("users").whereField("email", isEqualTo: email)
                        .getDocuments() { (querySnapshot, err) in
                            if let err = err {
//                              print("Error getting documents: \(err)")
                                Log(self).error("Error fetching user's name from firestore for profile display: \(err.localizedDescription)")
                            } else {
                                for document in querySnapshot!.documents {
                                    let firstName = document.data()["firstname"] as? String
                                    let lastName = document.data()["lastname"] as? String
                                    SharedData.instance.userFirstName = firstName
                                    SharedData.instance.userLastName = lastName
                                }
                            }
                    }
                    
                    // Transition to landing screen
                    self.transitionToLanding()
                }
            }
            
        }
        
    }
    
    // Transition to landing screen
    func transitionToLanding() {
        
        if let landingViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.landingViewController) as? LandingViewController {
            navigationController?.pushViewController(landingViewController, animated: true)
        }
        
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        if let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.loginViewController) as? LoginViewController {
          navigationController?.pushViewController(loginViewController, animated: true)
        }
        
    }
    
}
