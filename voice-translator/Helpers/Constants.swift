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
        static let recordViewController = "RecordVC"
        static let resetPasswordViewController = "ResetPasswordVC"
        static let messageVCSegue = "MessageVCSegue"
        static let statusVCSegue = "StatusVCSegue"
        
        static let URL_BASE = "https://voice-translator-dot-teak-mantis-279104.uc.r.appspot.com"
//      static let URL_BASE = "http://localhost:8080"
        static let URL_UPLOAD = "/ios-upload"
        static let URL_VIEWSTATUS = "/ios-viewstatus"
        static let URL_CHECKSTATUS = "/ios-checkstatus"
        static let URL_DELETEFILE = "/ios-deletefile"
        
        static let languagePickerOptions:[(languageText: String, languageValue: String)] = [("Afrikaans (South Africa)", "af-ZA"), ("Albanian (Albania)", "sq-AL"), ("Amharic (Ethiopia)", "am-ET"), ("Arabic (Algeria)", "ar-DZ"), ("Arabic (Bahrain)", "ar-BH"), ("Arabic (Egypt)", "ar-EG"), ("Arabic (Iraq)", "ar-IQ"), ("Arabic (Israel)", "ar-IL"), ("Arabic (Jordan)", "ar-JO"), ("Arabic (Kuwait)", "ar-KW"), ("Arabic (Lebanon)", "ar-LB"), ("Arabic (Morocco)", "ar-MA"), ("Arabic (Oman)", "ar-OM"), ("Arabic (Qatar)", "ar-QA"), ("Arabic (Saudi Arabia)", "ar-SA"), ("Arabic (State of Palestine)", "ar-PS"), ("Arabic (Tunisia)", "ar-TN"), ("Arabic (United Arab Emirates)", "ar-AE"), ("Arabic (Yemen)", "ar-YE"), ("Armenian (Armenia)", "hy-AM"), ("Azerbaijani (Azerbaijan)", "az-AZ"), ("Basque (Spain)", "eu-ES"), ("Bengali (Bangladesh)", "bn-BD"), ("Bengali (India)", "bn-IN"), ("Bosnian (Bosnia and Herzegovina)", "bs-BA"), ("Bulgarian (Bulgaria)", "bg-BG"), ("Burmese (Myanmar)", "my-MM"), ("Catalan (Spain)", "ca-ES"), ("Chinese, Cantonese (Traditional Hong Kong)", "yue-Hant-HK"), ("Chinese, Mandarin (Simplified, China)", "zh (cmn-Hans-CN)"), ("Chinese, Mandarin (Traditional, Taiwan)", "zh-TW (cmn-Hant-TW)"), ("Croatian (Croatia)", "hr-HR"), ("Czech (Czech Republic)", "cs-CZ"), ("Danish (Denmark)", "da-DK"), ("Dutch (Belgium)", "nl-BE"), ("Dutch (Netherlands)", "nl-NL"), ("English (Australia)", "en-AU"), ("English (Canada)", "en-CA"), ("English (Ghana)", "en-GH"), ("English (Hong Kong)", "en-HK"), ("English (India)", "en-IN"), ("English (Ireland)", "en-IE"), ("English (Kenya)", "en-KE"), ("English (New Zealand)", "en-NZ"), ("English (Nigeria)", "en-NG"), ("English (Pakistan)", "en-PK"), ("English (Philippines)", "en-PH"), ("English (Singapore)", "en-SG"), ("English (South Africa)", "en-ZA"), ("English (Tanzania)", "en-TZ"), ("English (United Kingdom)", "en-GB"), ("English (United States)", "en-US"), ("Estonian (Estonia)", "et-EE"), ("Filipino (Philippines)", "fil-PH"), ("Finnish (Finland)", "fi-FI"), ("French (Belgium)", "fr-BE"), ("French (Canada)", "fr-CA"), ("French (France)", "fr-FR"), ("French (Switzerland)", "fr-CH"), ("Galician (Spain)", "gl-ES"), ("Georgian (Georgia)", "ka-GE"), ("German (Austria)", "de-AT"), ("German (Germany)", "de-DE"), ("German (Switzerland)", "de-CH"), ("Greek (Greece)", "el-GR"), ("Gujarati (India)", "gu-IN"), ("Hebrew (Israel)", "iw-IL"), ("Hindi (India)", "hi-IN"), ("Hungarian (Hungary)", "hu-HU"), ("Icelandic (Iceland)", "is-IS"), ("Indonesian (Indonesia)", "id-ID"), ("Italian (Italy)", "it-IT"), ("Italian (Switzerland)", "it-CH"), ("Japanese (Japan)", "ja-JP"), ("Javanese (Indonesia)", "jv-ID"), ("Kannada (India)", "kn-IN"), ("Khmer (Cambodia)", "km-KH"), ("Korean (South Korea)", "ko-KR"), ("Lao (Laos)", "lo-LA"), ("Latvian (Latvia)", "lv-LV"), ("Lithuanian (Lithuania)", "lt-LT"), ("Macedonian (North Macedonia)", "mk-MK"), ("Malay (Malaysia)", "ms-MY"), ("Malayalam (India)", "ml-IN"), ("Marathi (India)", "mr-IN"), ("Mongolian (Mongolia)", "mn-MN"), ("Nepali (Nepal)", "ne-NP"), ("Norwegian BokmÂl (Norway)", "no-NO"), ("Persian (Iran)", "fa-IR"), ("Polish (Poland)", "pl-PL"), ("Portuguese (Brazil)", "pt-BR"), ("Portuguese (Portugal)", "pt-PT"), ("Punjabi (Gurmukhi India)", "pa-Guru-IN"), ("Romanian (Romania)", "ro-RO"), ("Russian (Russia)", "ru-RU"), ("Serbian (Serbia)", "sr-RS"), ("Sinhala (Sri Lanka)", "si-LK"), ("Slovak (Slovakia)", "sk-SK"), ("Slovenian (Slovenia)", "sl-SI"), ("Spanish (Argentina)", "es-AR"), ("Spanish (Bolivia)", "es-BO"), ("Spanish (Chile)", "es-CL"), ("Spanish (Colombia)", "es-CO"), ("Spanish (Costa Rica)", "es-CR"), ("Spanish (Dominican Republic)", "es-DO"), ("Spanish (Ecuador)", "es-EC"), ("Spanish (El Salvador)", "es-SV"), ("Spanish (Guatemala)", "es-GT"), ("Spanish (Honduras)", "es-HN"), ("Spanish (Mexico)", "es-MX"), ("Spanish (Nicaragua)", "es-NI"), ("Spanish (Panama)", "es-PA"), ("Spanish (Paraguay)", "es-PY"), ("Spanish (Peru)", "es-PE"), ("Spanish (Puerto Rico)", "es-PR"), ("Spanish (Spain)", "es-ES"), ("Spanish (United States)", "es-US"), ("Spanish (Uruguay)", "es-UY"), ("Spanish (Venezuela)", "es-VE"), ("Sundanese (Indonesia)", "su-ID"), ("Swahili (Kenya)", "sw-KE"), ("Swahili (Tanzania)", "sw-TZ"), ("Swedish (Sweden)", "sv-SE"), ("Tamil (India)", "ta-IN"), ("Tamil (Malaysia)", "ta-MY"), ("Tamil (Singapore)", "ta-SG"), ("Tamil (Sri Lanka)", "ta-LK"), ("Telugu (India)", "te-IN"), ("Thai (Thailand)", "th-TH"), ("Turkish (Turkey)", "tr-TR"), ("Ukrainian (Ukraine)", "uk-UA"), ("Urdu (India)", "ur-IN"), ("Urdu (Pakistan)", "ur-PK"), ("Uzbek (Uzbekistan)", "uz-UZ"), ("Vietnamese (Vietnam)", "vi-VN"), ("Zulu (South Africa)", "zu-ZA")]
        
    }
    
}
