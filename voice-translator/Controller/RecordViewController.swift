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
    @IBOutlet weak var errorLabel: UILabel!
    
    var audioRecorder: AVAudioRecorder!
    let recordImage = Utilities.resizeImage(image: UIImage(systemName: "mic.circle")!, targetSize: CGSize(width: 100.0, height: 100.0))
    let stopRecordImage = Utilities.resizeImage(image: UIImage(systemName: "mic.slash.fill")!, targetSize: CGSize(width: 100.0, height: 100.0))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the elements
        setStartRecordingImage()
        Utilities.styleFilledButton(startRecordButton)
        startRecordButton.titleLabel?.font =  UIFont(name: "AvenirNext-DemiBold", size: 20)
        
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
            startRecording()
        } else {
            stopRecording(success: true)
        }
    }
    
    func startRecording() {
        let filename = SharedData.instance.userName! + "_recording.m4a"
//      print("file name is: \(filename)")
        SharedData.instance.fileName = filename
        let audioFilename = getDocumentsDirectory().appendingPathComponent(filename)
        
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
            showError("Recording failed for some reason.")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopRecording(success: false)
        }
    }
    
}
