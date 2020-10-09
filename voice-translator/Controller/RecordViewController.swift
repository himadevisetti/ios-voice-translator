//
//  RecordViewController.swift
//  voice-translator
//
//  Created by Hima Devisetti on 9/3/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingImage: UIImageView!
    @IBOutlet weak var startRecordButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var audioRecorder: AVAudioRecorder!
    let recordImage = Utilities.resizeImage(image: UIImage(systemName: "mic.circle")!, targetSize: CGSize(width: 100.0, height: 100.0))
    let stopRecordImage = Utilities.resizeImage(image: UIImage(systemName: "mic.slash.fill")!, targetSize: CGSize(width: 100.0, height: 100.0))
    
    var toolItems : [UIBarButtonItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpNavigationBarAndItems()
        setUpElements()
    }
    
    func setUpNavigationBarAndItems() {
        
        // Set the screen title
        self.navigationController?.navigationBar.isTranslucent = false
        let attributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 17)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.navigationItem.title = Constants.Storyboard.recordScreenTitle

        // Hide the back button to avoid navigating back to login screen
        self.navigationItem.hidesBackButton = true
        
        // Hide bottom toolbar
//      self.navigationController?.setToolbarHidden(true, animated: true)
        
    }
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the elements
        setStartRecordingImage()
        Utilities.styleFilledButton(startRecordButton)
        startRecordButton.titleLabel?.font =  UIFont(name: "AvenirNext-DemiBold", size: 20)
        Utilities.styleFilledButton(uploadButton)
        
    }
    
    func setStartRecordingImage() {
        recordingImage.image = recordImage
        recordingImage.image = recordingImage.image?.withRenderingMode(.alwaysTemplate)
        recordingImage.tintColor = .red
    }
    
    func setStopRecordingImage() {
        recordingImage.image = stopRecordImage
        recordingImage.image = recordingImage.image?.withRenderingMode(.alwaysTemplate)
        recordingImage.tintColor = .red
    }
    
    func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    @IBAction func startRecordTapped(_ sender: Any) {
        
        if audioRecorder == nil {
            recordingImage.alpha = 1.0
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
                self.recordingImage.alpha = 0.0
            }, completion: nil)
            startRecording()
        } else {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
                self.recordingImage.alpha = 1.0
            }, completion: nil)
            stopRecording(success: true)
        }
        
    }
    
    
    func startRecording() {
        
        let usernameArr = SharedData.instance.userName!.components(separatedBy: "@")
        let filename = usernameArr[0] + "_recording.m4a"
//      print("file name is: \(filename)")
        
        SharedData.instance.fileName = filename
        let audioFilename = getDocumentsDirectory().appendingPathComponent(filename)
        
        // Get the singleton instance.
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Set the audio session category, mode, and options.
            try audioSession.setCategory(.playAndRecord, mode:.spokenAudio)
            try audioSession.setActive(true)
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            
        } catch {
//          print("Failed to set audio session properties.")
            Log(self).error("Failed to set audio session properties for recording.", includeCodeLocation: true)
        }
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            startRecordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            stopRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func stopRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        setStopRecordingImage()
        
        if success {
            startRecordButton.setTitle("Tap to Re-record", for: .normal)
            setStartRecordingImage()
        } else {
            startRecordButton.setTitle("Tap to Record", for: .normal)
            setStartRecordingImage()
            // recording failed
            Log(self).error("Recording failed for some reason.")
            showError("Recording failed for some reason.")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopRecording(success: false)
        }
    }
        
    @IBAction func uploadButtonTapped(_ sender: Any) {
        
//        if let translateVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.translateViewController) as? TranslateViewController {
//            navigationController?.pushViewController(translateVC, animated: true)
//        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
