//
//  LanguageOptionsTableViewController.swift
//  voice-translator
//
//  Created by Hima Devisetti on 9/25/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit

class LanguageOptionsTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    weak var delegate: SettingsViewController!
    
    var index = 0
    var selectedTransTo: String? 
    var optionType: OptionsType?
    var optionTypeStr: String?
    
    var data: [String]!
    var filteredData: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBarAndItems()
        
        optionType = OptionsType(rawValue: index)
        
        switch index {
        case 0:
            optionTypeStr = ".translateFrom"
            self.title = "Select Translate from Language"
        case 1:
            optionTypeStr = ".translateTo"
            self.title = "Select Translate to Language"
        case 2:
            optionTypeStr = selectedTransTo // pass the value selected for 'Translated To' option
            self.title = "Select Text-To-Speech Tech"
            searchBar.isHidden = true
            tableView.contentInset = UIEdgeInsets(top: -searchBar.bounds.height, left: 0, bottom: 0, right: 0)
        case 3:
            optionTypeStr = selectedTransTo // pass the value selected for 'Translated To' option
            self.title = "Select a voice"
            searchBar.isHidden = true
            tableView.contentInset = UIEdgeInsets(top: -searchBar.bounds.height, left: 0, bottom: 0, right: 0)
        default:
            optionTypeStr = "No such option"
        }
        
        data = optionType!.getOptions(selectedTransTo: optionTypeStr!)
        
        searchBar.delegate = self
        filteredData = data
    }
    
    func setUpNavigationBarAndItems() {
        
        // Set the screen title
        self.navigationController?.navigationBar.isTranslucent = false
        let attributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 17)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        // Customize the back button to show an 'X' and remove title
        //      let imageSize = CGSize(width: 22.0, height: 22.0)
        //      let backButtonImage = UIImage(systemName: "multiply")!.resize(targetSize: imageSize).imageWithInset(insets: UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0))
        //      self.navigationController?.navigationBar.backIndicatorImage = backButtonImage
        //      self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButtonImage
        // No title
        //      self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Hide bottom toolbar
        self.navigationController?.setToolbarHidden(true, animated: true)
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        print("Count of options: \(data.count)")
        return filteredData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageOptionCell")! as UITableViewCell
        
        cell.textLabel?.text = filteredData[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        print("Selected Option: \(selectedCell.textLabel!.text!)")
        
        //      delegate.updateTranslateFrom(fromLanguageOption: selectedCell.textLabel!.text!)
        switch index {
        case 0:
            delegate.updateTranslateFrom(fromLanguageOption: selectedCell.textLabel!.text!)
        case 1:
            delegate.updateTranslateTo(toLanguageOption: selectedCell.textLabel!.text!)
        case 2:
            delegate.updateSynthName(synthNameOption: selectedCell.textLabel!.text!)
        case 3:
            delegate.updateVoiceType(voiceTypeOption: selectedCell.textLabel!.text!)
        default:
            optionTypeStr = "No such option"
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Search bar configuration
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredData = []
        
        if searchText == "" {
            filteredData = data
        } else {
            for languageOption in data {
                if languageOption.lowercased().contains(searchText.lowercased()) {
                    filteredData.append(languageOption)
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
}
