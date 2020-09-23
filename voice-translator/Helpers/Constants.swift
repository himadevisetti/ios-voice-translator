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
        static let speechViewController = "SpeechVC"
        static let resetPasswordViewController = "ResetPasswordVC"
        static let signUpViewController = "SignUpVC"
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
    
    static let licenseAgreement = """

                                  Privacy Policy

                                  The Voice Translate app was built as a Free app. This service is provided at no cost and is intended for use as is. This page is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decided to use this Service. If you choose to use this Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that we collect is used for providing and improving the Service. We will not use or share your information with anyone except as described in this Privacy Policy. The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at Terms unless otherwise defined in this Privacy Policy.

                                  Information Collection and Use

                                  For a better experience, while using our Service, we may require you to provide us with certain personally identifiable information, including but not limited to email, first name, last name. The information that we request will be stored in our database and used only for authentication purposes.

                                  Log Data

                                  We want to inform you that whenever you use our Service, in case of an error in the app we collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics.

                                  Media

                                  Media uploaded by you for translation goes to secure storage and will be deleted right away after translation is complete. You have an option to delete translated media in the app. If not, it will be remain available to you from a secure storage for 24 hours and will be deleted after that.

                                  Cookies

                                  No cookies are collected or used in the mobile app at this time. This Service uses cookies only for the website version of the app to provide Cross Site Request Forgery (CSRF) protection.

                                  Service Providers

                                  We may employ third-party companies and individuals due to the following reasons:

                                  To facilitate our Service;
                                  To provide the Service on our behalf;
                                  To perform Service-related tasks; or
                                  To assist us in analyzing how our Service is used.
                                  
                                  We want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.

                                  Security

                                  We value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security.

                                  Links to Other Sites

                                  This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.

                                  Children’s Privacy

                                  These Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that we will be able to perform necessary actions.

                                  Changes to This Privacy Policy

                                  We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page.

                                  This policy is effective as of 2020-09-09.

                                  Terms & Conditions

                                  By downloading or using the app, these terms will automatically apply to you – you should make sure therefore that you read them carefully before using the app. You’re not allowed to copy, or modify the app, any part of the app, or our trademarks in any way. You’re not allowed to attempt to extract the source code of the app, and you also shouldn’t try to translate the app into other languages, or make derivative versions. The app itself, and all the trade marks, copyright, database rights and other intellectual property rights related to it, still belong to Voice Translate team.

                                  Voice Translate team is committed to ensuring that the app is as useful and efficient as possible. For that reason, we reserve the right to make changes to the app or to charge for its services, at any time and for any reason. We will never charge you for the app or its services without making it very clear to you exactly what you’re paying for.

                                  The Voice Translate app stores and processes personal data that you have provided to us, in order to provide our Service. It’s your responsibility to keep your phone and access to the app secure. We therefore recommend that you do not jailbreak or root your phone, which is the process of removing software restrictions and limitations imposed by the official operating system of your device. It could make your phone vulnerable to malware/viruses/malicious programs, compromise your phone’s security features and it could mean that the Voice Translate app won’t work properly or at all.

                                  You should be aware that there are certain things that Voice Translate team will not take responsibility for. Certain functions of the app will require the app to have an active internet connection. The connection can be Wi-Fi, or provided by your mobile network provider, but Voice Translate team cannot take responsibility for the app not working at full functionality if you don’t have access to Wi-Fi, and you don’t have any of your data allowance left.

                                  If you’re using the app outside of an area with Wi-Fi, you should remember that your terms of the agreement with your mobile network provider will still apply. As a result, you may be charged by your mobile provider for the cost of data for the duration of the connection while accessing the app, or other third party charges. In using the app, you’re accepting responsibility for any such charges, including roaming data charges if you use the app outside of your home territory (i.e. region or country) without turning off data roaming. If you are not the bill payer for the device on which you’re using the app, please be aware that we assume that you have received permission from the bill payer for using the app.

                                  Along the same lines, Voice Translate team cannot always take responsibility for the way you use the app i.e. You need to make sure that your device stays charged – if it runs out of battery and you can’t turn it on to avail the Service, Voice Translate team cannot accept responsibility.

                                  With respect to Voice Translate team’s responsibility for your use of the app, when you’re using the app, it’s important to bear in mind that although we endeavour to ensure that it is updated and correct at all times, we do rely on third parties to provide information to us so that we can make it available to you. Voice Translate team accepts no liability for any loss, direct or indirect, you experience as a result of relying wholly on this functionality of the app.

                                  At some point, we may wish to update the app. The app is currently available on iOS – the requirements for system (and for any additional systems we decide to extend the availability of the app to) may change, and you’ll need to download the updates if you want to keep using the app. Voice Translate team does not promise that it will always update the app so that it is relevant to you and/or works with the iOS version that you have installed on your device. However, you promise to always accept updates to the application when offered to you, We may also wish to stop providing the app, and may terminate use of it at any time without giving notice of termination to you. Unless we tell you otherwise, upon any termination, (a) the rights and licenses granted to you in these terms will end; (b) you must stop using the app, and (if needed) delete it from your device.

                                  Changes to This Terms and Conditions

                                  We may update our Terms and Conditions from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Terms and Conditions on this page.

                                  These terms and conditions are effective as of 2020-09-09.

                                  Contact Us

                                  If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at voice_translator@yahoo.com.

                                  """
    
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
