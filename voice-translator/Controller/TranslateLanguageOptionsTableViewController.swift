//
//  TranslateLanguageOptionsTableViewController.swift
//  voice-translator
//
//  Created by Hima Devisetti on 10/4/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit

class TranslateLanguageOptionsTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    weak var delegate: TranslateViewController!
    
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
//      print("Selected Option: \(selectedCell.textLabel!.text!)")
        
        //      delegate.updateTranslateFrom(fromLanguageOption: selectedCell.textLabel!.text!)
        switch index {
        case 0:
            delegate.updateTranslateFrom(fromLanguageOption: selectedCell.textLabel!.text!)
        case 1:
            delegate.updateTranslateTo(toLanguageOption: selectedCell.textLabel!.text!)
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
