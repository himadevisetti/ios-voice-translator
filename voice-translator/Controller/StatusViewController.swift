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
        setUpElements()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUpElements() {
        
        stackViewToShowFiles.spacing = 20.0
        stackViewToShowFiles.alignment = .leading
        
        // Style the elements
        let fileUrlsArray = SharedData.instance.statusForUser!
        print("File names array: \(fileUrlsArray)")
        
        let fileCount = fileUrlsArray.count
        print("File count: \(fileCount)")
        
        // Array to hold filenames (filename is the last part of the URL)
        var fileNamesArray:[String] = []
        
        var buttonValuesArray:[UIButton] = []
        var urlValuesArray:[URL] = []
        var playerItemValuesArray:[AVPlayerItem] = []
        
        var labelAdded = false;
        
        // Get the first item of the fileUrlsArray
        var file = fileUrlsArray[0]
        print("File: \(file)")
        
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
                    print("File name: \(filename)")
                    fileNamesArray.append(filename)
                    
                    // buttonnamesArray will have items such as button1, button2 .. upto button5
                    // Create UIButtons with filename as the title and append them to buttonValuesArray
                    button = setUpButton(filename)
                    buttonValuesArray.append(button!)
                    
                    // Increment loop control counter
                    count += 1
                } // end of while count < fileCount
                
                for index in 0..<fileCount {
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
                print("File name: \(filename)")
                button = setUpButtonSingle(filename)
                
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
        
        stackViewToShowFiles.layoutIfNeeded()
        print("Stack view height after adding all the elements: \(stackViewToShowFiles.frame.height)") // new height
        setUpEmptyLabel()
        
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
        
        // Add the Text Label to Stack View
        stackViewToShowFiles.addArrangedSubview(textLabel!)
        
    }
    
    func setUpLabel(_ message:String) {
        
        // Set up Text Label
        textLabel = UILabel()
        textLabel!.backgroundColor = UIColor.white
        textLabel!.widthAnchor.constraint(equalToConstant: self.stackViewToShowFiles.frame.width).isActive = true
//      textLabel!.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        textLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
//      textLabel!.sizeToFit()
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
        
        // Add the Button to Stack View
        stackViewToShowFiles.addArrangedSubview(button!)
        
        return button!
        
    }
    
    @objc func buttonActionSingle(sender: UIButton!) {
        print("Play button tapped")
        
        if player?.rate == 0
        {
            player!.play()
            sender.setImage(pauseButtonImage, for: .normal)
        } else {
            player!.pause()
            sender.setImage(playButtonImage, for: .normal)
        }
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
        
        // Add the Button to Stack View
        stackViewToShowFiles.addArrangedSubview(button!)
        
        return button!
        
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Play button tapped")
        let buttonPressedByUser = sender.titleLabel!.text
        print("Button pressed by user: \(String(describing: buttonPressedByUser))")
        
        // Load first audio into the player
        if playerValues == nil {
            // Get the url that corresponds to the button pressed by the user
            playerValues = playerDictionary[buttonPressedByUser!]
            
            print("************* Testing ***************")
            print("Button pressed by user is: \(String(describing: playerValues?.button.titleLabel?.text))")
            print("Url corresponding to the button pressed: \(String(describing: playerValues?.url))")
            print("Duration of the player item: \(String(describing: playerValues?.playerItem.duration))")
            print("************* Testing ***************")
            
            playerItem = AVPlayerItem(url: playerValues!.url)
            player = AVPlayer(playerItem: playerItem)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.bounds
            self.view.layer.addSublayer(playerLayer)
        } else {
            // Load another audio into the player
            print("Currently playing button value is: \(String(describing: playerValues?.button.titleLabel?.text))")
            print("Current playing rate: \(player!.rate)")
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
    
    @objc func finishedPlaying(myNotification:NSNotification) {
        //button!.setImage(UIImage(named: "player_control_play_50px.png"), forState: UIControlState.Normal)
        playerValues?.button.setImage(playButtonImage, for: .normal)
        let stoppedPlayerItem = myNotification.object as! AVPlayerItem
        stoppedPlayerItem.seek(to: CMTime.zero, completionHandler: nil)
    }
    
}
