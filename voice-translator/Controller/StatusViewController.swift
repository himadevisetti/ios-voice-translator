//
//  StatusViewController.swift
//  voice-translator
//
//  Created by user178116 on 8/24/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import AVFoundation

class StatusViewController: UIViewController {
    
    @IBOutlet weak var stackViewToShowFiles: UIStackView!
    
    var messageString: String?
    var textLabel: UILabel?
    var buttonTitle: String?
    var button: UIButton?
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    //Define you tuple to hold player attributes
    typealias Player = (button: UIButton, url: URL, playerItem: AVPlayerItem)
    var playerDictionary = [String: Player]()
    var playerValues: Player?
    let pauseButtonImage = Utilities.resizeImage(image: UIImage(systemName: "pause.rectangle.fill")!, targetSize: CGSize(width: 70.0, height: 50.0))
    let playButtonImage = Utilities.resizeImage(image: UIImage(systemName: "play.rectangle.fill")!, targetSize: CGSize(width: 70.0, height: 50.0))

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpNavigationBarAndItems()
        setUpElements()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUpNavigationBarAndItems() {
        
        // Set the screen title
        self.navigationController?.navigationBar.isTranslucent = false
        let attributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 17)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.navigationItem.title = Constants.Storyboard.statusScreenTitle
        
        // Hide the back button to avoid navigating back to upload screen
        self.navigationItem.hidesBackButton = true
        
        // Add home button to navigation bar on the right-side
        let homeButton = UIBarButtonItem(image: UIImage(systemName: "house")!.withRenderingMode(.alwaysOriginal),
                                      style: .plain, target: self, action: #selector(homeButtonTapped))
        self.navigationItem.rightBarButtonItem  = homeButton
        
    }
    
    func setUpElements() {
        
        stackViewToShowFiles.spacing = 20.0
        stackViewToShowFiles.alignment = .leading
//      stackViewToShowFiles.distribution = .fill
        
        // Style the elements
        let fileUrlsArray = SharedData.instance.statusForUser!
//      print("File names array: \(fileUrlsArray)")
        
        let fileCount = fileUrlsArray.count
//      print("File count: \(fileCount)")
        
        // Array to hold filenames (filename is the last part of the URL)
        var fileNamesArray:[String] = []
        
        var buttonValuesArray:[UIButton] = []
        var urlValuesArray:[URL] = []
        var playerItemValuesArray:[AVPlayerItem] = []
        
        var labelAdded = false;
        
        // Get the first item of the fileUrlsArray
        var file = fileUrlsArray[0]
//      print("File: \(file)")
        
        // ios-checkstatus API returned files
        if file.hasPrefix("https") {
            
            if !labelAdded {
                setUpMultilineLabel("Your translated files")
                labelAdded = true;
            }
            
            // When there is more than one file
            if fileCount > 1 {
                
                // Create urls, playerItems and buttons to add them to the respective dictionaries
                var count = 0
                while count < fileCount {
                    
                    file = fileUrlsArray[count]
                    
                    // Ignore the files under processing
                    if file.hasPrefix("https") {
                        // There is more than one file (upto 5 files could be returned by the ios-checkstatus API)
                        // urlNamesArray will have items such as url1, url2 .. upto url5
                        // Create URLs using the file URLs and append them to urlValuesArray
                        let url = URL(string: file)!
                        urlValuesArray.append(url)
                        
                        // playerItemNamesArray will have items such as playerItem1, playerItem2 .. upto playerItem5
                        // Create playerItems using the URLs and append them to playerItemValuesArray
                        playerItem = AVPlayerItem(url: url)
                        playerItemValuesArray.append(playerItem!)
                        
                        // filename is the last part of the URL
                        // Get filename and append it to fileNamesArray
                        let filename = url.lastPathComponent
    //                  print("File name: \(filename)")
                        fileNamesArray.append(filename)
                        
                        // buttonnamesArray will have items such as button1, button2 .. upto button5
                        // Create UIButtons with filename as the title and append them to buttonValuesArray
                        button = setUpButton(filename)
                        buttonValuesArray.append(button!)
                    }
                    // Increment loop control counter
                    count += 1
                } // end of while count < fileCount
                
                for index in 0..<urlValuesArray.count {
                    playerDictionary[fileNamesArray[index]] = Player(button: buttonValuesArray[index], url: urlValuesArray[index], playerItem: playerItemValuesArray[index])
                }
                
            } else {
                
                // At this point, there's only one file; Create one url, playerItem each and add item to the player
                // Add player to the playerLayer and add playerLayer to the UI view
                // Get mp3 filename and create a button using filename as title
                // Add button to the vertical stack view
                let url = URL(string: file)!
                
                playerItem = AVPlayerItem(url: url)
                player = AVPlayer(playerItem: playerItem!)
                let playerLayer = AVPlayerLayer(player: player!)
                playerLayer.frame = self.view.bounds
                self.view.layer.addSublayer(playerLayer)
                
                let filename = url.lastPathComponent
//              print("File name: \(filename)")
                button = setUpButtonSingle(filename)
                
                // Populate playerValues object to act upon finished playing notification
                playerValues = Player(button: button!, url: url, playerItem: playerItem!)
                
                // Add the Button to Stack View
                // stackViewToShowFiles.addArrangedSubview(button!)
            }
            
        } else if file.hasPrefix("No files") {
            
            // ios-checkstatus API returned "No files were submitted for translation. Please upload a file by clicking translate button. In case you have just submitted a file, please give it a few minutes"
            setUpLabel(file)
            
        } else if file.hasPrefix("No result") {
            
            // ios-checkstatus API returned "No result returned from DB: " + err.message
            setUpLabel(file)
        } else {
            
            //  Could not fetch data from server
            setUpLabel(file)
        }
        
        setUpEmptyLabel()
        stackViewToShowFiles.layoutIfNeeded()
//      print("Stack view height after adding all the elements: \(stackViewToShowFiles.frame.height)") // new height
//      stackViewToShowFiles.heightAnchor.constraint(equalToConstant: stackViewToShowFiles.frame.height).isActive = true
        
    }
    
    func setUpMultilineLabel(_ message:String) {
        
        // Set up Text Label
        textLabel = UILabel()
        textLabel!.backgroundColor = UIColor.white
        textLabel!.widthAnchor.constraint(equalToConstant: self.stackViewToShowFiles.frame.width).isActive = true
        textLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        textLabel!.textAlignment = .center
        textLabel!.text = message
        textLabel!.lineBreakMode = .byWordWrapping
        textLabel!.numberOfLines = 0;
//      textLabel!.sizeToFit()
//      textLabel!.layoutIfNeeded()
        
        // Add the Text Label to Stack View
        stackViewToShowFiles.addArrangedSubview(textLabel!)
        
    }
    
    func setUpLabel(_ message:String) {
        
        // Set up Text Label
        textLabel = UILabel()
        textLabel!.backgroundColor = UIColor.white
        textLabel!.widthAnchor.constraint(equalToConstant: self.stackViewToShowFiles.frame.width).isActive = true
//      textLabel!.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
//      textLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        textLabel!.font = UIFont(name: "Avenir Next", size: 14)
//      textLabel!.sizeToFit()
//      textLabel!.layoutIfNeeded()
        textLabel!.text = message
        textLabel!.lineBreakMode = .byWordWrapping
        textLabel!.numberOfLines = 0;
        
        // Add the Text Label to Stack View
        stackViewToShowFiles.addArrangedSubview(textLabel!)
        
    }
    
    func setUpEmptyLabel() {
        
        // Set up Text Label
        textLabel = UILabel()
        textLabel!.backgroundColor = UIColor.white
        textLabel!.widthAnchor.constraint(equalToConstant: self.stackViewToShowFiles.frame.width).isActive = true
//      textLabel!.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
//      textLabel!.sizeToFit()
//      textLabel!.layoutIfNeeded()
        textLabel!.numberOfLines = 1;
        
        // Add the Text Label to Stack View
        stackViewToShowFiles.addArrangedSubview(textLabel!)
        
    }
    
    func setUpButtonSingle(_ title: String) -> UIButton {
        
        // Set up Button
        button = UIButton(type: .system)
        button!.setTitle(title, for: .normal)
        button!.setTitleColor(.black, for: .normal)
        button!.titleLabel?.font =  UIFont(name: "Avenir Next", size: 14)
        button!.titleLabel?.numberOfLines = 0; // Dynamic number of lines
        button!.titleLabel?.lineBreakMode = .byWordWrapping;
        button!.setImage(playButtonImage, for: .normal)
        button!.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button!.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        button!.tintColor = .red
        button!.addTarget(self, action: #selector(buttonActionSingle), for: .touchUpInside)
        let rightSwipeButton = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeButtonActionSingle))
        button!.addGestureRecognizer(rightSwipeButton)
        
//      button!.sizeToFit()
//      button!.layoutIfNeeded()
        
        // Add the Button to Stack View
        stackViewToShowFiles.addArrangedSubview(button!)
        
        return button!
        
    }
    
    @objc func buttonActionSingle(sender: UIButton!) {
        if player?.rate == 0
        {
            player!.play()
            sender.setImage(pauseButtonImage, for: .normal)
        } else {
            player!.pause()
            sender.setImage(playButtonImage, for: .normal)
        }
    }
    
    @objc func rightSwipeButtonActionSingle(recognizer: UITapGestureRecognizer) {

        let swipedButton = recognizer.view as! UIButton
        let buttonTitle = swipedButton.titleLabel!.text!
        print("Button to be deleted: \(buttonTitle)")
        let deleteURL = playerValues?.url
//      print("URL to be deleted: \(deleteURL!.absoluteString)")
        showDeleteAlertSingle(deleteURL!.absoluteString)
    }
    
    func showDeleteAlertSingle(_ deleteURLString: String) {
        let alert = UIAlertController(title: "Delete the File?", message: "", preferredStyle: .alert)
        let yesButton = UIAlertAction(title: "Yes", style: .default, handler: {(_ action: UIAlertAction) -> Void in
//          print("you pressed 'Yes' button")
            // Call deleteFile API
            self.deleteFile(deleteURLString)
            
            // Remove all subviews from the stackview because there are no more translated files for this user
            while let first = self.stackViewToShowFiles.arrangedSubviews.first {
                self.stackViewToShowFiles.removeArrangedSubview(first)
                    first.removeFromSuperview()
            }
            
            // Add label to the stackView to show status
            self.setUpEmptyLabel()
            self.setUpLabel("There are no translated files for you at this time")
            self.setUpEmptyLabel()
        })
        let noButton = UIAlertAction(title: "No", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("You pressed 'No' button")
        })
        alert.addAction(yesButton)
        alert.addAction(noButton)
        present(alert, animated: true, completion: nil)
    }
    
    func setUpButton(_ title: String) -> UIButton {
        
        // Set up Button
        button = UIButton(type: .system)
        button!.setTitle(title, for: .normal)
        button!.setTitleColor(.black, for: .normal)
        button!.titleLabel?.font =  UIFont(name: "Avenir Next", size: 14)
        button!.titleLabel?.numberOfLines = 0; // Dynamic number of lines
        button!.titleLabel?.lineBreakMode = .byWordWrapping;
        button!.setImage(playButtonImage, for: .normal)
        button!.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button!.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        button!.tintColor = .red
        button!.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        let rightSwipeButton = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeButtonAction))
        button!.addGestureRecognizer(rightSwipeButton)
        
//      button!.sizeToFit()
//      button!.layoutIfNeeded()
        
        // Add the Button to Stack View
        stackViewToShowFiles.addArrangedSubview(button!)
        
        return button!
        
    }
    
    @objc func buttonAction(sender: UIButton!) {
        let buttonPressedByUser = sender.titleLabel!.text
//      print("Button pressed by user: \(String(describing: buttonPressedByUser))")
        
        // Load first audio into the player
        if playerValues == nil {
            // Get the url that corresponds to the button pressed by the user
            playerValues = playerDictionary[buttonPressedByUser!]
            
//          print("************* Testing ***************")
//          print("Button pressed by user is: \(String(describing: playerValues?.button.titleLabel?.text))")
//          print("Url corresponding to the button pressed: \(String(describing: playerValues?.url))")
//          print("Duration of the player item: \(String(describing: playerValues?.playerItem.duration))")
//          print("************* Testing ***************")
            
            playerItem = AVPlayerItem(url: playerValues!.url)
            player = AVPlayer(playerItem: playerItem)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.bounds
            self.view.layer.addSublayer(playerLayer)
        } else {
            // Load another audio into the player
//          print("Currently playing button value is: \(String(describing: playerValues?.button.titleLabel?.text))")
//          print("Current playing rate: \(player!.rate)")
            if buttonPressedByUser != playerValues?.button.titleLabel!.text {
                
                // Reset player rate to 0 and change the button image in case something was playing
                player!.rate = 0
                playerValues?.button.setImage(playButtonImage, for: .normal)
                
                // Get the url that corresponds to the button pressed by the user
                playerValues = playerDictionary[buttonPressedByUser!]
                
                playerItem = AVPlayerItem(url: playerValues!.url)
                player = AVPlayer(playerItem: playerItem)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = self.view.bounds
                self.view.layer.addSublayer(playerLayer)
            }
        }
        
        // Current audio is not playing
        if player!.rate == 0
        {
            player!.play()
            playerValues?.button.setImage(pauseButtonImage, for: .normal)
        } else {
            // Pause button tapped on the currently playing audio
            player!.pause()
            playerValues?.button.setImage(playButtonImage, for: .normal)
        }
        
    }
    
    @objc func rightSwipeButtonAction(recognizer: UITapGestureRecognizer) {

        let swipedButton = recognizer.view as! UIButton
        let buttonTitle = swipedButton.titleLabel!.text!
//      print("Button to be deleted: \(buttonTitle)")
        playerValues = playerDictionary[buttonTitle]
        let deleteURL = playerValues?.url
//      print("URL to be deleted: \(deleteURL!.absoluteString)")
        showDeleteAlert(deleteURL!.absoluteString, swipedButton)
    }
    
    func showDeleteAlert(_ deleteURLString: String, _ swipedButton: UIButton) {
        let alert = UIAlertController(title: "Delete the File?", message: "", preferredStyle: .alert)
        let yesButton = UIAlertAction(title: "Yes", style: .default, handler: {(_ action: UIAlertAction) -> Void in
//          print("you pressed 'Yes' button")
            // Call deleteFile API
            self.deleteFile(deleteURLString)
            
            // Remove deleted item from the displayed items list
            if let buttonIndex = self.stackViewToShowFiles.arrangedSubviews.firstIndex(of: swipedButton) {
//              print("Index of the button to be removed: \(buttonIndex)")
                self.stackViewToShowFiles.arrangedSubviews[buttonIndex].removeFromSuperview()
            }
            
        })
        let noButton = UIAlertAction(title: "No", style: .default, handler: {(_ action: UIAlertAction) -> Void in
//          print("You pressed 'No' button")
            if let buttonIndex = self.stackViewToShowFiles.arrangedSubviews.firstIndex(of: swipedButton) {
                print("Index of the button to be removed: \(buttonIndex)")
            }
        })
        alert.addAction(yesButton)
        alert.addAction(noButton)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func finishedPlaying(myNotification:NSNotification) {
        playerValues?.button.setImage(playButtonImage, for: .normal)
        let stoppedPlayerItem = myNotification.object as! AVPlayerItem
        stoppedPlayerItem.seek(to: CMTime.zero, completionHandler: nil)
    }
    
    // Call ios-deletefile API to delete translated audio file for the current user
    func deleteFile(_ urlString: String) {
        let deleteFileUrl: String = Constants.Api.URL_BASE + Constants.Api.URL_DELETEFILE
        guard let url = URL(string: deleteFileUrl) else { return }
        NetworkService.sharedNetworkService.urlQueryParameters.add(value: urlString, forKey: "urlstring")
        NetworkService.sharedNetworkService.urlQueryParameters.add(value: SharedData.instance.userName!, forKey: "username")
        
        var statusCode: Int?
        NetworkService.sharedNetworkService.makeRequest(toURL: url, withHttpMethod: .delete) { (results) in
            
            DispatchQueue.main.async {
                statusCode = results.response?.httpStatusCode
                print("HTTP status code:", statusCode ?? 0)
                SharedData.instance.statusCode = statusCode
            }
        }
    }
    
    @IBAction func homeButtonTapped(_ sender: Any) {
        
        if let landingViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.landingViewController) as? LandingViewController {
          navigationController?.pushViewController(landingViewController, animated: true)
        }
        
    }
    
}
