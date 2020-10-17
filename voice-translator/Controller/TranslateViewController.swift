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
import MediaPlayer

class TranslateViewController: UIViewController, Loggable {
    
    @IBOutlet weak var recordPromptLabel: UILabel!
    
    @IBOutlet weak var translateFrom: DropDownButton!
    @IBOutlet weak var translateFromLabel: LeftPaddedLabel!
    
    @IBOutlet weak var translateTo: DropDownButton!
    @IBOutlet weak var translateToLabel: LeftPaddedLabel!
    
    @IBOutlet weak var chooseFileButton: UIButton!
    @IBOutlet weak var fileName: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var logCategory = "Upload"
    
    var recordingSession: AVAudioSession!
    var fromLanguageValue = ""
    var toLanguageValue = ""
    
    let uploadURL: String = Constants.Api.URL_BASE + Constants.Api.URL_UPLOAD
    var fileURL: URL?
    var fileContents: NSMutableData = NSMutableData()
    //  var fileName: String = ""
    var mimeType: String = ""
    var fileSize: Double = 0
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
                        let errorMessage = "You did not grant permission to record. Please grant permission from settings for this app or upload an existing file from your storage"
                        Log(self).error(errorMessage, includeCodeLocation: true)
                        self.showError(errorMessage)
                    }
                }
            }
        } catch {
            // failed to record!
            let errorMessage = "Error occured while trying to record."
            Log(self).error(errorMessage, includeCodeLocation: true)
            showError(errorMessage)
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
        
        let actionSheetAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let mediaAction = UIAlertAction(title: " Media", style: .default) { (action) -> Void in
            
            let status = MPMediaLibrary.authorizationStatus()
            let appD = UIApplication.shared.delegate as? AppDelegate
            switch status {
            case .denied, .restricted, .notDetermined:
                if (appD!.hasAlreadyLaunched) {
                    self.showError("Please grant media library access for 'Voice Translate' app in Settings > Privacy")
                } else {
                    appD!.sethasAlreadyLaunched()
                }
            case .authorized:
                break
            @unknown default:
                self.showError("There's an unknown error while accessing media library. Please grant media library access for 'Voice Translate' app in Settings > Privacy")
            }
            
            let mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.anyAudio)
            mediaPicker.delegate = self
            mediaPicker.allowsPickingMultipleItems = false
            self.present(mediaPicker, animated: true, completion: nil)
            
        }
        
        let mediaImage = UIImage(systemName: "music.note.list")?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBlue)
        mediaAction.setValue(mediaImage, forKey: "image")
        mediaAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
//      mediaAction.setValue(UIColor.black, forKey: "titleTextColor")
        actionSheetAlertController.addAction(mediaAction)
        
        let documentAction = UIAlertAction(title: "  Document", style: .default) { (action) -> Void in
            
            let options = [kUTTypeAudio as String, kUTTypeMP3 as String, kUTTypeMPEG4Audio as String, kUTTypeAppleProtectedMPEG4Audio as String]
            let documentPicker = UIDocumentPickerViewController(documentTypes: options, in: .import)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            self.present(documentPicker, animated: true, completion: nil)
            
        }
        
        let documentImage = UIImage(systemName: "doc")?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBlue)
        documentAction.setValue(documentImage, forKey: "image")
        documentAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
//      documentAction.setValue(UIColor.black, forKey: "titleTextColor")
        actionSheetAlertController.addAction(documentAction)
       
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        actionSheetAlertController.addAction(cancelAction)
        
        actionSheetAlertController.pruneNegativeWidthConstraints()
        actionSheetAlertController.view.layer.cornerRadius = 25
        actionSheetAlertController.view.tintColor = .black

        if let popoverController = actionSheetAlertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        self.present(actionSheetAlertController, animated: true, completion: nil)
        
    }
    
    func uploadSingleFile() {
        if fileURL == nil {
            showError("Please choose a file to upload")
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                self.uploadButton.isUserInteractionEnabled = true
            }
            return
        }
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
//                  print("HTTP status code:", statusCode ?? 0)
                    
                    // Response returned from the API, disable spinning wheel and re-enable the controls on the screen
                    self.indicator.stopAnimating()
                    self.indicator.hidesWhenStopped = true
                    
                    if let error = results.error {
//                      print(error)
                        Log(self).error("API error during file upload: \(error)", includeCodeLocation: true)
                    }
                    
                    if let data = results.data {
                        if let toDictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
//                          print(toDictionary)
                            Log(self).info("Response from upload API: \(toDictionary)")
                        }
                    }
                    
                    if let failedFiles = failedFilesList {
                        for file in failedFiles {
//                          print(file)
                            Log(self).error("File that failed during upload: \(file)", includeCodeLocation: true)
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
        
        // Disabled filename validation as music library doesn't have those restrictions
        // Validate filename
//      let filename = fileName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//      if Utilities.isValidFile(filename) == false {
//
//          // File is invalid
//          return "File name is invalid. Cannot contain spaces or braces"
//      }
        
        // Validate that the file size is not greater than 100MB
        let oneHundredMB = Double(100 * 1024 * 1024)
        if fileSize > oneHundredMB {
            return "File too big, please upload a file less than 100MB"
        }
        
        return nil
    }
    
    func accessMusicLibrary(pathURL: URL, title: String) {
        
        Log(self).info("Access to media library is authorized")
        exportFileToAppSandbox(pathURL, title: title) { sandboxFileURL, error in
            guard let sandboxFileURL = sandboxFileURL, error == nil else {
                Log(self).error("Export failed: \(error!)", includeCodeLocation: true)
                return
            }
            
            SharedData.instance.fileName = sandboxFileURL.lastPathComponent
            self.fileURL = URL(fileURLWithPath: sandboxFileURL.path)
            
            DispatchQueue.main.async {
                // Export completed. Hide spinning wheel
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                
                // Setting the fileName to the fileName outlet in the view
                self.fileName.text = sandboxFileURL.lastPathComponent
                self.fileName.alpha = 1
            }
            
        }
        
    }
    
    func exportFileToAppSandbox(_ assetURL: URL, title: String, completionHandler: @escaping (_ fileURL: URL?, _ error: Error?) -> ()) {
        let asset = AVURLAsset(url: assetURL)
        mimeType = assetURL.mimeType()
        
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            completionHandler(nil, ExportError.unableToCreateExporter)
            return
        }
        
        exporter.timeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        let estimatedFileSize = Double(exporter.estimatedOutputFileLength)
        let doubleBytes = Double(1048576)
        let fileSizeInMB = estimatedFileSize / doubleBytes
        fileSize = round(fileSizeInMB * 100) / 100 // round off to 2 decimal places
        
        // Export process takes a while. Show spinning wheel
        indicator.startAnimating()
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = dir.appendingPathComponent(title).appendingPathExtension("m4a")
        
        //Delete Existing file
        do {
            try FileManager.default.removeItem(at: sandboxFileURL)
        } catch let error as NSError {
            Log(self).error("File could not be deleted from sandbox: \(error.debugDescription)")
        }
        
        exporter.outputURL = sandboxFileURL
        exporter.outputFileType = .m4a
        
        exporter.exportAsynchronously {
            if exporter.status == .completed {
                completionHandler(sandboxFileURL, nil)
            } else {
                completionHandler(nil, exporter.error)
            }
        }
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
            fileSize = attr[FileAttributeKey.size] as! Double
//          print("File size: + \(fileSize)")
            
            try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
//          print("Copied file")
        } catch {
//          print("Error: \(error)")
            Log(self).error("Error while copying the file: \(error)")
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

extension TranslateViewController: MPMediaPickerControllerDelegate {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {

        guard let item: MPMediaItem = mediaItemCollection.items.first else {
            return
        }
        let pathURL: URL? = item.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
        if pathURL == nil {
            self.showError("Unable to read DRM protected file.")
            return
        }
        let title = item.value(forProperty: MPMediaItemPropertyTitle) as? String ?? "Unknown Title"
        accessMusicLibrary(pathURL: pathURL!, title: title)
        
        self.dismiss(animated:true)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated:true)
    }
    
}

enum ExportError: Error {
    case unableToCreateExporter
}
