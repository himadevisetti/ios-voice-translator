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
import UserNotifications
import AuthLibrary
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var hasAlreadyLaunched :Bool!
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var voiceLists: [FormattedVoice]?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        if voiceLists == nil || (voiceLists?.isEmpty ?? true) {
            TextToSpeechRecognitionService.sharedInstance.voiceListDelegate = self
            TextToSpeechRecognitionService.sharedInstance.getVoiceLists ()
        }
        
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
        
        // Clear remote push notifications
        clearNotifications()
        
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
    
    func fetchToken() {
        SpeechRecognitionService.sharedInstance.getDeviceID { (deviceID) in
            // authenticate using an authorization token (obtained using OAuth)
            FCMTokenProvider.getToken(deviceID: deviceID) { (shouldWait, token, error) in
                //          print("shouldWait: \(shouldWait), token: \(String(describing: token)), error: \(error?.localizedDescription ?? "")")
                if error != nil {
                    print("error: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
    
    func fetchVoiceList() {
        if voiceLists == nil || (voiceLists?.isEmpty ?? true) {
            TextToSpeechRecognitionService.sharedInstance.voiceListDelegate = self
            TextToSpeechRecognitionService.sharedInstance.getVoiceLists ()
        }
    }
    
}
