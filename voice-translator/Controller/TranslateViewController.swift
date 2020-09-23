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

class TranslateViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var recordPromptLabel: UILabel!
    @IBOutlet weak var fromLanguagePicker: UITextField!
    @IBOutlet weak var toLanguagePicker: UITextField!
    @IBOutlet weak var chooseFileButton: UIButton!
    @IBOutlet weak var fileName: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var recordingSession: AVAudioSession!
    
    var currentTextField = UITextField()
    var pickerView = UIPickerView()
    
    // var languagePickerOptions:[String] = []
    var fromLanguagePickerOptions:[(languageText: String, languageValue: String)] = []
    var toLanguagePickerOptions:[(languageText: String, languageValue: String)] = []
    
    var fromLanguageValue: String = ""
    var toLanguageValue: String = ""
    let uploadURL: String = Constants.Api.URL_BASE + Constants.Api.URL_UPLOAD
    var fileURL: URL?
    var fileContents: NSMutableData = NSMutableData()
    //  var fileName: String = ""
    var mimeType: String = ""
    var fileSize: UInt64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpNavigationBarAndItems()
        
        fromLanguagePickerOptions = Constants.languagePickerOptions
        toLanguagePickerOptions = Constants.languagePickerOptions
        
        setUpElements()
    }
    
    func setUpNavigationBarAndItems() {
        
        // Set the screen title
        self.navigationController?.navigationBar.isTranslucent = false
        let attributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 17)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.navigationItem.title = Constants.Storyboard.translateScreenTitle
        
        // Hide bottom toolbar
//      self.navigationController?.setToolbarHidden(true, animated: true)
        
        // Add record button to navigation bar on the right-side
        let recordButton = UIBarButtonItem(image: UIImage(systemName: "music.mic")!.withRenderingMode(.alwaysOriginal),
                                      style: .plain, target: self, action: #selector(recordButtonTapped))
        self.navigationItem.rightBarButtonItem  = recordButton
        
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        
        seekUserPermission()
        
    }
    
    // Seek user's permission to record
    func seekUserPermission() {
        
        recordingSession = AVAudioSession.sharedInstance()
            
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { (allowed) in
                DispatchQueue.main.async {
                    if allowed {
                        print("User has granted permission to record.")
                        if let recordViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.recordViewController) as? RecordViewController {
                            self.navigationController?.pushViewController(recordViewController, animated: true)
                        }
                    } else {
                        // failed to record!
                        self.showError("You did not grant permission to record. Please grant permission from settings for this app or upload an existing file from your storage")
                     }
                }
            }
        } catch {
            // failed to record!
            showError("Error occured while trying to record.")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        fileName.alpha = 0
        
        // Style the UI Elements
        recordPromptLabel.text = "Want to record? Click on record icon at the top-right corner"
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
        let fileInfo = NetworkService.FileInfo(withFileURL: fileURL, filename: SharedData.instance.fileName!, name: "file", mimetype: mimeType)
        upload(files: [fileInfo], toURL: URL(string: uploadURL))
    }
    
    func upload(files: [NetworkService.FileInfo], toURL url: URL?) {
        if let uploadURL = url {
            
     //     NetworkService.sharedNetworkService.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
            NetworkService.sharedNetworkService.httpBodyParameters.add(value: SharedData.instance.userName!, forKey: "username")
            NetworkService.sharedNetworkService.httpBodyParameters.add(value: fromLanguageValue, forKey: "srclang")
            NetworkService.sharedNetworkService.httpBodyParameters.add(value: toLanguageValue, forKey: "tgtlang")
            
            NetworkService.sharedNetworkService.upload(files: files, toURL: uploadURL, withHttpMethod: .post) { (results, failedFilesList) in
                
                DispatchQueue.main.async {
                    
                    let statusCode = results.response?.httpStatusCode
                    print("HTTP status code:", statusCode ?? 0)
                    
                    // Response returned from the API, disable spinning wheel and re-enable the controls on the screen
                    self.indicator.stopAnimating()
                    self.indicator.hidesWhenStopped = true
                    
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
                    
                    if statusCode == 200 {
                        if let messageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.messageViewController) as? MessageViewController {
                            self.navigationController?.pushViewController(messageVC, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func uploadButtonTapped(_ sender: Any) {
        let error = validateFields()
        
        if error != nil {
            // Input is not valid
            self.showError(error!)
            
        } else {
            self.uploadSingleFile()
            activityIndicator()
            indicator.startAnimating()
            indicator.backgroundColor = .white
            uploadButton.isUserInteractionEnabled = false
        }
        
    }
    
    var indicator = UIActivityIndicatorView()
    
    // Spinning wheel processing indicator to show while waiting for the GET API's response
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    // Validate the input fields
    // If valid, returns nil
    // If invalid, return an error string
    func validateFields() -> String? {
        
        // Ensure that all mandatory fields are filled in
        if fromLanguageValue == "" {
            return "Please choose a value from 'From Language' dropdown."
        }
        
        if toLanguageValue == "" {
            return "Please choose a value from 'To Language' dropdown."
        }
        
        // Validate that a file was uploaded
        let filename = fileName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isValidFile(filename) == false {
            
            // File is invalid
            return "Please upload a valid file"
        }
        
        // Validate that the file size is not greater than 100MB
        let oneHundredMB = 100 * 1024 * 1024
        if fileSize > oneHundredMB {
            return "File too big, please upload a file less than 100MB"
        }
        
        return nil
    }
    
}

extension TranslateViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else {
            return
        }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: selectedFileURL.path)
            fileSize = attr[FileAttributeKey.size] as! UInt64
//          print("File size: + \(fileSize)")
            
            try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
//          print("Copied file")
        } catch {
            print("Error: \(error)")
        }
        
        SharedData.instance.fileName = sandboxFileURL.lastPathComponent
        fileURL = URL(fileURLWithPath: sandboxFileURL.path)
        
        let pathExtension = sandboxFileURL.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            mimeType = (UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue())! as String
        }
        
        // Setting the fileName to the fileName outlet in the view
        fileName.text = sandboxFileURL.lastPathComponent
        fileName.alpha = 1
        self.view.endEditing(true)
        
    }
    
}
