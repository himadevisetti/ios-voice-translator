//
//  ProfileViewController.swift
//  voice-translator
//
//  Created by Hima Devisetti on 9/21/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpNavigationBarAndItems()
    }
    
    func setUpNavigationBarAndItems() {
        
        // Set the screen title
        self.navigationController?.navigationBar.isTranslucent = false
        let attributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 17)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.navigationItem.title = Constants.Storyboard.profileScreenTitle
        
    }

    @IBAction func LogOutTapped(_ sender: Any) {
        
        if let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.loginViewController) as? LoginViewController {
          navigationController?.pushViewController(loginViewController, animated: true)
        }
        
    }

}
