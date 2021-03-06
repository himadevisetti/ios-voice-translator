//
//  AppDelegate.extension.swift
//  voice-translator
//
//  Created by Hima Devisetti on 10/3/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import AuthLibrary
import FirebaseMessaging
import FirebaseDynamicLinks
import FirebaseAuth

extension AppDelegate {
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        //      if let messageID = userInfo[gcmMessageIDKey] {
        //          print("Message ID: \(messageID)")
        //      }
        if let aps = userInfo["aps"] as? [String: Any], let alert = aps["alert"] as? [String: Any], let token = alert["body"] as? String , let expiryTime = alert["title"] as? String {
            let tokenData = [Constants.accessToken: token, Constants.expireTime: expiryTime]
            FCMTokenProvider.tokenFromAppDelegate(tokenDict: tokenData)
            NotificationCenter.default.post(name: NSNotification.Name(Constants.tokenReceived), object: tokenData)
        }
        // Print full message.
        //  print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        //      if let messageID = userInfo[gcmMessageIDKey] {
        //          print("Message ID: \(messageID)")
        //      }
        guard let tokenData = userInfo as? [String: Any] else {return}
        
        NotificationCenter.default.post(name: NSNotification.Name(Constants.tokenReceived), object: tokenData)
        // Print full message.
        //  print(userInfo)
        
        // Clear remote push notifications
        clearNotifications()
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
    
    func clearNotifications() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        let notifications =  UNUserNotificationCenter.current()
        notifications.removeAllPendingNotificationRequests()
        notifications.removeAllDeliveredNotifications()
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if let incomingURL = userActivity.webpageURL {
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                guard error == nil else {
//                  print("Found an error: \(error!.localizedDescription)")
                    Log(self).error("Found an error: \(error!.localizedDescription)", includeCodeLocation: true)
                    return
                }
                if let dynamicLink = dynamicLink {
                    _ = self.handleIncomingDynamicLink(dynamicLink)
                }
            }
//          print("Link Handled: \(linkHandled)")
            if linkHandled {
                return true
            } else {
                // Do other things with the incoming URL
                return false
            }
        }
        return false
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
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.hasAlreadyLaunched = false
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
        //      if let messageID = userInfo[gcmMessageIDKey], let aps = userInfo["aps"] as? [String: Any], let alert
        if let aps = userInfo["aps"] as? [String: Any], let alert = aps["alert"] as? [String: Any], let token = alert["body"] as? String , let expiryTime = alert["title"] as? String {
            //          print("Message ID: \(messageID)")
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
        //      if let messageID = userInfo[gcmMessageIDKey], let aps = userInfo["aps"] as? [String: Any], let alert
        if let aps = userInfo["aps"] as? [String: Any], let alert = aps["alert"] as? [String: Any], let token = alert["body"] as? String , let expiryTime = alert["title"] as? String {
            //          print("Message ID: \(messageID)")
            let tokenData = [Constants.accessToken: token, Constants.expireTime: expiryTime]
            NotificationCenter.default.post(name: NSNotification.Name(Constants.tokenReceived), object: tokenData)
        }
        // Print full message.
        //  print(userInfo)
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
