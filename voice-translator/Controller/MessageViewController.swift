//
//  MessageViewController.swift
//  voice-translator
//
//  Created by user178116 on 8/23/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import AVFoundation

class MessageViewController: UIViewController {
    
    @IBOutlet weak var messageView: UIStackView!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    let viewStatusUrl: String = Constants.Storyboard.URL_BASE + Constants.Storyboard.URL_VIEWSTATUS
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var button: UIButton?
    
    let playButtonImage = Utilities.resizeImage(image: UIImage(systemName: "play.rectangle.fill")!, targetSize: CGSize(width: 70.0, height: 50.0))
    let pauseButtonImage = Utilities.resizeImage(image: UIImage(systemName: "pause.rectangle.fill")!, targetSize: CGSize(width: 70.0, height: 50.0))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
        getStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUpElements() {
        
        // Style the UI Elements
        // Add spinning wheel and disable the controls on the screen to show processing
        activityIndicator()
        indicator.startAnimating()
        indicator.backgroundColor = .white
        homeButton.isUserInteractionEnabled = false
        logoutButton.isUserInteractionEnabled = false
    }
    
    func getStatus() {
        guard let url = URL(string: viewStatusUrl) else { return }
        NetworkService.sharedNetworkService.urlQueryParameters.add(value: SharedData.instance.userName!, forKey: "username")
        NetworkService.sharedNetworkService.urlQueryParameters.add(value: SharedData.instance.fileName!, forKey: "filename")
        
        NetworkService.sharedNetworkService.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            
            DispatchQueue.main.async {
                let statusCode = results.response?.httpStatusCode
                print("HTTP status code:", statusCode ?? 0)
                
                // Response returned from the API, disable spinning wheel and re-enable the controls on the screen
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                self.homeButton.isUserInteractionEnabled = true
                self.logoutButton.isUserInteractionEnabled = true
                
                if let data = results.data {
                    let decoder = JSONDecoder()
                    guard let status = try? decoder.decode(String.self, from: data) else { return }
                    let statusURL = status.description
//                  print(status.description)
                    
                    if statusURL.hasPrefix("https") {
                        
                        // Spacing between the UI elements (label and button) in the stack view
                        self.messageView.spacing = 16.0
                        
                        // GET call returned atleast one URL, display the label
                        let textLabel = UILabel()
                        textLabel.backgroundColor = UIColor.white
                        textLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
                        textLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
                        textLabel.textAlignment = .center
                        textLabel.text = "Your translated file"
                        self.messageView.addArrangedSubview(textLabel)
                        
                        let url = URL(string: statusURL)
                        self.playerItem = AVPlayerItem(url: url!)
                        self.player = AVPlayer(playerItem: self.playerItem!)
                        let playerLayer = AVPlayerLayer(player: self.player!)
                        playerLayer.frame = self.view.bounds
                        self.view.layer.addSublayer(playerLayer)
                        
                        // Button to display the translated file so the user could play it
                        self.button = UIButton(type: .system)
                        self.button!.setTitle(url!.lastPathComponent, for: .normal)
                        self.button!.setTitleColor(.black, for: .normal)
                        self.button!.titleLabel?.font =  UIFont(name: "Avenir Next", size: 14)
                        self.button!.titleLabel?.numberOfLines = 0; // Dynamic number of lines
                        self.button!.titleLabel?.lineBreakMode = .byWordWrapping;
                        let image = Utilities.resizeImage(image: UIImage(systemName: "play.rectangle.fill")!, targetSize: CGSize(width: 70.0, height: 50.0))
                        self.button!.setImage(image, for: .normal)
                        self.button!.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
                        self.button!.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
                        self.button!.tintColor = .red
                        self.button!.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
                        self.messageView.addArrangedSubview(self.button!)
                        
                    } else {
                        
                        // Uploaded file is currently being processed
                        let textLabel = UILabel()
                        textLabel.backgroundColor = UIColor.white
//                        textLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
                        textLabel.font = UIFont(name: "Avenir Next", size: 14)
                        textLabel.text = statusURL
                        textLabel.lineBreakMode = .byWordWrapping
                        textLabel.numberOfLines = 0;
                        textLabel.text = statusURL
                        self.messageView.addArrangedSubview(textLabel)
                    }
                }
            }
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        if player?.rate == 0
        {
            // playing the audio
            player!.play()
            button!.setImage(pauseButtonImage, for: .normal)
        } else {
            // paused the audio
            player!.pause()
            button!.setImage(playButtonImage, for: .normal)
        }
    }
    
    @objc func finishedPlaying(myNotification:NSNotification) {
        button!.setImage(playButtonImage, for: .normal)
        let stoppedPlayerItem = myNotification.object as! AVPlayerItem
        stoppedPlayerItem.seek(to: CMTime.zero, completionHandler: nil)
    }
    
    
    var indicator = UIActivityIndicatorView()
    
    // Spinning wheel processing indicator to show while waiting for the GET API's response
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    // Currently not using this fucntion. Playing the file directly from Google cloud storage bucket
    func downloadAndSaveAudioFile(_ audioFile: String, completion: @escaping (String) -> Void) {
        
        //Create directory if not present
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectory = paths.first! as NSString
        let soundDirPathString = documentDirectory.appendingPathComponent("Sounds")
        
        do {
            try FileManager.default.createDirectory(atPath: soundDirPathString, withIntermediateDirectories: true, attributes:nil)
//          print("directory created at \(soundDirPathString)")
        } catch let error as NSError {
            print("error while creating dir : \(error.localizedDescription)");
        }
        
        if let audioUrl = URL(string: audioFile) {
            // create your document folder url
            let documentsUrl =  FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first! as URL
            let documentsFolderUrl = documentsUrl.appendingPathComponent("Sounds")
            // your destination file url
            let destinationUrl = documentsFolderUrl.appendingPathComponent(audioUrl.lastPathComponent)
//          print(destinationUrl)
            // check if it exists before downloading it
            if FileManager().fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                completion(destinationUrl.absoluteString)
            } else {
                //  if the file doesn't exist
                //  just download the data from your url
                DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
                    if let myAudioDataFromUrl = try? Data(contentsOf: audioUrl){
                        // after downloading your data you need to save it to your destination url
                        if (try? myAudioDataFromUrl.write(to: destinationUrl, options: [.atomic])) != nil {
                            print("file saved at \(destinationUrl)")
                            completion(destinationUrl.absoluteString)
                        } else {
                            print("error saving file")
                            completion("")
                        }
                    }
                })
            }
        }
    }
    
    
}
