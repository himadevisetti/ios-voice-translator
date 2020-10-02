//
//  SpeechViewController.swift
//  voice-translator
//
//  Created by Hima Devisetti on 9/25/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import AVFoundation
import googleapis

let SAMPLE_RATE = 16000

class SpeechViewController : UIViewController, AudioControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var optionsCard: CardView!
    @IBOutlet weak var audioButton: UIButton!
    
    var audioData = NSMutableData()
    var listening: Bool = false
    var tableViewDataSource = [[String: String]]()
    var isFirst = true
    var avPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBarAndItems()
        optionsCard.cornerRadius = optionsCard.frame.height/2
        AudioController.sharedInstance.delegate = self
        SpeechRecognitionService.sharedInstance.delegate = self
    }
    
    func setUpNavigationBarAndItems() {
        
        // Set the screen title
        self.navigationController?.navigationBar.isTranslucent = false
        let attributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 17)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.title = Constants.Storyboard.speechScreenTitle
        
        // Hide the back button to avoid navigating back to login screen
        self.navigationItem.hidesBackButton = true
        
        // Hide bottom toolbar
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        // Add settings button to navigation bar on the right-side
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear")!.withRenderingMode(.alwaysOriginal),
                                             style: .plain, target: self, action: #selector(settingsButtonTapped))
        self.navigationItem.rightBarButtonItem  = settingsButton
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        
        if let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.settingsViewController) as? SettingsViewController {
            navigationController?.pushViewController(settingsVC, animated: true)
        }
        
    }
    
    @IBAction func recordAudio(_ sender: UIButton) {
        if listening {//Stop the audio
            _ = AudioController.sharedInstance.stop()
            SpeechRecognitionService.sharedInstance.stopStreaming()
            listening = false
            audioButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        } else {//Record the audio
            audioData = NSMutableData()
            _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
            SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
            _ = AudioController.sharedInstance.start()
            listening = true
            audioButton.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
        }
    }
    func processSampleData(_ data: Data) -> Void {
        
        audioData.append(data)
        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
                                                        * Double(SAMPLE_RATE) /* samples/second */
                                                        * 2 /* bytes/sample */);
        if audioData.length > chunkSize, let data = audioData as Data? {
            SpeechRecognitionService.sharedInstance.audioData = data
            SpeechRecognitionService.sharedInstance.streamAudioData()
            self.audioData = NSMutableData()
        }
    }
    
}

//MARK: helper functions
extension SpeechViewController {
    func showErrorAlert(message: String){
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true)
    }
    
    func handleError(error: Error) {
        showErrorAlert(message: error.localizedDescription)
    }
    
    func audioPlayerFor(audioData: Data) {
        DispatchQueue.main.async {
            do {
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                self.avPlayer = try AVAudioPlayer(data: audioData)
                if let _ = self.avPlayer {
                    self.avPlayer?.prepareToPlay()
                    self.avPlayer?.play()
                }
                
            } catch let error {
                print("Error occurred while playing audio: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: Table delegate handling
extension SpeechViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableViewDataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: data[Constants.selfKey] != nil ? "selfCI" : "intentCI", for: indexPath) as! ChatTableViewCell
        if data[Constants.selfKey] != nil {
            cell.selfText.text = data[Constants.selfKey]
        } else {
            cell.botResponseText.text = data[Constants.botKey]
        }
        return cell
    }
}

extension SpeechViewController: SpeechRecognitionServiceProtocol {
    func didReceiveAudioInputResponse(response: StreamingRecognizeResponse?, error: NSError?) {
        if let error = error {
            handleError(error: error)
        } else if let response = response, let resultArray = response.resultsArray as? [StreamingRecognitionResult] {
            //    print(response)
            for result in resultArray {
                if result.isFinal {
                    recordAudio(audioButton)
                    isFirst = true
                    let text = (result.alternativesArray?.firstObject as? SpeechRecognitionAlternative)?.transcript ?? ""
                    tableViewDataSource.removeLast()
                    tableViewDataSource.append([Constants.selfKey:text])
                    tableView.reloadRows(at: [IndexPath(row: tableViewDataSource.count - 1, section: 0)], with: .automatic)
                    
                    //Received transcript, sending it to Translation API
                    //MARK:- Call Translation API
                    
                    TranslationServices.sharedInstance.translateText(text: text, completionHandler: {(response, errorString) in
                        if let error = errorString {
                            self.showErrorAlert(message: error)
                        } else if let response = response {
                            guard let translatedObj = response.translationsArray.firstObject as? Translation, let translatedText = translatedObj.translatedText else {return}
                            self.tableViewDataSource.append([Constants.botKey: translatedText])
                            self.tableView.insertRows(at: [IndexPath(row: self.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                            //Received translated text, sending it to Speech to text API
                            //MARK:- Call STT API
                            TextToSpeechRecognitionService.sharedInstance.textToSpeech(text: translatedText, completionHandler: {(audioData, errorString) in
                                if let error = errorString {
                                    self.showErrorAlert(message: error)
                                } else if let audioData = audioData {
                                    self.audioPlayerFor(audioData: audioData)
                                }
                            })
                        }
                    })
                } else {
                    if let firstAlternativeResult = result.alternativesArray?.firstObject as? SpeechRecognitionAlternative, !firstAlternativeResult.transcript.isEmpty {
                        if isFirst {
                            tableViewDataSource.append([Constants.selfKey: firstAlternativeResult.transcript])
                            tableView.insertRows(at: [IndexPath(row: tableViewDataSource.count - 1, section: 0)], with: .automatic)
                            isFirst = false
                        } else {
                            tableViewDataSource.removeLast()
                            tableViewDataSource.append([Constants.selfKey: firstAlternativeResult.transcript])
                            tableView.reloadRows(at: [IndexPath(row: tableViewDataSource.count - 1, section: 0)], with: .automatic)
                        }
                    }
                }
            }
            tableView.scrollToBottom()
        }
    }
}

extension UITableView {
    func  scrollToBottom(animated: Bool = true) {
        let sections = self.numberOfSections
        let rows = self.numberOfRows(inSection: sections - 1)
        if (rows > 0) {
            self.scrollToRow(at: NSIndexPath(row: rows - 1, section: sections - 1) as IndexPath, at: .bottom, animated: true)
        }
    }
}

