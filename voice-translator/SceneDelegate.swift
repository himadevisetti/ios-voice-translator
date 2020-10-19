//
//  SceneDelegate.swift
//  voice-translator
//
//  Created by user178116 on 8/17/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import FirebaseDynamicLinks
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        self.scene(scene, openURLContexts: connectionOptions.urlContexts)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        if let incomingURL = URLContexts.first?.url {
            _ = fetchIncomingURL(url: incomingURL)
        }
        
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        if let incomingURL = userActivity.webpageURL {
            _ = fetchIncomingURL(url: incomingURL)
        }
    }
    
    func fetchIncomingURL(url: URL) -> Bool {
        
        let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamicLink, error) in
            guard error == nil else {
//              print("Found an error: \(error!.localizedDescription)")
                Log(self).error("Found an error: \(error!.localizedDescription)", includeCodeLocation: true)
                return
            }
            if let dynamicLink = dynamicLink {
                _ = self.handleIncomingDynamicLink(dynamicLink)
            }
        }
        
        if linkHandled {
            return true
        } else {
            // Do other things with the incoming URL
            return false
        }
    }
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) -> Bool {
        
        guard let url = dynamicLink.url else {
//          print("Dynamic link object has no URL")
            Log(self).error("Dynamic link object has no URL", includeCodeLocation: true)
            return false
        }
        
//      let dynamicLinkURL = url.absoluteString
//      print("Dynamic link is: \(dynamicLinkURL)")
        
        let mode = url.queryParameters["mode"]
        let oobCode = url.queryParameters["oobCode"]
//      let continueUrl = url.queryParameters["continueUrl"]
//      let language = url.queryParameters["lang"]
        
        let email = UserDefaults.standard.value(forKey: Constants.Setup.kEmail)
        
        switch mode {
        case "verifyEmail":
            let rootViewController = self.window?.rootViewController as! UINavigationController
            Auth.auth().applyActionCode(oobCode!) { (err) in
                if let err = err {
                    let error = err as NSError
                    // There's an error while validating the action code for email verification
                    switch error.code {
                    case AuthErrorCode.expiredActionCode.rawValue:
                        Log("verifyEmail").error("Code expired. Click 'Sign up' and get the verify email link sent again")
                    case AuthErrorCode.invalidActionCode.rawValue:
                        Log("verifyEmail").error("Invalid code. Code is expired or has already been used")
                    default:
                        Log("verifyEmail").error("Unknown error: \(error.localizedDescription)")
                    }
                } else {
                    // Email has been verified. Prompt user to login
                    let alert = UIAlertController(title: "Account verified", message: "Your account has been verified. Please sign in", preferredStyle: .alert)
                    // Create agree button
                    let agreeAction = UIAlertAction(title: "Ok", style: .default) { (action) -> Void in
                        Log("verifyEmail").info("Account has been verified")
                        // Sign out the user (disable auto-login) as this is their first-time and they need to login manually using username and password
                        let firebaseAuth = Auth.auth()
                        do {
                          try firebaseAuth.signOut()
                        } catch let signOutError as NSError {
                            // Send this to logs
                            Log("verifyEmail").info("Error while signing out the user from firebase: \(signOutError.localizedDescription)")
                        }
                        if let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.loginViewController) as? LoginViewController {
                            loginViewController.verifyEmailFlow = true
                            rootViewController.pushViewController(loginViewController, animated: true)
                        }
                    }
                    
                    // Add agree button to the alert
                    alert.addAction(agreeAction)
                    rootViewController.present(alert, animated: true, completion: nil)
                }
            }
        case "resetPassword":
            if let rootViewController = self.window?.rootViewController as? UINavigationController {
                if let confirmPasswordViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.confirmPasswordViewController) as? ConfirmPasswordViewController {
                    confirmPasswordViewController.email = email as? String
                    confirmPasswordViewController.actionCode = oobCode
                    rootViewController.pushViewController(confirmPasswordViewController, animated: true)
                }
            }
        default:
            break
        }
        
        return false
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

