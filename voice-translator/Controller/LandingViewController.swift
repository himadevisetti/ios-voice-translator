//
//  LandingViewController.swift
//  voice-translator
//
//  Created by user178116 on 8/17/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import AVFoundation

class LandingViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var checkStatusButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var recordingSession: AVAudioSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the elements
        Utilities.styleFilledButton(recordButton)
        Utilities.styleFilledButton(translateButton)
        Utilities.styleFilledButton(checkStatusButton)
        
    }
    
    func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    // Queries database and returns upto 5 translated audio files for the user
    @IBAction func checkStatusForUser(_ sender: Any) {
        
        checkStatus()
    }
    
    // Call ios-checkstatus API to fetch upto 5 previously translated audio files for the current user
    func checkStatus() {
        let checkStatusUrl: String = Constants.Storyboard.URL_BASE + Constants.Storyboard.URL_CHECKSTATUS
        guard let url = URL(string: checkStatusUrl) else { return }
        NetworkService.sharedNetworkService.urlQueryParameters.add(value: SharedData.instance.userName!, forKey: "username")
        
        NetworkService.sharedNetworkService.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            
            DispatchQueue.main.async {
                let statusCode = results.response?.httpStatusCode
                print("HTTP status code:", statusCode ?? 0)
                
                if let data = results.data {
                    print("Data returned by the server is: \(data)")
                    let decoder = JSONDecoder()
                    var statusURL: [String]
                    if let status = try? decoder.decode([String].self, from: data) {
                        statusURL = status
                    } else if let status = try? decoder.decode(String.self, from: data) {
                        statusURL = [status]
                    }
                    else {
                        return
                    }
                    print(statusURL.description)
                    SharedData.instance.statusForUser = statusURL
                } else {
                    print("Could not fetch data from server")
                    SharedData.instance.statusForUser = ["Could not fetch data from server"]
                }
                self.transitionToShowStatus()
            }
        }
    }
    
    // Transition to Status screen
    func transitionToShowStatus() {
        
        let statusViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.statusViewController) as? StatusViewController
        
        view.window?.rootViewController = statusViewController
        view.window?.makeKeyAndVisible()
        
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        seekUserPermission()
    }
    
    // Segue for back button from Record View Controller
    @IBAction func unwindFromRecordVC(unwindSegue: UIStoryboardSegue) {
    }
    
    // Seek user's permission to record
    func seekUserPermission() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("User has granted permission to record.")
                    } else {
                        // failed to record!
                        self.showError("You did not grant permission to record.")
                    }
                }
            }
        } catch {
            // failed to record!
            showError("Error occured while trying to record.")
        }
    }
    
}
