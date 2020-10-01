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
                    print(error.code)
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
                    
                    // Save user's firstname and lastname in local cache to display on profile page
                    SharedData.instance.userFirstName = firstName
                    SharedData.instance.userLastName = lastName
                    
                    // Display privacy policy
                    self.displayPrivacyPolicy(email: email, givenName: firstName, familyName: lastName, userId: result!.user.uid)

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
    
    func displayPrivacyPolicy(email: String, givenName: String, familyName: String, userId: String) {
        
        // Create alert
        let alert = UIAlertController(title: "License Agreement", message: "", preferredStyle: .alert)
        alert.setValue(Utilities.formattedLicenseAgreement(), forKey: "attributedMessage")
        
        // Create Decline button
        let declineAction = UIAlertAction(title: "Decline" , style: .destructive) { (action) -> Void in
            let user = Auth.auth().currentUser
            user?.delete { error in
              if let error = error {
                // An error happened.
                self.showError(error.localizedDescription)
              } else {
                // Account deleted.
                print("Account was deleted")
              }
            }
            
            self.showError("Please accept privacy policy in order to access the app")
        }
        
        // Create Accept button
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { (action) -> Void in
            // first-time user and hence save user info to firestore
            let errMessage = Utilities.saveUserToFirestore(email: email, firstName: givenName, lastName: familyName, uid: userId)
            
            if errMessage != nil {
                // user doesn't need to know that there's an error while saving their data to DB
                // write it to the application log and monitor such errors
                print(errMessage!)
            }
            // Transition to landing screen
            self.transitionToLanding()
        }
        
        // Add task to tableview buttons
        alert.addAction(declineAction)
        alert.addAction(acceptAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
