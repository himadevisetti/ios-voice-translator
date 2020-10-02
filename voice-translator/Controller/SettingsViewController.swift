//
//  SettingsViewController.swift
//  voice-translator
//
//  Created by Hima Devisetti on 9/25/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var selectedTransFrom = ""
    var selectedTransTo   = ""
    var selectedSynthName = ""
    var selectedVoiceType = ""
    
    @IBOutlet weak var translateFrom: DropDownButton!
    @IBOutlet weak var translateFromLabel: LeftPaddedLabel!
    
    @IBOutlet weak var translateTo: DropDownButton!
    @IBOutlet weak var translateToLabel: LeftPaddedLabel!
    
    @IBOutlet weak var ttsTech: DropDownButton!
    @IBOutlet weak var ttsTechLabel: LeftPaddedLabel!
    
    @IBOutlet weak var voiceType: DropDownButton!
    @IBOutlet weak var voiceTypeLabel: LeftPaddedLabel!
    
    @IBOutlet weak var getStartedButton: UIButton!
    
    lazy var alert : UIAlertController = {
        let alert = UIAlertController(title: Constants.tokenFetchingAlertTitle, message: Constants.tokenFetchingAlertMessage, preferredStyle: .alert)
        return alert
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = .black
        NotificationCenter.default.addObserver(self, selector: #selector(dismissAlert), name: NSNotification.Name(Constants.tokenReceived), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert), name: NSNotification.Name(Constants.retreivingToken), object: nil)
        setUpNavigationBarAndItems()
        setUpElements()
        if let userPreference = UserDefaults.standard.value(forKey: Constants.userLanguagePreferences) as? [String: String] {
            selectedTransFrom = userPreference[Constants.selectedTransFrom] ?? ""
            selectedTransTo = userPreference[Constants.selectedTransTo] ?? ""
            selectedSynthName = userPreference[Constants.selectedSynthName] ?? ""
            selectedVoiceType = userPreference[Constants.selectedVoiceType] ?? ""
            translateFromLabel.text = selectedTransFrom
            translateToLabel.text = selectedTransTo
            ttsTechLabel.text = selectedSynthName
            voiceTypeLabel.text = selectedVoiceType
        }

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
        self.title = Constants.Storyboard.settingsScreenTitle
        
        // Hide the back button to avoid navigating back to upload screen
        self.navigationItem.hidesBackButton = true
        
        // Add home button to navigation bar on the right-side
        let homeButton = UIBarButtonItem(image: UIImage(systemName: "house")!.withRenderingMode(.alwaysOriginal),
                                         style: .plain, target: self, action: #selector(homeButtonTapped))
        self.navigationItem.rightBarButtonItem  = homeButton
        
    }
    
    func setUpElements() {
        
        // Style the UI Elements     
        Utilities.styleFilledLeftButton(translateFrom)
        Utilities.styleFilledLeftButton(translateTo)
        Utilities.styleFilledLeftButton(ttsTech)
        Utilities.styleFilledLeftButton(voiceType)
        Utilities.styleFilledButton(getStartedButton)
        
    }
    
    @IBAction func homeButtonTapped(_ sender: Any) {
        
        if let landingViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.landingViewController) as? LandingViewController {
            navigationController?.pushViewController(landingViewController, animated: true)
        }
        
    }
    
    @IBAction func translateFromTapped(_ sender: Any) {
        
        if let languageOptionsTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.languageOptionsTableViewController) as? LanguageOptionsTableViewController {
            languageOptionsTableViewController.index = 0
            languageOptionsTableViewController.delegate = self
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationController?.pushViewController(languageOptionsTableViewController, animated: true)
        }
        
    }
    
    func updateTranslateFrom(fromLanguageOption: String) {
        
        translateFromLabel.roundCorners(corners: [.topRight, .bottomRight], radius: 5)
        translateFromLabel.textColor = .black
        translateFromLabel.text = fromLanguageOption
        selectedTransFrom = fromLanguageOption
        
    }
    
    @IBAction func translateToTapped(_ sender: Any) {
        
        if let languageOptionsTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.languageOptionsTableViewController) as? LanguageOptionsTableViewController {
            languageOptionsTableViewController.index = 1
            languageOptionsTableViewController.delegate = self
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationController?.pushViewController(languageOptionsTableViewController, animated: true)
        }
        
    }
    
    func updateTranslateTo(toLanguageOption: String) {
        
        translateToLabel.roundCorners(corners: [.topRight, .bottomRight], radius: 5)
        translateToLabel.textColor = .black
        translateToLabel.text = toLanguageOption
        selectedTransTo = toLanguageOption
        let synthNames = OptionsType.synthName.getOptions(selectedTransTo: selectedTransTo)
        selectedSynthName = synthNames.contains("Wavenet") ? "Wavenet" : "Standard"
        ttsTechLabel.text = selectedSynthName
        ttsTechLabel.textColor = .black
        selectedVoiceType = "Default"
        voiceTypeLabel.text = selectedVoiceType
        
    }
    
    @IBAction func ttsTechTapped(_ sender: Any) {
        if let languageOptionsTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.languageOptionsTableViewController) as? LanguageOptionsTableViewController {
            languageOptionsTableViewController.index = 2
            if selectedTransTo.isEmpty {
                showNoTranslateToError()
            }
            languageOptionsTableViewController.selectedTransTo = selectedTransTo
            languageOptionsTableViewController.delegate = self
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationController?.pushViewController(languageOptionsTableViewController, animated: true)
        }
    }
    
    func updateSynthName(synthNameOption: String) {
        
        ttsTechLabel.roundCorners(corners: [.topRight, .bottomRight], radius: 5)
        ttsTechLabel.textColor = .black
        ttsTechLabel.text = synthNameOption
        selectedSynthName = synthNameOption
        
    }
    
    @IBAction func voiceTypeTapped(_ sender: Any) {
        if let languageOptionsTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.languageOptionsTableViewController) as? LanguageOptionsTableViewController {
            languageOptionsTableViewController.index = 3
            if selectedTransTo.isEmpty {
                showNoTranslateToError()
            }
            languageOptionsTableViewController.selectedTransTo = selectedTransTo
            languageOptionsTableViewController.delegate = self
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationController?.pushViewController(languageOptionsTableViewController, animated: true)
        }
    }
    
    func updateVoiceType(voiceTypeOption: String) {
        
        voiceTypeLabel.roundCorners(corners: [.topRight, .bottomRight], radius: 5)
        voiceTypeLabel.textColor = .black
        voiceTypeLabel.text = voiceTypeOption
        selectedVoiceType = voiceTypeOption
        
    }
    
    @IBAction func getStarted(_ sender: Any) {
        //  print("selectedTransFrom: \(selectedTransFrom)")
        //  print("selectedTransTo: \(selectedTransTo)")
        //  print("selectedVoiceType: \(selectedVoiceType)")
        //  print("selectedSynthName: \(selectedSynthName)")
        if selectedTransFrom.isEmpty || selectedTransTo.isEmpty ||
            selectedVoiceType.isEmpty || selectedSynthName.isEmpty {
            let alertVC = UIAlertController(title: "Infomation needed", message: "Please fill all the fields", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertVC, animated: true)
            return
            
        }
        UserDefaults.standard.set([Constants.selectedTransFrom: selectedTransFrom, Constants.selectedTransTo: selectedTransTo, Constants.selectedSynthName: selectedSynthName, Constants.selectedVoiceType : selectedVoiceType], forKey: Constants.userLanguagePreferences)
        if let speechVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.speechViewController) as? SpeechViewController {
            navigationController?.pushViewController(speechVC, animated: true)
        }
        
    }
    
    func showNoTranslateToError() {
        let alertVC = UIAlertController(title: "Information needed", message: "Please select translate to first", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true)
    }
    
}

enum OptionsType: Int {
    case translateFrom = 0, translateTo, synthName, voiceType
    
    func getTitle() -> String {
        switch self {
        case .translateFrom:
            return "Translate from"
        case .translateTo:
            return "Translate to"
        case .synthName:
            return "Synthesis name"
        case .voiceType:
            return "Voice type"
        }
    }
    
    func getMessage() -> String {
        switch self {
        case .translateFrom:
            return "Choose one option for Translate from"
        case .translateTo:
            return "Choose one option for Translate to"
        case .synthName:
            return "Choose one option for Synthesis name"
        case .voiceType:
            return "Choose one option for Voice type"
        }
    }
    
    func getOptions(selectedTransTo: String = "") -> [String] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let voiceList = appDelegate.voiceLists else { return [] }
        switch self {
        case .translateFrom, .translateTo:
            let from = voiceList.map { (formattedVoice) -> String in
                return formattedVoice.languageName
            }
            return from
        case .synthName:
            let synthName = voiceList.filter {
                return $0.languageName == selectedTransTo
            }
            if let synthesis = synthName.first {
                return synthesis.synthesisName
            }
            return []
        case .voiceType:
            let synthName = voiceList.filter {
                return $0.languageName == selectedTransTo
            }
            if let synthesis = synthName.first {
                return synthesis.synthesisGender
            }
            return []
        }
    }
}
