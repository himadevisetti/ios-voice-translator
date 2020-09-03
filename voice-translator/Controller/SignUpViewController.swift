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
import FirebaseFirestore

class SignUpViewController: UIViewController {

    
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElements()
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
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Validate the input fields
    // If valid, returns nil
    // If invalid, return an error string
    func validateFields() -> String? {
       
        // Esnure that all mandatory fields are filled in
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
            return "Please esnure your password is atleast 8 characters, contains an alphabet, a number and a special character"
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
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
                    // There's an error while creating user
                    self.showError("Error creating user")
                    
                } else {
                    // User was created successfully. Store the firstname and lastname in Firestore
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: ["firstname": firstName, "lastname": lastName, "uid": result!.user.uid]) { (error) in
                        if error != nil {
                            self.showError("Error saving user data")
                        }
                    }
                }
                
                // Transition to landing screen
                self.transitionToLanding()
                
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
