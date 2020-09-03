//
//  AppDelegate.swift
//  voice-translator
//
//  Created by user178116 on 8/17/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var hasAlreadyLaunched :Bool!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        // Initialize Google sign-in
        GIDSignIn.sharedInstance().clientID = "753356494760-ciujpg9t8bs3c37hokaclf2fa0evk2r9.apps.googleusercontent.com"
        
        // If the user is already logged into firebase
        if let user = Auth.auth().currentUser {
            print("You're signed in as \(user.uid), email: \(String(describing: user.email))")
        }
        
        //retrieve value from local store, if value doesn't exist then false is returned
        hasAlreadyLaunched = UserDefaults.standard.bool(forKey: "hasAlreadyLaunched")
        
        //check app first-time launched
        if (hasAlreadyLaunched) {
            hasAlreadyLaunched = true
        } else {
            UserDefaults.standard.set(true, forKey: "hasAlreadyLaunched")
        }
        
        return true
    }
    
    func sethasAlreadyLaunched() {
        hasAlreadyLaunched = true
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

