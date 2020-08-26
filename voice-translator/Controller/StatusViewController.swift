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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
        
    }
    
    func setUpElements() {
        
       stackViewToShowFiles.alignment = .fill
       stackViewToShowFiles.distribution = .fillEqually
       stackViewToShowFiles.spacing = 16.0
        
        // Style the elements
        let filenamesArray = SharedData.instance.statusForUser!
        print("Printing file names array: \(filenamesArray)")
        
        var labelAdded = false;
        for file in filenamesArray {
            print("File: \(file)")
            if file.hasPrefix("https") {
                
                if !labelAdded {
                    setUpLabel("Your translated files")
                    labelAdded = true; 
                }
                
                let url = URL(string: file)!
                let filename = url.lastPathComponent
                print("File name: \(filename)")
                button = setUpButton(filename)
                
                // Add the Button to Stack View
                stackViewToShowFiles.addArrangedSubview(button!)
                
            } else if file.hasPrefix("No files") {
                setUpLabel(file)
            } else if file.hasPrefix("No result") {
                setUpLabel(file)
            } else {
                //  messageString = "Could not fetch data from server"
                setUpLabel(file)
            }
        }
        
    }
    
    func setUpLabel(_ message:String) {
        
        // Set up Text Label
        textLabel = UILabel()
        textLabel!.backgroundColor = UIColor.white
        textLabel!.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        textLabel!.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        textLabel!.textAlignment = .center
        textLabel!.text = message
        
        // Add the Text Label to Stack View
        stackViewToShowFiles.addArrangedSubview(textLabel!)
        
    }
    
    func setUpButton(_ title: String) -> UIButton {
        
        // Set up Button
        button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        button!.center.x = self.view.center.x // for horizontal center
        button!.setTitle(title, for: .normal)
        button!.setBackgroundImage(UIImage(systemName: "play.rectangle.fill"), for: .normal)
        button!.tintColor = .red
        button!.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        return button!
        
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Play button tapped")
        player!.play()
    }
    
}
