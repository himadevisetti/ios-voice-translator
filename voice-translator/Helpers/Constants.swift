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
        static let profileViewController = "ProfileVC"
        static let translateViewController = "TranslateVC"
        static let messageViewController = "MessageVC"
        static let statusViewController = "StatusVC"
        static let recordViewController = "RecordVC"
        static let settingsViewController = "SettingsVC"
        static let languageOptionsTableViewController = "LanguageOptionsVC"
        static let translateLanguageOptionsTableViewController = "TranslateLanguageOptionsVC"
        static let speechViewController = "SpeechVC"
        static let resetPasswordViewController = "ResetPasswordVC"
        static let signUpViewController = "SignUpVC"
        static let confirmPasswordViewController = "ConfirmPasswordVC"
        static let agreementsViewController = "AgreementsVC"
        static let signUpScreenTitle = "Sign up"
        static let homeScreenTitle = "Home"
        static let profileScreenTitle = "Profile"
        static let recordScreenTitle = "Record Audio"
        static let translateScreenTitle = "Translate Audio File"
        static let messageScreenTitle = "Status"
        static let settingsScreenTitle = "Speech Settings"
        static let speechScreenTitle = "Speech"
        static let statusScreenTitle = "Status"
        static let resetPasswordScreenTitle = "Reset your password"
        static let optionsScreenTitle = "Choose an option"
        static let privacyPolicyScreenTitle = "Privacy Policy"
        static let termsScreenTitle = "Terms and Conditions"
        static let confirmPasswordScreenTitle = "Confirm your password"

    }
    
    struct Api {
        
        static let URL_BASE = "https://voice-translator-dot-teak-mantis-279104.uc.r.appspot.com"
//      static let URL_BASE = "http://localhost:8080"
        static let URL_UPLOAD = "/ios-upload"
        static let URL_VIEWSTATUS = "/ios-viewstatus"
        static let URL_CHECKSTATUS = "/ios-checkstatus"
        static let URL_DELETEFILE = "/ios-deletefile"
        
    }
    
    struct Setup {
        
        static let kFirebaseOpenAppScheme = "FirebaseOpenAppScheme"
        static let kFirebaseOpenAppURIPrefix = "FirebaseOpenAppURIPrefix"
        static let kFirebaseOpenAppQueryItemEmailName = "FirebaseOpenAppQueryItemEmailName"
        static let kEmail = "Email"
        static let kFirstName = "FirstName"
        static let kLastName = "LastName"
        static let kUid = "uid"
//      static var shouldOpenMailApp = false
        
    }
    
    static let TTS_Host = "texttospeech.googleapis.com"
    // authtoken-service is the GCP project name for Token Service
    // Deployed firebase functions for token-service to GCP project teak-mantis-279104
    static let translateParent = "projects/teak-mantis-279104/locations/global"
    static let languageCode = "en-US"
    static let STT_Host = "speech.googleapis.com"
    static let TRANSLATE_Host = "translation.googleapis.com"
    
}

extension Constants {
  static let selfKey = "Self"
  static let botKey = "Bot"
  static let selectedTransFrom = "selectedTransFrom"
  static let selectedTransTo = "selectedTransTo"
  static let selectedVoiceType = "selectedVoiceType"
  static let selectedSynthName = "selectedSynthName"
  static let userLanguagePreferences = "userLanguagePreferences"
  static let translateFromPlaceholder = "Translate from"
  static let translateToPlaceholder = "Translate to"
  static let synthNamePlaceholder = "TTS Tech"
  static let voiceTypePlaceholder = "Voice type"

}

//MARK: Token service constants
extension Constants {
  static let token = "Token"
  static let accessToken = "accessToken"
  static let expireTime = "expireTime"
  static let tokenReceived = "tokenReceived"
  static let retreivingToken = "RetrievingToken"
  static let getTokenAPI = "getOAuthToken"
  static let tokenType = "Bearer "
  static let noTokenError = "No token is available"
  static let tokenFetchingAlertTitle = "Alert"
  static let tokenFetchingAlertMessage = "Retrieving token ..."
}
