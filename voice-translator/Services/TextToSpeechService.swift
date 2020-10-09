//
//  TextToSpeechRecognitionService.swift
//  voice-translator
//
//  Created by Hima Devisetti on 9/25/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import Foundation
import googleapis
import AVFoundation
import AuthLibrary
import Firebase
import FirebaseInstanceID

protocol VoiceListProtocol {
    func didReceiveVoiceList(voiceList: [FormattedVoice]?, errorString: String?)
}

class TextToSpeechRecognitionService {
    var client = TextToSpeech(host: Constants.TTS_Host)
    private var writer = GRXBufferedPipe()
    private var call : GRPCProtoCall!
    
    static let sharedInstance = TextToSpeechRecognitionService()
    var voiceListDelegate: VoiceListProtocol?
    
    func getDeviceID(callBack: @escaping (String)->Void) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
//              print("Error fetching remote instance ID: \(error)")
                Log(self).error("Error fetching remote instance ID: \(error)", includeCodeLocation: true)
                callBack( "")
            } else if let result = result {
                //      print("Remote instance ID token: \(result.token)")
                callBack( result.token)
            } else {
                callBack( "")
            }
        }
    }
    
    func textToSpeech(text:String, completionHandler: @escaping (_ audioData: Data?, _ error: String?) -> Void) {
        let authT = FCMTokenProvider.getTokenFromUserDefaults()
        let synthesisInput = SynthesisInput()
        synthesisInput.text = text
        
        let voiceSelectionParams = VoiceSelectionParams()
        voiceSelectionParams.languageCode = "en-US"
        //voiceSelectionParams.ssmlGender = SsmlVoiceGender.neutral
        
        if let userPreference = UserDefaults.standard.value(forKey: Constants.userLanguagePreferences) as? [String: String] {
            let selectedTransTo = userPreference[Constants.selectedTransTo] ?? ""
            let selectedSynthName = userPreference[Constants.selectedSynthName] ?? ""
            let selectedVoiceType = userPreference[Constants.selectedVoiceType] ?? ""
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let voiceList = appDelegate.voiceLists {
                let transTo = voiceList.filter {
                    return $0.languageName == selectedTransTo
                }
                if let transTo = transTo.first {
                    let transToLangCode =  transTo.languageCode
                    voiceSelectionParams.languageCode = transToLangCode
                    
                    if let synthNameIndex = transTo.synthesisName.firstIndex(of: selectedSynthName){
                        let synthNameCode = transTo.synthesisNameCode[synthNameIndex]
                        voiceSelectionParams.name = synthNameCode
                    }
                    if let synthGenderIndex = transTo.synthesisGender.firstIndex(of: selectedVoiceType){
                        let synthGenderCode = transTo.synthesisGenderCode[synthGenderIndex]
                        voiceSelectionParams.ssmlGender = synthGenderCode
                    }
                }
            }
        }
        
        let audioConfig = AudioConfig()
        audioConfig.audioEncoding = AudioEncoding.mp3
        
        let speechRequest = SynthesizeSpeechRequest()
        speechRequest.audioConfig = audioConfig
        speechRequest.input = synthesisInput
        speechRequest.voice = voiceSelectionParams
        
        self.call = self.client.rpcToSynthesizeSpeech(with: speechRequest, handler: { (synthesizeSpeechResponse, error) in
            if error != nil {
//              print(error?.localizedDescription ?? "No error description available")
                Log(self).error("\(String(describing: error?.localizedDescription)) ?? 'No error description available'", includeCodeLocation: true)
                completionHandler(nil, error?.localizedDescription)
                return
            }
            guard let response = synthesizeSpeechResponse else {
//              print("No response received")
                Log(self).error("No response received")
                return
            }
            //    print("Text to speech response\(response)")
            guard let audioData =  response.audioContent else {
//              print("no audio data received")
                Log(self).error("No audio data received")
                return
            }
            completionHandler(audioData, nil)
        })
        
        self.call.requestHeaders.setObject(NSString(string:authT), forKey:NSString(string:"Authorization"))
        // if the API key has a bundle ID restriction, specify the bundle ID like this
        self.call.requestHeaders.setObject(NSString(string:Bundle.main.bundleIdentifier!), forKey:NSString(string:"X-Ios-Bundle-Identifier"))
        //  print("HEADERS:\(String(describing: self.call.requestHeaders))")
        self.call.start()
    }
    
    @objc func getVoiceLists() {
        SpeechRecognitionService.sharedInstance.getDeviceID { (deviceID) in
            FCMTokenProvider.getToken(deviceID: deviceID, { (shouldWait, token, error) in
                if let authT = token, shouldWait == false {//Token received execute code
                    self.call = self.client.rpcToListVoices(with: ListVoicesRequest(), handler: { (listVoiceResponse, error) in
                        if let errorStr = error?.localizedDescription {
                            self.voiceListDelegate?.didReceiveVoiceList(voiceList: nil, errorString: errorStr)
                            //                        completionHandler(nil, errorStr)
                            return
                        }
                        //          print(listVoiceResponse ?? "No voice list found")
                        if let listVoiceResponse = listVoiceResponse {
                            let formattedVoice = FormattedVoice.formatVoiceResponse(listVoiceResponse: listVoiceResponse)
                            self.voiceListDelegate?.didReceiveVoiceList(voiceList: formattedVoice, errorString: nil)
                            //                        completionHandler(formattedVoice, nil)
                        }
                    })
                    self.call.requestHeaders.setObject(NSString(string:authT), forKey:NSString(string:"Authorization"))
                    // if the API key has a bundle ID restriction, specify the bundle ID like this
                    self.call.requestHeaders.setObject(NSString(string:Bundle.main.bundleIdentifier!), forKey:NSString(string:"X-Ios-Bundle-Identifier"))
                    //        print("HEADERS:\(String(describing: self.call.requestHeaders))")
                    self.call.start()
                } else if shouldWait == true {//Token will be sent via PN.
                    //Observe for notification
                    NotificationCenter.default.addObserver(self, selector: #selector(self.getVoiceLists), name: NSNotification.Name(Constants.tokenReceived), object: nil)
                } else {// an error occurred
                    //Handle error
                }
            })
        }
    }
}

struct FormattedVoice {
    var languageCode: String = ""
    var languageName: String = ""
    var synthesisName: [String] = []
    var synthesisGender: [String] = []
    var synthesisNameCode: [String] = []
    var synthesisGenderCode: [SsmlVoiceGender] = []
    
    static func formatVoiceResponse(listVoiceResponse: ListVoicesResponse) -> [FormattedVoice] {
        var result = [FormattedVoice]()
        for voice in listVoiceResponse.voicesArray {
            if let voice = voice as? Voice {
                for languageCode in voice.languageCodesArray {
                    let index = result.filter({$0.languageCode == ((languageCode as? String) ?? "")})
                    var resultVoice = index.count > 0 ? (index.first ?? FormattedVoice()) : FormattedVoice()
                    resultVoice.languageCode = (languageCode as? String) ?? ""
                    resultVoice.languageName = convertLanguageCodes(languageCode: resultVoice.languageCode)
                    
                    let name = getSynthesisName(name: voice.name)
                    if !resultVoice.synthesisName.contains(name) {
                        resultVoice.synthesisName.append(getSynthesisName(name: voice.name))
                        resultVoice.synthesisNameCode.append(voice.name)
                    }
                    
                    let gender = getGender(name: voice.name, gender: voice.ssmlGender)
                    if !resultVoice.synthesisGender.contains(gender) {
                        resultVoice.synthesisGender.append(gender)
                        resultVoice.synthesisGenderCode.append(voice.ssmlGender)
                    }
                    if index.count > 0 {
                        
                        result.removeAll(where: {$0.languageCode == ((languageCode as? String) ?? "")})
                    }
                    result.append(resultVoice)
                }
            }
        }
        result = result.sorted(by: {$0.languageName.uppercased() < $1.languageName.uppercased()})
        
        return result
    }
    
    static func convertLanguageCodes(languageCode: String) -> String {
        var languageName = ""
        switch (languageCode) {
        case "ar-XA":
            languageName = "Arabic"
        case "bn-IN":
            languageName = "Bengali"
        case "cmn-CN":
            languageName = "Mandarin Chinese CN"
        case "cmn-TW":
            languageName = "Mandarin Chinese TW"
        case "cs-CZ":
            languageName = "Czech Republic"
        case "da-DK":
            languageName = "Danish"
        case "de-DE":
            languageName = "German"
        case "el-GR":
            languageName = "Greek"
        case "en-AU":
            languageName = "English AU"
        case "en-GB":
            languageName = "English UK"
        case "en-IN":
            languageName = "English IN"
        case "en-US":
            languageName = "English US"
        case "es-ES":
            languageName = "Spanish"
        case "fi-FI":
            languageName = "Finnish"
        case "fil-PH":
            languageName = "Filipino"
        case "fr-CA":
            languageName = "French CA"
        case "fr-FR":
            languageName = "French"
        case "gu-IN":
            languageName = "Gujarati"
        case "hi-IN":
            languageName = "Hindi"
        case "hu-HU":
            languageName = "Hungarian"
        case "id-ID":
            languageName = "Indonesian"
        case "it-IT":
            languageName = "Italian"
        case "ja-JP":
            languageName = "Japanese"
        case "kn-IN":
            languageName = "Kannada"
        case "ko-KR":
            languageName = "Korean"
        case "ml-IN":
            languageName = "Malayalam"
        case "nl-NL":
            languageName = "Dutch"
        case "nb-NO":
            languageName = "Norwegian"
        case "pl-PL":
            languageName = "Polish"
        case "pt-BR":
            languageName = "Portugese BR"
        case "pt-PT":
            languageName = "Portugese"
        case "ru-RU":
            languageName = "Russian"
        case "sk-SK":
            languageName = "Slovak SK"
        case "sv-SE":
            languageName = "Swedish"
        case "ta-IN":
            languageName = "Tamil"
        case "te-IN":
            languageName = "Telugu"
        case "th-TH":
            languageName = "Thai"
        case "tr-TR":
            languageName = "Turkish"
        case "uk-UA":
            languageName = "Ukrainian UA"
        case "vi-VN":
            languageName = "Vietnamese"
        case "yue-HK":
            languageName = "Chinese HK"
        default:
            languageName = languageCode
        }
        return "\(languageName) (\(languageCode))"
    }
    
    static func getSynthesisName(name: String) -> String {
        let components = name.components(separatedBy: "-")
        if components.count > 2 {
            return components[2]
        }
        return ""
    }
    
    static func getGender(name: String, gender: SsmlVoiceGender) -> String {
        let components = name.components(separatedBy: "-")
        if components.count > 3 {
            return gender.getGenderString() + " " + components[3]
        }
        return gender.getGenderString()
    }
}

extension SsmlVoiceGender {
    func getGenderString() -> String {
        switch self {
        case .gpbUnrecognizedEnumeratorValue:
            return "Unspecified"
        case .ssmlVoiceGenderUnspecified:
            return "Unspecified"
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .neutral:
            return "Neutral"
        default:
            return "Unknown"
        }
    }
}
