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
        static let speechViewController = "SpeechVC"
        static let resetPasswordViewController = "ResetPasswordVC"
        static let signUpViewController = "SignUpVC"
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

    }
    
    struct Api {
        
        static let URL_BASE = "https://voice-translator-dot-teak-mantis-279104.uc.r.appspot.com"
//      static let URL_BASE = "http://localhost:8080"
        static let URL_UPLOAD = "/ios-upload"
        static let URL_VIEWSTATUS = "/ios-viewstatus"
        static let URL_CHECKSTATUS = "/ios-checkstatus"
        static let URL_DELETEFILE = "/ios-deletefile"
        
    }
    
    static let TTS_Host = "texttospeech.googleapis.com"
    // authtoken-service is the GCP project name for Token Service
    // Deployed firebase functions for token-service to GCP project teak-mantis-279104
    static let translateParent = "projects/teak-mantis-279104/locations/global"
    static let languageCode = "en-US"
    static let STT_Host = "speech.googleapis.com"
    static let TRANSLATE_Host = "translation.googleapis.com"
    
    static let languagePickerOptions:[(languageText: String, languageValue: String)] = [("Afrikaans (South Africa)", "af-ZA"), ("Albanian (Albania)", "sq-AL"), ("Amharic (Ethiopia)", "am-ET"), ("Arabic (Algeria)", "ar-DZ"), ("Arabic (Bahrain)", "ar-BH"), ("Arabic (Egypt)", "ar-EG"), ("Arabic (Iraq)", "ar-IQ"), ("Arabic (Israel)", "ar-IL"), ("Arabic (Jordan)", "ar-JO"), ("Arabic (Kuwait)", "ar-KW"), ("Arabic (Lebanon)", "ar-LB"), ("Arabic (Morocco)", "ar-MA"), ("Arabic (Oman)", "ar-OM"), ("Arabic (Qatar)", "ar-QA"), ("Arabic (Saudi Arabia)", "ar-SA"), ("Arabic (State of Palestine)", "ar-PS"), ("Arabic (Tunisia)", "ar-TN"), ("Arabic (United Arab Emirates)", "ar-AE"), ("Arabic (Yemen)", "ar-YE"), ("Armenian (Armenia)", "hy-AM"), ("Azerbaijani (Azerbaijan)", "az-AZ"), ("Basque (Spain)", "eu-ES"), ("Bengali (Bangladesh)", "bn-BD"), ("Bengali (India)", "bn-IN"), ("Bosnian (Bosnia and Herzegovina)", "bs-BA"), ("Bulgarian (Bulgaria)", "bg-BG"), ("Burmese (Myanmar)", "my-MM"), ("Catalan (Spain)", "ca-ES"), ("Chinese, Cantonese (Traditional Hong Kong)", "yue-Hant-HK"), ("Chinese, Mandarin (Simplified, China)", "zh (cmn-Hans-CN)"), ("Chinese, Mandarin (Traditional, Taiwan)", "zh-TW (cmn-Hant-TW)"), ("Croatian (Croatia)", "hr-HR"), ("Czech (Czech Republic)", "cs-CZ"), ("Danish (Denmark)", "da-DK"), ("Dutch (Belgium)", "nl-BE"), ("Dutch (Netherlands)", "nl-NL"), ("English (Australia)", "en-AU"), ("English (Canada)", "en-CA"), ("English (Ghana)", "en-GH"), ("English (Hong Kong)", "en-HK"), ("English (India)", "en-IN"), ("English (Ireland)", "en-IE"), ("English (Kenya)", "en-KE"), ("English (New Zealand)", "en-NZ"), ("English (Nigeria)", "en-NG"), ("English (Pakistan)", "en-PK"), ("English (Philippines)", "en-PH"), ("English (Singapore)", "en-SG"), ("English (South Africa)", "en-ZA"), ("English (Tanzania)", "en-TZ"), ("English (United Kingdom)", "en-GB"), ("English (United States)", "en-US"), ("Estonian (Estonia)", "et-EE"), ("Filipino (Philippines)", "fil-PH"), ("Finnish (Finland)", "fi-FI"), ("French (Belgium)", "fr-BE"), ("French (Canada)", "fr-CA"), ("French (France)", "fr-FR"), ("French (Switzerland)", "fr-CH"), ("Galician (Spain)", "gl-ES"), ("Georgian (Georgia)", "ka-GE"), ("German (Austria)", "de-AT"), ("German (Germany)", "de-DE"), ("German (Switzerland)", "de-CH"), ("Greek (Greece)", "el-GR"), ("Gujarati (India)", "gu-IN"), ("Hebrew (Israel)", "iw-IL"), ("Hindi (India)", "hi-IN"), ("Hungarian (Hungary)", "hu-HU"), ("Icelandic (Iceland)", "is-IS"), ("Indonesian (Indonesia)", "id-ID"), ("Italian (Italy)", "it-IT"), ("Italian (Switzerland)", "it-CH"), ("Japanese (Japan)", "ja-JP"), ("Javanese (Indonesia)", "jv-ID"), ("Kannada (India)", "kn-IN"), ("Khmer (Cambodia)", "km-KH"), ("Korean (South Korea)", "ko-KR"), ("Lao (Laos)", "lo-LA"), ("Latvian (Latvia)", "lv-LV"), ("Lithuanian (Lithuania)", "lt-LT"), ("Macedonian (North Macedonia)", "mk-MK"), ("Malay (Malaysia)", "ms-MY"), ("Malayalam (India)", "ml-IN"), ("Marathi (India)", "mr-IN"), ("Mongolian (Mongolia)", "mn-MN"), ("Nepali (Nepal)", "ne-NP"), ("Norwegian BokmÂl (Norway)", "no-NO"), ("Persian (Iran)", "fa-IR"), ("Polish (Poland)", "pl-PL"), ("Portuguese (Brazil)", "pt-BR"), ("Portuguese (Portugal)", "pt-PT"), ("Punjabi (Gurmukhi India)", "pa-Guru-IN"), ("Romanian (Romania)", "ro-RO"), ("Russian (Russia)", "ru-RU"), ("Serbian (Serbia)", "sr-RS"), ("Sinhala (Sri Lanka)", "si-LK"), ("Slovak (Slovakia)", "sk-SK"), ("Slovenian (Slovenia)", "sl-SI"), ("Spanish (Argentina)", "es-AR"), ("Spanish (Bolivia)", "es-BO"), ("Spanish (Chile)", "es-CL"), ("Spanish (Colombia)", "es-CO"), ("Spanish (Costa Rica)", "es-CR"), ("Spanish (Dominican Republic)", "es-DO"), ("Spanish (Ecuador)", "es-EC"), ("Spanish (El Salvador)", "es-SV"), ("Spanish (Guatemala)", "es-GT"), ("Spanish (Honduras)", "es-HN"), ("Spanish (Mexico)", "es-MX"), ("Spanish (Nicaragua)", "es-NI"), ("Spanish (Panama)", "es-PA"), ("Spanish (Paraguay)", "es-PY"), ("Spanish (Peru)", "es-PE"), ("Spanish (Puerto Rico)", "es-PR"), ("Spanish (Spain)", "es-ES"), ("Spanish (United States)", "es-US"), ("Spanish (Uruguay)", "es-UY"), ("Spanish (Venezuela)", "es-VE"), ("Sundanese (Indonesia)", "su-ID"), ("Swahili (Kenya)", "sw-KE"), ("Swahili (Tanzania)", "sw-TZ"), ("Swedish (Sweden)", "sv-SE"), ("Tamil (India)", "ta-IN"), ("Tamil (Malaysia)", "ta-MY"), ("Tamil (Singapore)", "ta-SG"), ("Tamil (Sri Lanka)", "ta-LK"), ("Telugu (India)", "te-IN"), ("Thai (Thailand)", "th-TH"), ("Turkish (Turkey)", "tr-TR"), ("Ukrainian (Ukraine)", "uk-UA"), ("Urdu (India)", "ur-IN"), ("Urdu (Pakistan)", "ur-PK"), ("Uzbek (Uzbekistan)", "uz-UZ"), ("Vietnamese (Vietnam)", "vi-VN"), ("Zulu (South Africa)", "zu-ZA")]
    
}

extension Constants {
  static let SettingsScreenTtitle = "Settings"
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
