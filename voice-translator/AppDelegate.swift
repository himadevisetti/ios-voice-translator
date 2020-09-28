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
        
        Messaging.messaging().delegate = self
        
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
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        if let aps = userInfo["aps"] as? [String: Any], let alert = aps["alert"] as? [String: Any], let token = alert["body"] as? String , let expiryTime = alert["title"] as? String {
            let tokenData = [Constants.accessToken: token, Constants.expireTime: expiryTime]
            FCMTokenProvider.tokenFromAppDelegate(tokenDict: tokenData)
            NotificationCenter.default.post(name: NSNotification.Name(Constants.tokenReceived), object: tokenData)
        }
        // Print full message.
        //    print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        guard let tokenData = userInfo as? [String: Any] else {return}
        
        NotificationCenter.default.post(name: NSNotification.Name(Constants.tokenReceived), object: tokenData)
        // Print full message.
        print(userInfo)
    }
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//      print("APNs token retrieved: \(deviceToken)")
        //Call firebase function to store device token in the data base.
        // With swizzling disabled you must set the APNs token here.
//      let deviceTokenString = deviceToken.base64EncodedString()
        Messaging.messaging().apnsToken = deviceToken
        fetchToken()
        //fetchVoiceList()
    }
    
    func fetchVoiceList() {
        if voiceLists == nil || (voiceLists?.isEmpty ?? true) {
            TextToSpeechRecognitionService.sharedInstance.voiceListDelegate = self
            TextToSpeechRecognitionService.sharedInstance.getVoiceLists ()
        }
    }
    
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey], let aps = userInfo["aps"] as? [String: Any], let alert = aps["alert"] as? [String: Any], let token = alert["body"] as? String , let expiryTime = alert["title"] as? String {
            print("Message ID: \(messageID)")
            let tokenData = [Constants.accessToken: token, Constants.expireTime: expiryTime]
            //UserDefaults.standard.set(tokenData, forKey: ApplicationConstants.token)
            FCMTokenProvider.tokenFromAppDelegate(tokenDict: tokenData)
            NotificationCenter.default.post(name: NSNotification.Name(Constants.tokenReceived), object: tokenData)
        }
        // Print full message.
        //  print(userInfo)
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey], let aps = userInfo["aps"] as? [String: Any], let alert = aps["alert"] as? [String: Any], let token = alert["body"] as? String , let expiryTime = alert["title"] as? String {
            print("Message ID: \(messageID)")
            let tokenData = [Constants.accessToken: token, Constants.expireTime: expiryTime]
            NotificationCenter.default.post(name: NSNotification.Name(Constants.tokenReceived), object: tokenData)
        }
        // Print full message.
        print(userInfo)
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//      print("Firebase registration token: \(fcmToken)")
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
}

extension AppDelegate: VoiceListProtocol {
    func didReceiveVoiceList(voiceList: [FormattedVoice]?, errorString: String?) {
        if let errorString = errorString {
            let alertVC = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default))
            self.window?.rootViewController?.present(alertVC, animated: true)
        }
        self.voiceLists = voiceList
        NotificationCenter.default.post(name: Notification.Name("FetchVoiceList"), object: nil)
        
    }
    
}
