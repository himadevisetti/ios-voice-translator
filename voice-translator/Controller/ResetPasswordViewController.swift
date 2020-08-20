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
        Utilities.styleFilledButton(resetPasswordButton)
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
    
    func showMessage(_ message:String) {
        
        errorLabel.text = message
        errorLabel.textColor = UIColor.black
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
            Auth.auth().sendPasswordReset(withEmail: email) { (err) in
                
                // Check for errors
                if err != nil {
                    // There's an error while signing in the user
                    self.showError(err!.localizedDescription)
                }
                else {
                    // Transition to landing screen
                    self.showMessage("An email has been sent to the email address provided by you. Please follow the instructions specified in the email.")
                }
            }
            
        }

    }
    
}
