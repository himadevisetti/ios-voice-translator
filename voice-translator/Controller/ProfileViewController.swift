//
//  ProfileViewController.swift
//  voice-translator
//
//  Created by Hima Devisetti on 9/30/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    var logCategory = "Profile"
    
    private let reuseIdentifier = "ProfileCell"
    var indicator = UIActivityIndicatorView(style: .large)
    
    var tableView: UITableView!
    var userInfoHeader: UserInfoHeader!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpNavigationBarAndItems()
        
        // Set up the activity indicator
        setUpActivityIndicator()
    }
    
    func setUpNavigationBarAndItems() {
        
        // Set the screen title
        self.navigationController?.navigationBar.isTranslucent = false
        let attributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 17)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.navigationItem.title = Constants.Storyboard.profileScreenTitle
        
        configureTableView()
        
    }

    func configureTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        
        tableView.register(ProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
        tableView.frame = view.frame
        
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
        userInfoHeader = UserInfoHeader(frame: frame)
        tableView.tableHeaderView = userInfoHeader
        tableView.tableFooterView = UIView()
    }
    
    // Spinning wheel processing indicator to show while waiting for the GET API's response
    func setUpActivityIndicator() {
        // Set up the activity indicator
        indicator.color = .gray
        indicator.backgroundColor = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        let safeAreaGuide = self.view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: safeAreaGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: safeAreaGuide.centerYAnchor)
        ])
    }
    
    // Call ios-checkstatus API to fetch upto 5 previously translated audio files for the current user
    func checkStatus() {
        let checkStatusUrl: String = Constants.Api.URL_BASE + Constants.Api.URL_CHECKSTATUS
        guard let url = URL(string: checkStatusUrl) else { return }
        NetworkService.sharedNetworkService.urlQueryParameters.add(value: SharedData.instance.userName!, forKey: "username")
        
        NetworkService.sharedNetworkService.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            
            DispatchQueue.main.async {
                let statusCode = results.response?.httpStatusCode
//              print("HTTP status code:", statusCode ?? 0)
                Log(self).info("HTTP status code from checkstatus API: \(statusCode ?? 0)")
                
                // Response returned from the API, disable spinning wheel and re-enable the controls on the screen
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                
                if let data = results.data {
                    let decoder = JSONDecoder()
                    var statusURL: [String]
                    if let status = try? decoder.decode([String].self, from: data) {
                        statusURL = status
                    } else if let status = try? decoder.decode(String.self, from: data) {
                        statusURL = [status]
                    }
                    else {
                        return
                    }
                    SharedData.instance.statusForUser = statusURL
                } else {
                    SharedData.instance.statusForUser = ["Could not fetch data from server"]
                }
                self.transitionToShowStatus()
            }
        }
    }
    
    // Transition to Status screen
    func transitionToShowStatus() {
        
        if let statusViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.statusViewController) as? StatusViewController {
          navigationController?.pushViewController(statusViewController, animated: true)
        }
        
    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = ProfileSection(rawValue: section) else { return 0 }
        
        switch section {
        case .Agreements: return AgreementsOptions.allCases.count
        case .Profile: return ProfileOptions.allCases.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .systemIndigo
        
        let title = UILabel()
        title.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        title.textColor = .white
        title.text = ProfileSection(rawValue: section)?.description
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ProfileCell
        
        guard let section = ProfileSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .Agreements:
            let agreements = AgreementsOptions(rawValue: indexPath.row)
            cell.textLabel?.text = agreements?.description
        case .Profile:
            let profile = ProfileOptions(rawValue: indexPath.row)
            cell.textLabel?.text = profile?.description
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = ProfileSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .Agreements:
            let agreements = AgreementsOptions(rawValue: indexPath.row)
            switch agreements {
            case .privacyPolicy:
                if let agreementsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.agreementsViewController) as? AgreementsViewController {
                    agreementsViewController.urlSwitchindex = 0 // pass this to indicate privacy URL
                    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                    navigationController?.pushViewController(agreementsViewController, animated: true)
                }
            case .termsAndConditions:
                if let agreementsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.agreementsViewController) as? AgreementsViewController {
                    agreementsViewController.urlSwitchindex = 1 // pass this to indicate terms URL
                    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                    navigationController?.pushViewController(agreementsViewController, animated: true)
                }
            default: break
            } // Switch Agreements
        case .Profile:
            let profile = ProfileOptions(rawValue: indexPath.row)
            switch profile {
            case .checkStatus:
                checkStatus()
                indicator.startAnimating()
        //      checkStatusButton.isUserInteractionEnabled = false
            case .logOut:
                let firebaseAuth = Auth.auth()
                do {
                  try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                    // Send this to logs
//                  print(signOutError.localizedDescription)
                    Log(self).info("Error while signing out the user from firebase: \(signOutError.localizedDescription)")
                }
                if let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.loginViewController) as? LoginViewController {
                  navigationController?.pushViewController(loginViewController, animated: true)
                }
            default: break
            } // Switch Profile
        } // Switch Section
        
        // To deselect the row after the action is performed
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
