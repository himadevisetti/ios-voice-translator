//
//  LandingViewController.swift
//  voice-translator
//
//  Created by user178116 on 8/17/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
    
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var checkStatusButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
   // let checkStatusUrl: String = Constants.Storyboard.URL_BASE + Constants.Storyboard.URL_CHECKSTATUS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the elements
        Utilities.styleFilledButton(translateButton)
        Utilities.styleFilledButton(checkStatusButton)
        
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
      //  transitionToShowStatus()
    }
    
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
                    guard let status = try? decoder.decode([String].self, from: data) else { return }
                    let statusURL = status
                    print(status.description)
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
    
}
