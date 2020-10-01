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
        
        // Automatically sign in the user.
//      GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        setupNavigationBarItems()
        setUpElements()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func setupNavigationBarItems() {
        
        // Set the screen title
        self.navigationController?.navigationBar.barTintColor = UIColor.systemIndigo
        self.navigationController?.navigationBar.tintColor = .white // change the Back button color
        self.navigationController?.navigationBar.isTranslucent = false
//      let attributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 17)!]
//      UINavigationBar.appearance().titleTextAttributes = attributes
//      self.navigationItem.title = Constants.Storyboard.homeScreenTitle
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        // Back button shows on login screen when log out is tapped
        // Hide the back button to avoid navigating back from login screen
        self.navigationItem.hidesBackButton = true
        
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
            return "Please ensure your password is atleast 8 characters, contains an alphabet, a number and a special character"
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        
        if let resetPasswordViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.resetPasswordViewController) as? ResetPasswordViewController {
          navigationController?.pushViewController(resetPasswordViewController, animated: true)
        }
        
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        if let signUpViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.signUpViewController) as? SignUpViewController {
          navigationController?.pushViewController(signUpViewController, animated: true)
        }
        
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
                    let error = err! as NSError
                    print(error.code)
                    // There's an error while signing in the user
                    switch error.code {
                    case AuthErrorCode.wrongPassword.rawValue:
                        self.showError("Wrong password")
                    case AuthErrorCode.invalidEmail.rawValue:
                        self.showError("Invalid email")
                    case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
                        self.showError("AccountExistsWithDifferentCredential")
                    default:
                        self.showError("Unknown error: \(error.localizedDescription)")
                    }
                    
                }
                else {
                    // Fetch user's firstname and lastname from database to display on profile page
                    let db = Firestore.firestore()
                    db.collection("users").whereField("email", isEqualTo: email)
                        .getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
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
    
    func setupGoogleButton() {
        
        let googleButton = UIButton(frame: CGRect(x: 0,y: 0,width: 48,height: 48))
        let googleButtonImage = Utilities.resizeImage(image: UIImage(named: "google_logo_custom.png")!, targetSize: CGSize(width: 48, height: 48.0))
        googleButton.setImage(googleButtonImage, for: .normal)
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
                    
                    // display privacy policy
                    self.displayPrivacyPolicy(email: email!, givenName: givenName!, familyName: familyName!, userId: userId)

                } else {
                    
                    // Save user's firstname and lastname in local cache to display on profile page
                    SharedData.instance.userFirstName = givenName
                    SharedData.instance.userLastName = familyName
                    
                    // Transition to landing screen
                    self.transitionToLanding()
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        GIDSignIn.sharedInstance().signOut()
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            showError(signOutError.localizedDescription)
        }
    }
    
    func setupAppleButton() {
//      let appleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
        let appleButton = UIButton(frame: CGRect(x: 0,y: 0,width: 48,height: 48))
        let appleButtonImage = Utilities.resizeImage(image: UIImage(named: "apple_logo_custom.png")!, targetSize: CGSize(width: 48, height: 48.0))
        appleButton.setImage(appleButtonImage, for: .normal)
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
        
//        let landingViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.landingViewController) as? LandingViewController
        
//        view.window?.rootViewController = landingViewController
//        view.window?.makeKeyAndVisible()
        
        if let landingViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.landingViewController) as? LandingViewController {
          navigationController?.pushViewController(landingViewController, animated: true)
        }
        
    }
    
    // Display privacy policy when the app was launched for the first time
    func displayPrivacyPolicy(email: String, givenName: String, familyName: String, userId: String) {
        
        // Create alert
        let alert = UIAlertController(title: "License Agreement", message: "", preferredStyle: .alert)
        alert.setValue(Utilities.formattedLicenseAgreement(), forKey: "attributedMessage")
        
        // Create Agree button
        let agreeAction = UIAlertAction(title: "Agree", style: .default) { (action) -> Void in
            print("License agreement accepted")
            // first-time user and hence save user info to firestore
            let errMessage = Utilities.saveUserToFirestore(email: email, firstName: givenName, lastName: familyName, uid: userId)
            
            if errMessage != nil {
                // user doesn't need to know that there's an error while saving their data to DB
                // write it to the application log and monitor such errors
                print(errMessage!)
            }
            // Save user's firstname and lastname in local cache to display on profile page
            SharedData.instance.userFirstName = givenName
            SharedData.instance.userLastName = familyName
            
            // Transition to landing screen
            self.transitionToLanding()
        }
        
        // Add task to tableview buttons
        alert.addAction(agreeAction)
        
        self.present(alert, animated: true, completion: nil)
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
                        
                        // display privacy policy
                        self.displayPrivacyPolicy(email: email!, givenName: givenName!, familyName: familyName!, userId: userId)
                        
                    } else {
                        // Save user's firstname and lastname in local cache to display on profile page
                        SharedData.instance.userFirstName = givenName
                        SharedData.instance.userLastName = familyName
                        
                        // Transition to landing screen
                        self.transitionToLanding()
                    }
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
