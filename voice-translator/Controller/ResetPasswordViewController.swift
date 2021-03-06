//
//  ResetPasswordViewController.swift
//  voice-translator
//
//  Created by user178116 on 8/19/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Text fields should be setup in viewDidLayoutSubviews() instead of viewDidLoad() in order to adjust width according to device size
        Utilities.styleTextField(emailText)
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
        self.navigationItem.title = Constants.Storyboard.resetPasswordScreenTitle
        
        // Hide the back button to avoid navigating back to login screen
        self.navigationItem.hidesBackButton = true
        
    }
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
                    
        // Style the UI Elements
        Utilities.styleFilledButton(resetPasswordButton)
    }

    // Validate the input fields
    // If valid, returns nil
    // If invalid, return an error string
    func validateFields() -> String? {
       
        // Esnure that all mandatory fields are filled in
        if emailText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in the email address."
        }
        
        // Check email is valid
        let cleanEmail = emailText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isValidEmail(cleanEmail) == false {
            
            // Email is invalid
            return "Please enter a valid email address"
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    @IBAction func resetPasswordTapped(_ sender: Any) {
        
        // Validate the input
        let error = validateFields()
        
        if error != nil {
            // Input is not valid
            showError(error!)
            
        } else {
            
            // Create clean versions of input data
            let email = emailText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            resetPassword(email: email)
            
        }

    }
    
    func resetPassword(email: String) {
        
        let actionCodeSettings = Utilities.generateActionCodeSettings(email: email)
        
        // Send password reset link
        Auth.auth().sendPasswordReset(withEmail: email, actionCodeSettings: actionCodeSettings) { (err) in
            if let err = err {
                Log(self).error("Error while sending reset password email to \(email): \(err.localizedDescription)")
                self.showError(err.localizedDescription)
            }
        }
        
        UserDefaults.standard.set(email, forKey: Constants.Setup.kEmail)
        
        let title = "Reset password"
        let message = "Password reset link sent to email \(email). Please follow the instructions specified in the email to reset your password."
        self.showSuccessAlert(title: title, message: message)
        
    }
    
    func showSuccessAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.emailText.text = ""
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        if let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.loginViewController) as? LoginViewController {
          navigationController?.pushViewController(loginViewController, animated: true)
        }
        
    }
    
}
