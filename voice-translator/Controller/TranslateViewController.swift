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

class TranslateViewController: UIViewController {
    
    @IBOutlet weak var recordPromptLabel: UILabel!
    
    @IBOutlet weak var translateFrom: DropDownButton!
    @IBOutlet weak var translateFromLabel: LeftPaddedLabel!
    
    @IBOutlet weak var translateTo: DropDownButton!
    @IBOutlet weak var translateToLabel: LeftPaddedLabel!
    
    @IBOutlet weak var chooseFileButton: UIButton!
    @IBOutlet weak var fileName: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var recordingSession: AVAudioSession!
    var fromLanguageValue = ""
    var toLanguageValue = ""
    
    let uploadURL: String = Constants.Api.URL_BASE + Constants.Api.URL_UPLOAD
    var fileURL: URL?
    var fileContents: NSMutableData = NSMutableData()
    //  var fileName: String = ""
    var mimeType: String = ""
    var fileSize: UInt64 = 0
    var indicator = UIActivityIndicatorView(style: .large)
    
    lazy var alert : UIAlertController = {
        let alert = UIAlertController(title: Constants.tokenFetchingAlertTitle, message: Constants.tokenFetchingAlertMessage, preferredStyle: .alert)
        return alert
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(dismissAlert), name: NSNotification.Name(Constants.tokenReceived), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert), name: NSNotification.Name(Constants.retreivingToken), object: nil)
        
        setUpNavigationBarAndItems()
        setUpElements()
        setUpActivityIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let appD = UIApplication.shared.delegate as? AppDelegate, appD.voiceLists?.isEmpty ?? true {
            
            presentAlert()
            appD.fetchVoiceList()
            NotificationCenter.default.addObserver(self, selector: #selector(dismissAlert), name: NSNotification.Name("FetchVoiceList"), object: nil)
            
        }
        
    }
    
    @objc func presentAlert() {
        //Showing the alert until token is received
        if alert.isViewLoaded == false {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func dismissAlert() {
        alert.dismiss(animated: true, completion: nil)
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
                        //                      print("User has granted permission to record.")
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
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        fileName.alpha = 0
        
        // Style the UI Elements
        recordPromptLabel.text = "Want to record? Click on record icon at the top-right corner"
        Utilities.styleFilledLeftButton(translateFrom)
        Utilities.styleFilledLeftButton(translateTo)
        Utilities.styleHollowButton(chooseFileButton)
        Utilities.styleFilledButton(uploadButton)
        
    }
    
    @IBAction func translateFromTapped(_ sender: Any) {
        
        if let translateLanguageOptionsTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.translateLanguageOptionsTableViewController) as? TranslateLanguageOptionsTableViewController {
            translateLanguageOptionsTableViewController.index = 0
            translateLanguageOptionsTableViewController.delegate = self
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationController?.pushViewController(translateLanguageOptionsTableViewController, animated: true)
        }
        
    }
    
    func updateTranslateFrom(fromLanguageOption: String) {
        
        translateFromLabel.roundCorners(corners: [.topRight, .bottomRight], radius: 5)
        translateFromLabel.textColor = .black
        translateFromLabel.text = fromLanguageOption
        fromLanguageValue = fromLanguageOption.slice(from: "(", to: ")") ?? ""
        
    }
    
    @IBAction func translateToTapped(_ sender: Any) {
        
        if let translateLanguageOptionsTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.translateLanguageOptionsTableViewController) as? TranslateLanguageOptionsTableViewController {
            translateLanguageOptionsTableViewController.index = 1
            translateLanguageOptionsTableViewController.delegate = self
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationController?.pushViewController(translateLanguageOptionsTableViewController, animated: true)
        }
        
    }
    
    func updateTranslateTo(toLanguageOption: String) {
        
        translateToLabel.roundCorners(corners: [.topRight, .bottomRight], radius: 5)
        translateToLabel.textColor = .black
        translateToLabel.text = toLanguageOption
        toLanguageValue = toLanguageOption.slice(from: "(", to: ")") ?? ""
        
    }
    
    @IBAction func chooseFileTapped(_ sender: Any) {
        
        let options = [kUTTypeAudio as String, kUTTypeMP3 as String, kUTTypeMPEG4Audio as String, kUTTypeAppleProtectedMPEG4Audio as String]
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: options, in: .import)
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
            indicator.startAnimating()
            uploadButton.isUserInteractionEnabled = false
        }
        
    }
    
    // Spinning wheel processing indicator to show while waiting for the GET API's response
    func setUpActivityIndicator() {
        // Set up the activity indicator
        indicator.color = .gray
        indicator.backgroundColor = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        let safeAreaGuide = self.view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: safeAreaGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: safeAreaGuide.centerYAnchor)
        ])
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
