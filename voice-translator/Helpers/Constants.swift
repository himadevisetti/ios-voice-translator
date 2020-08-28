//
//  Constants.swift
//  voice-translator
//
//  Created by user178116 on 8/18/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Storyboard {
        
        static let loginViewController = "LoginVC"
        static let landingViewController = "LandingVC"
        static let statusViewController = "StatusVC"
        static let resetPasswordViewController = "ResetPasswordVC"
        static let messageVCSegue = "MessageVCSegue"
        static let statusVCSegue = "StatusVCSegue"
        
        // static let URL_BASE = "https://voice-translator-dot-teak-mantis-279104.uc.r.appspot.com"
        static let URL_BASE = "http://localhost:8080"
        // static let URL_BASE = "http://192.168.56.1:8080"
        static let URL_UPLOAD = "/ios-upload"
        static let URL_VIEWSTATUS = "/ios-viewstatus"
        static let URL_CHECKSTATUS = "/ios-checkstatus"
        
    }
    
}
