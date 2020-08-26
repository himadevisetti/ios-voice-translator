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
    
    @IBOutlet weak var messageText: UITextField!
    
    let viewStatusUrl: String = Constants.Storyboard.URL_BASE + Constants.Storyboard.URL_VIEWSTATUS
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var button: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
        getStatus()
    }
    
    func setUpElements() {
        
        // Style the UI Elements
        Utilities.styleTextFieldNoBorder(messageText)
        // messageText.text = "Checking status"
        // messageText.text = "Your file is currently being processed. Please check status after a few minutes from Home screen"
    }
    
    func getStatus() {
        guard let url = URL(string: viewStatusUrl) else { return }
        NetworkService.sharedNetworkService.urlQueryParameters.add(value: SharedData.instance.userName!, forKey: "username")
        NetworkService.sharedNetworkService.urlQueryParameters.add(value: SharedData.instance.fileName!, forKey: "filename")
        
        NetworkService.sharedNetworkService.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            
            DispatchQueue.main.async {
                let statusCode = results.response?.httpStatusCode
                print("HTTP status code:", statusCode ?? 0)
                
                if let data = results.data {
                    print("Data returned by the server is: \(data)")
                    let decoder = JSONDecoder()
                    guard let status = try? decoder.decode(String.self, from: data) else { return }
                    let statusURL = status.description
                    print(status.description)
                    if statusURL.hasPrefix("https") {
                        self.messageText.textAlignment = .center
                        self.messageText.text = "Your translated file"
                        let url = URL(string: statusURL)
                        print("the url = \(url!)")
                        self.playerItem = AVPlayerItem(url: url!)
                        self.player = AVPlayer(playerItem: self.playerItem!)
                        let playerLayer = AVPlayerLayer(player: self.player!)
                        playerLayer.frame = self.view.bounds
                        self.view.layer.addSublayer(playerLayer)
                        self.button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
                        self.button!.center.x = self.view.center.x // for horizontal center
                        self.button!.setTitle(url!.lastPathComponent, for: .normal)
                        self.button!.setBackgroundImage(UIImage(systemName: "play.rectangle.fill"), for: .normal)
                        self.button!.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
                        self.view.addSubview(self.button!)
                        
//                        self.downloadAndSaveAudioFile(statusURL) { (savedLocation) in
//                            print("Saved at \(savedLocation)")
//                           // self.messageText.text = savedLocation
//                            do {
//                                self.player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: savedLocation))
//                            } catch {
//                                print(error)
//                            }
//                            let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
//                            button.center.x = self.view.center.x // for horizontal center
//                            button.setTitle(url.lastPathComponent, for: .normal)
//                            button.setBackgroundImage(UIImage(systemName: "play.rectangle.fill"), for: .normal)
//                            button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
//                            self.messageText.text = "Your translated file"
//                            self.view.addSubview(button)
//                        }
                    } else {
                        self.messageText.text = statusURL
                    }
                }
            }
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
      print("Play button tapped")
      if player?.rate == 0
        {
            player!.play()
            //button!.setImage(UIImage(named: "player_control_pause_50px.png"), forState: UIControlState.Normal)
            button!.setTitle("Pause", for: UIControl.State.normal)
        } else {
            player!.pause()
            //button!.setImage(UIImage(named: "player_control_play_50px.png"), forState: UIControlState.Normal)
            button!.setTitle("Play", for: UIControl.State.normal)
        }
    }
    
    func downloadAndSaveAudioFile(_ audioFile: String, completion: @escaping (String) -> Void) {
        
        //Create directory if not present
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectory = paths.first! as NSString
        let soundDirPathString = documentDirectory.appendingPathComponent("Sounds")
        
        do {
            try FileManager.default.createDirectory(atPath: soundDirPathString, withIntermediateDirectories: true, attributes:nil)
            print("directory created at \(soundDirPathString)")
        } catch let error as NSError {
            print("error while creating dir : \(error.localizedDescription)");
        }
        
        if let audioUrl = URL(string: audioFile) {
            // create your document folder url
            let documentsUrl =  FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first! as URL
            let documentsFolderUrl = documentsUrl.appendingPathComponent("Sounds")
            // your destination file url
            let destinationUrl = documentsFolderUrl.appendingPathComponent(audioUrl.lastPathComponent)
            
            print(destinationUrl)
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
