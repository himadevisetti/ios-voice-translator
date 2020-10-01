//
//  AgreementsViewController.swift
//  voice-translator
//
//  Created by Hima Devisetti on 9/30/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import WebKit

class AgreementsViewController: UIViewController {

    var urlSwitchindex = 0
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpNavigationBarAndItems()
        
        switch urlSwitchindex {
        case 0:
//          self.title = Constants.Storyboard.privacyPolicyScreenTitle
            let privacyURL = "https://teak-mantis-279104.firebaseapp.com/index.html"
            if let url = URL(string: privacyURL) {
                let urlRequest = URLRequest(url: url)
                webView.load(urlRequest)
            }
        case 1:
//          self.title = Constants.Storyboard.termsScreenTitle
            let termsURL = "https://teak-mantis-279104.firebaseapp.com/terms.html"
            if let url = URL(string: termsURL) {
                let urlRequest = URLRequest(url: url)
                webView.load(urlRequest)
            }
        default:
            break
        }
    }

    func setUpNavigationBarAndItems() {
        
        // Set the screen title
        self.navigationController?.navigationBar.isTranslucent = false
        let attributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 17)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
//        self.navigationItem.title = Constants.Storyboard.privacyPolicyScreenTitle
        
        // Hide bottom toolbar
        self.navigationController?.setToolbarHidden(true, animated: true)
        
    }
    
}
