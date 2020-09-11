//
//  ViewController.swift
//  voice-translator
//
//  Created by user178116 on 8/17/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices

class LoginViewController: UIViewController, GIDSignInDelegate {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpLink: UIButton!
    @IBOutlet weak var forgotPasswordLink: UIButton!
    @IBOutlet weak var stackToShowSocialButtons: UIStackView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        //        Automatically sign in the user.
        //        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        setUpElements()
        
    }
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the UI Elements
        Utilities.styleTextField(emailText)
        Utilities.styleTextField(passwordText)
        Utilities.styleFilledButton(logInButton)
        
        // Align the social buttons in the horizontal stack
        stackToShowSocialButtons.distribution = .fillEqually
        
        setupGoogleButton()
        setupAppleButton()
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
            
            // Save email for later use
            SharedData.instance.userName = email
            
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
    
    func setupGoogleButton() {
        
        let googleButton = UIButton(frame: CGRect(x: 0,y: 0,width: 48,height: 48))
        //      googleButton.center = stackToShowSocialButtons.center
        googleButton.setImage(UIImage(named: "btn_google_dark_focus_ios.png"), for: .normal)
        googleButton.layer.cornerRadius = 5
        //      googleButton.layer.masksToBounds = true
        googleButton.layer.borderColor = .none
        //      googleButton.layer.borderWidth = 2
        googleButton.addTarget(self, action: #selector(googleSignInButtonTapped), for: .touchUpInside)
        
        // Add the Button to Stack View
        stackToShowSocialButtons.addArrangedSubview(googleButton)
    }
    
    @IBAction func googleSignInButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authDataResult, error) in
            if let error = error {
                let authError = error as NSError
                self.showError(authError.localizedDescription)
                return
            }
            if let authorizedUser = authDataResult?.user {
                let email = authorizedUser.email
                let userId = authorizedUser.uid
                let givenName = user.profile.givenName
                let familyName = user.profile.familyName
                
//              print("User \(givenName!), \(familyName!) signed in as \(userId), email: \(email ?? "unknown email")")
                print("User signed in as \(userId), email: \(email ?? "unknown email")")
                
                // Save email for later use
                SharedData.instance.userName = email
                
                // detect iOS app first-time launch
                if(!self.appDelegate.hasAlreadyLaunched) {
                    
                    //set hasAlreadyLaunched to false
                    self.appDelegate.sethasAlreadyLaunched()
                    
                    // first-time user and hence save user info to firestore
                    let errMessage = self.saveUserToFirestore(email: email!, firstName: givenName!, lastName: familyName!, uid: userId)
                    
                    if errMessage != nil {
                        // user doesn't need to know that there's an error while saving their data to DB
                        // write it to the application log and monitor such errors
                        print(errMessage!)
                    }
                }
                
                // Transition to landing screen
                self.transitionToLanding()
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        
    }
    
    func setupAppleButton() {
        //        let appleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
        let appleButton = UIButton(frame: CGRect(x: 0,y: 0,width: 48,height: 48))
        //      appleButton.center = stackToShowSocialButtons.center
        appleButton.setImage(UIImage(named: "White_Logo_Square.png"), for: .normal)
        appleButton.layer.cornerRadius = 5
        appleButton.layer.masksToBounds = true
        appleButton.layer.borderColor = UIColor.black.cgColor
        appleButton.layer.borderWidth = 0.5
        appleButton.addTarget(self, action: #selector(appleSignInButtonTapped), for: .touchUpInside)
        
        // Add the Button to Stack View
        stackToShowSocialButtons.addArrangedSubview(appleButton)
    }
    
    @IBAction func appleSignInButtonTapped(_ sender: Any) {
        performSignInWithApple()
    }
    
    func performSignInWithApple() {
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        authorizationController.performRequests()
    }
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = Utilities.randomNonceString()
        request.nonce = Utilities.sha256(nonce)
        currentNonce = nonce
        
        return request
    }
    
    // Transition to landing screen
    func transitionToLanding() {
        
        let landingViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.landingViewController) as? LandingViewController
        
        view.window?.rootViewController = landingViewController
        view.window?.makeKeyAndVisible()
        
    }
    
    
    // save users to firestore
    func saveUserToFirestore(email: String, firstName: String, lastName: String, uid: String) -> String? {
        // User was created successfully. Store the firstname, lastname and email in Firestore
        let db = Firestore.firestore()
        var errMessage: String? = nil
        db.collection("users").addDocument(data: ["email": email,  "firstname": firstName, "lastname": lastName, "uid": uid]) { (error) in
            if error != nil {
                errMessage = "Error saving user data"
                //                self.showError(errMessage)
            }
        }
        return errMessage
    }
    
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        var errMessage: String
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                errMessage = "Invalid state: A login callback was received, but no login request was sent"
                fatalError(errMessage)
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                errMessage = "Unable to fetch identity token"
                print(errMessage)
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                errMessage = "Unable to serialize token string from data: \(appleIDToken.debugDescription)"
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { (authDataResult, error) in
                if let error = error {
                    let authError = error as NSError
                    self.showError(authError.localizedDescription)
                    return
                }
                if let user = authDataResult?.user {
                    let email = user.email
                    let userId = user.uid
                    let givenName = appleIDCredential.fullName?.givenName
                    let familyName = appleIDCredential.fullName?.familyName
                    
//                  print("User \(givenName!), \(familyName!) signed in as \(userId), email: \(email ?? "unknown email")")
                    print("User signed in as \(userId), email: \(email ?? "unknown email")")
                    
                    // Save email for later use
                    SharedData.instance.userName = email
                    
                    // detect iOS app first-time launch
                    if(!self.appDelegate.hasAlreadyLaunched) {
                        
                        //set hasAlreadyLaunched to false
                        self.appDelegate.sethasAlreadyLaunched()
                        
                        // first-time user and hence save user info to firestore
                        let errMessage = self.saveUserToFirestore(email: email!, firstName: givenName!, lastName: familyName!, uid: userId)
                        
                        if errMessage != nil {
                            // user doesn't need to know that there's an error while saving their data to DB
                            // write it to the application log and monitor such errors
                            print(errMessage!)
                        }
                    }
                    
                    // Transition to landing screen
                    self.transitionToLanding()
                }
            }
        }
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
