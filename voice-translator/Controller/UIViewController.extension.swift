//
//  UIViewController.extension.swift
//  voice-translator
//
//  Created by Hima Devisetti on 10/2/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import UserNotifications

extension UIViewController {
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            //print("User Notification settings: (settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func requestNotificationAuthorization() {
        // Request for permissions
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                //print("Notification granted: (granted)")
                guard granted else { return }
                self?.getNotificationSettings()
            }
    }
    
}
