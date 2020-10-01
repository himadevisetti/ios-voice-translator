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
    
    @IBOutlet weak var userPromptLabel: UILabel!
    @IBOutlet weak var speechButton: UIButton!
    @IBOutlet weak var speechImage: UIImageView!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var audioImage: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var toolItems : [UIBarButtonItem] = []
    let speechImg = UIImage(systemName: "speaker.3.fill")
    let audioImg = UIImage(systemName: "mic.fill")
    
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
        self.navigationItem.title = Constants.Storyboard.homeScreenTitle

        // Hide the back button to avoid navigating back to login screen
        self.navigationItem.hidesBackButton = true
        
        // Add profile to bottom bar
        navigationController?.isToolbarHidden = false
        toolItems.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil))
        toolItems.append(UIBarButtonItem(image: UIImage(systemName: "person.crop.circle")!.withRenderingMode(.alwaysOriginal),
                                         style: .plain, target: self, action: #selector(profileButtonTapped)))
        toolItems.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil))
        self.toolbarItems = toolItems
        
    }
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the elements
        userPromptLabel.text = "* Tap 'Speech' for Speech translate \n* Tap 'Audio' for File translate \n"
        Utilities.styleFilledButton(speechButton)
        Utilities.styleFilledButton(audioButton)
        setSpeechImage()
        setAudioImage()
        
    }
    
    func setSpeechImage() {
        speechImage.image = speechImg
        speechImage.image = speechImage.image?.withRenderingMode(.alwaysTemplate)
        speechImage.tintColor = .systemIndigo
    }
    
    func setAudioImage() {
        audioImage.image = audioImg
        audioImage.image = audioImage.image?.withRenderingMode(.alwaysTemplate)
        audioImage.tintColor = .systemIndigo
    }
    
    func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    @IBAction func speechButtonTapped(_ sender: Any) {
        
        if let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.settingsViewController) as? SettingsViewController {
            navigationController?.pushViewController(settingsVC, animated: true)
        }
        
    }
        
    @IBAction func audioButtonTapped(_ sender: Any) {
        
        if let translateVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.translateViewController) as? TranslateViewController {
            navigationController?.pushViewController(translateVC, animated: true)
        }
        
    }
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        
        if let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.profileViewController) as? ProfileViewController {
            navigationController?.pushViewController(profileVC, animated: true)
        }
        
    }
    
}
