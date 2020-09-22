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
    
    @IBOutlet weak var speechButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var checkStatusButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
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
        Utilities.styleFilledButton(speechButton)
        Utilities.styleFilledButton(audioButton)
        Utilities.styleFilledButton(checkStatusButton)
        
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
    
    // Queries database and returns upto 5 translated audio files for the user
    @IBAction func checkStatusForUser(_ sender: Any) {
        
        checkStatus()
        activityIndicator()
        indicator.startAnimating()
        indicator.backgroundColor = .white
//      checkStatusButton.isUserInteractionEnabled = false
    }
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        
        if let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.profileViewController) as? ProfileViewController {
            navigationController?.pushViewController(profileVC, animated: true)
        }
        
    }
    
    // Call ios-checkstatus API to fetch upto 5 previously translated audio files for the current user
    func checkStatus() {
        let checkStatusUrl: String = Constants.Api.URL_BASE + Constants.Api.URL_CHECKSTATUS
        guard let url = URL(string: checkStatusUrl) else { return }
        NetworkService.sharedNetworkService.urlQueryParameters.add(value: SharedData.instance.userName!, forKey: "username")
        
        NetworkService.sharedNetworkService.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            
            DispatchQueue.main.async {
                let statusCode = results.response?.httpStatusCode
                print("HTTP status code:", statusCode ?? 0)
                
                // Response returned from the API, disable spinning wheel and re-enable the controls on the screen
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                
                if let data = results.data {
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
                    //                  print(statusURL.description)
                    SharedData.instance.statusForUser = statusURL
                } else {
                    //                  print("Could not fetch data from server")
                    SharedData.instance.statusForUser = ["Could not fetch data from server"]
                }
                self.transitionToShowStatus()
            }
        }
    }
    
    // Transition to Status screen
    func transitionToShowStatus() {
        
//        let statusViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.statusViewController) as? StatusViewController
//
//        view.window?.rootViewController = statusViewController
//        view.window?.makeKeyAndVisible()
        
        if let statusViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.statusViewController) as? StatusViewController {
          navigationController?.pushViewController(statusViewController, animated: true)
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
    
}
