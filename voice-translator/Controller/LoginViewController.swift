//
//  ViewController.swift
//  voice-translator
//
//  Created by user178116 on 8/17/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpLink: UIButton!
    @IBOutlet weak var forgotPasswordLink: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUpElements()
        
    }
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
                    
        // Style the UI Elements
        Utilities.styleTextField(emailText)
        Utilities.styleTextField(passwordText)
        Utilities.styleFilledButton(logInButton)
        
    }

    // Validate the input fields
    // If valid, returns nil
    // If invalid, return an error string
    func validateFields() -> String? {
       
        // Esnure that all mandatory fields are filled in
        if emailText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
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
            return "Please esnure your password is atleast 8 characters, contains an alphabet, a number and a special character"
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    @IBAction func logInTapped(_ sender: Any) {
        
        // Validate the input
        let error = validateFields()
        
        if error != nil {
            // Input is not valid
            showError(error!)
            
        } else {
            
            // Create clean versions of input data
            let email = emailText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Sign in the user
            Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
                
                // Check for errors
                if err != nil {
                    // There's an error while signing in the user
                    self.showError(err!.localizedDescription)
                }
                else {
                    // Transition to landing screen
                    self.transitionToLanding()
                }
  
            }
            
        }
        
    }
    
    // Transition to landing screen
    func transitionToLanding() {
        
        let landingViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.landingViewController) as? LandingViewController
        
        view.window?.rootViewController = landingViewController
        view.window?.makeKeyAndVisible()
        
    }
    
}


