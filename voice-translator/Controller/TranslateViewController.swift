//
//  TranslateViewController.swift
//  voice-translator
//
//  Created by user178116 on 8/20/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import Alamofire

class TranslateViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var fromLanguagePicker: UITextField!
    @IBOutlet weak var toLanguagePicker: UITextField!
    @IBOutlet weak var chooseFileButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    
    var currentTextField = UITextField()
    var pickerView = UIPickerView()
    
   // var languagePickerOptions:[String] = []
    var fromLanguagePickerOptions:[(languageText: String, languageValue: String)] = []
    var toLanguagePickerOptions:[(languageText: String, languageValue: String)] = []
    
    var fromLanguageValue: String = ""
    var toLanguageValue: String = ""
    let fullUrl: String = Constants.Storyboard.URL_BASE + "/ios-upload"
    var fileURL: URL?
    var fileContents: NSMutableData = NSMutableData()
  //  var fileName: String = ""
    var mimeType: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
  //      languagePickerOptions = ["English","Telugu","Spanish","Hindi","Tamil"]
        let languagePickerOptions:[(languageText: String, languageValue: String)] = [("English(UnitedStates)", "en-US"), ("Telugu(India)", "te-IN"), ("Spanish(Spain)", "es-ES"), ("Zulu(SouthAfrica)", "zu-ZA")]
        
        fromLanguagePickerOptions = languagePickerOptions
        toLanguagePickerOptions = languagePickerOptions
        
        setUpElements()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
                    
        // Style the UI Elements
        Utilities.styleHollowButton(chooseFileButton)
        Utilities.styleFilledButton(uploadButton)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /* func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    } */
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        // return languagePickerOptions.count
        if currentTextField == fromLanguagePicker {
            return fromLanguagePickerOptions.count
        } else if currentTextField == toLanguagePicker {
            return toLanguagePickerOptions.count
        } else {
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if currentTextField == fromLanguagePicker {
            return fromLanguagePickerOptions[row].languageText
        } else if currentTextField == toLanguagePicker {
            return toLanguagePickerOptions[row].languageText
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if currentTextField == fromLanguagePicker {
            fromLanguagePicker.text = fromLanguagePickerOptions[row].languageText
            fromLanguageValue = fromLanguagePickerOptions[row].languageValue
            self.view.endEditing(true)
        } else if currentTextField == toLanguagePicker {
            toLanguagePicker.text = toLanguagePickerOptions[row].languageText
            toLanguageValue = toLanguagePickerOptions[row].languageValue
            self.view.endEditing(true)
        }
    }
    
    // Textfield Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        currentTextField = textField
        if currentTextField == fromLanguagePicker {
            currentTextField.inputView = pickerView
        } else if currentTextField == toLanguagePicker {
            currentTextField.inputView = pickerView
        }
    }
    
    
    @IBAction func chooseFileTapped(_ sender: Any) {
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeAudio as String, kUTTypeMP3 as String, kUTTypeMPEG4Audio as String, kUTTypeAppleProtectedMPEG4Audio as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    func uploadSingleFile() {
        // print("File URL is: \(fileURL!)")
        let fileInfo = NetworkService.FileInfo(withFileURL: fileURL, filename: SharedData.sharedDataInstance.fileName!, name: "file", mimetype: mimeType)
        upload(files: [fileInfo], toURL: URL(string: fullUrl))
    }
    
    func upload(files: [NetworkService.FileInfo], toURL url: URL?) {
        if let uploadURL = url {
            
       //     print("Username is \(String(describing: SharedData.sharedDataInstance.userName!))")
       //     print("Source Language is: \(fromLanguageValue)")
       //     print("Target Language is: \(toLanguageValue)")
       //     NetworkService.sharedNetworkService.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
            NetworkService.sharedNetworkService.httpBodyParameters.add(value: SharedData.sharedDataInstance.userName!, forKey: "username")
            NetworkService.sharedNetworkService.httpBodyParameters.add(value: fromLanguageValue, forKey: "srclang")
            NetworkService.sharedNetworkService.httpBodyParameters.add(value: toLanguageValue, forKey: "tgtlang")
            
            NetworkService.sharedNetworkService.upload(files: files, toURL: uploadURL, withHttpMethod: .post) { (results, failedFilesList) in
                print("HTTP status code:", results.response?.httpStatusCode ?? 0)
     
                if let error = results.error {
                    print(error)
                }
     
                if let data = results.data {
                    if let toDictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                        print(toDictionary)
                    }
                }
     
                if let failedFiles = failedFilesList {
                    for file in failedFiles {
                        print(file)
                    }
                }
            }
        }
    }
    
    @IBAction func uploadButtonTapped(_ sender: Any) {
        uploadSingleFile()
    }
    
}

extension TranslateViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else {
            return
        }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            print("File already exists in the app sandbox")
        } else {
            do {
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
                print("Copied file")
            } catch {
                print("Error: \(error)")
            }
        }
        
        SharedData.sharedDataInstance.fileName = sandboxFileURL.lastPathComponent
        fileURL = URL(fileURLWithPath: sandboxFileURL.path)
        
        let pathExtension = sandboxFileURL.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            mimeType = (UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue())! as String
            print("Mimetype: \(mimeType)")
        }
        
      /*  let asset = AVAsset(url: fileURL!)
        print("Audio metadata: \(asset.commonMetadata)")
        print("Audio duration: \(asset.duration)")
        print("Audio duration: \(CMTimeGetSeconds(asset.duration))")
        print("File name: \(sandboxFileURL.lastPathComponent)")
        
        do {
            fileContents = try NSMutableData(contentsOfFile: sandboxFileURL.path)
            print("Audio Data: \(fileContents)")
        } catch {
            print("Error: \(error)")
        }
     
        let headerS: HTTPHeaders = [
        "Authorization": "Bearer (HelperGlobalVars.shared.access_token)",
        "Accept": "application/json"
        ]
        
        print("Username is \(String(describing: SharedData.sharedDataInstance.userName!))")
        
        AF.upload(
        multipartFormData: { multipartFormData in
            // multipartFormData.append(fileUrl, withName: fileName)
            multipartFormData.append(self.fileContents as Data, withName: "file", fileName: self.fileName, mimeType: "audio/m4a")
            multipartFormData.append("mytestuser@mail.com".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"username")
            multipartFormData.append("en-US".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"srclang")
            multipartFormData.append("te-IN".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"tgtlang")
        },
        to: fullUrl,
        method: .post,
        headers: headerS)
        .responseJSON { response in
            print("Response: ")
            debugPrint(response)
        } */
    }
    
}
