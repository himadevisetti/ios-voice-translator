//
//  TranslationService.swift
//  voice-translator
//
//  Created by Hima Devisetti on 9/25/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import Foundation
import googleapis
import AuthLibrary

enum ServiceError: Error {
    case unknownError
    case invalidCredentials
    case tokenNotAvailable
    
}

let TRANSLATE_HOST = "translation.googleapis.com"

typealias TranslationCompletionHandler = (TranslateTextResponse?, NSError?) -> (Void)

class TranslationServices {
    static let sharedInstance = TranslationServices()
    private var client = TranslationService(host: TRANSLATE_HOST)
    private var call : GRPCProtoCall!
    func translateText(text: String, completionHandler: @escaping (TranslateTextResponse?, String?)->Void) {
        let authT = FCMTokenProvider.getTokenFromUserDefaults()
        let translateRequest = TranslateTextRequest()
        if let userPreference = UserDefaults.standard.value(forKey: Constants.userLanguagePreferences) as? [String: String] {
            let selectedTransFrom = userPreference[Constants.selectedTransFrom] ?? ""
            let selectedTransTo = userPreference[Constants.selectedTransTo] ?? ""
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let voiceList = appDelegate.voiceLists {
                let transTo = voiceList.filter {
                    return $0.languageName == selectedTransTo
                }
                if let transTo = transTo.first {
                    let transToLangCode =  transTo.languageCode
                    translateRequest.targetLanguageCode = transToLangCode
                }
                
                let transFrom = voiceList.filter {
                    return $0.languageName == selectedTransFrom
                }
                if let transFrom = transFrom.first {
                    let transFromLangCode =  transFrom.languageCode
                    translateRequest.sourceLanguageCode = transFromLangCode
                }
            }
        }
        
        translateRequest.contentsArray = [text]
        translateRequest.mimeType = "text/plain"
        translateRequest.parent = Constants.translateParent
        self.call = self.client.rpcToTranslateText(with: translateRequest, handler: { (translateResponse, error) in
            if error != nil {
                print(error?.localizedDescription ?? "No eror description found")
                completionHandler(nil, error?.localizedDescription)
                return
            }
            //      print(translateResponse ?? "Response found nil")
            guard let res = translateResponse else {return}
            completionHandler(res, nil)
        })
        self.call.requestHeaders.setObject(NSString(string:authT), forKey:NSString(string:"Authorization"))
        // if the API key has a bundle ID restriction, specify the bundle ID like this
        self.call.requestHeaders.setObject(NSString(string:Bundle.main.bundleIdentifier!), forKey:NSString(string:"X-Ios-Bundle-Identifier"))
        self.call.start()
    }
}
