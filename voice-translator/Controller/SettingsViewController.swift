
import UIKit

import MaterialComponents
import MaterialComponents.MaterialTypographyScheme

class SettingsViewController: UIViewController {
    
//  var containerScheme = ApplicationScheme.shared.containerScheme
//  var typographyScheme = MDCTypographyScheme()
  var selectedTransFrom = ""
  var selectedTransTo   = ""
  var selectedSynthName = ""
  var selectedVoiceType = ""

  @IBOutlet weak var getStartedButton: UIButton!
    
  let translateFromView: MDCTextField = {
    let address = MDCTextField()
    address.translatesAutoresizingMaskIntoConstraints = false
    address.autocapitalizationType = .words
    return address
  }()
  var translateFromController: MDCTextInputControllerFilled!

  let translateToView: MDCTextField = {
    let city = MDCTextField()
    city.translatesAutoresizingMaskIntoConstraints = false
    city.autocapitalizationType = .words
    return city
  }()
  var translateToController: MDCTextInputControllerFilled!

  let synthNameView: MDCTextField = {
    let state = MDCTextField()
    state.translatesAutoresizingMaskIntoConstraints = false
    state.autocapitalizationType = .allCharacters
    return state
  }()
  var synthNameController: MDCTextInputControllerFilled!

  let voiceTypeView: MDCTextField = {
    let zip = MDCTextField()
    zip.translatesAutoresizingMaskIntoConstraints = false
    return zip
  }()
  var voiceTypeController: MDCTextInputControllerFilled!
  var allTextFieldControllers = [MDCTextInputControllerFilled]()
  var appBar = MDCAppBar()
  lazy var alert : UIAlertController = {
    let alert = UIAlertController(title: Constants.tokenFetchingAlertTitle, message: Constants.tokenFetchingAlertMessage, preferredStyle: .alert)
    return alert
  }()

  required init?(coder aDecoder: NSCoder) {
    translateFromController = MDCTextInputControllerFilled(textInput: translateFromView)
    translateToController = MDCTextInputControllerFilled(textInput: translateToView)
    synthNameController = MDCTextInputControllerFilled(textInput: synthNameView)
    voiceTypeController = MDCTextInputControllerFilled(textInput: voiceTypeView)
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.tintColor = .black
//    self.view.backgroundColor = ApplicationScheme.shared.colorScheme.surfaceColor
    NotificationCenter.default.addObserver(self, selector: #selector(dismissAlert), name: NSNotification.Name(Constants.tokenReceived), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(presentAlert), name: NSNotification.Name(Constants.retreivingToken), object: nil)
    setUpNavigationBarAndItems()
    setUpElements()
    if let userPreference = UserDefaults.standard.value(forKey: Constants.userLanguagePreferences) as? [String: String] {
      selectedTransFrom = userPreference[Constants.selectedTransFrom] ?? ""
      selectedTransTo = userPreference[Constants.selectedTransTo] ?? ""
      selectedSynthName = userPreference[Constants.selectedSynthName] ?? ""
      selectedVoiceType = userPreference[Constants.selectedVoiceType] ?? ""
      translateFromView.text = selectedTransFrom
      translateToView.text = selectedTransTo
      synthNameView.text = selectedSynthName
      voiceTypeView.text = selectedVoiceType
    }

    setupTextFields()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let appD = UIApplication.shared.delegate as? AppDelegate, appD.voiceLists?.isEmpty ?? true {

      presentAlert()
      appD.fetchVoiceList()
      NotificationCenter.default.addObserver(self, selector: #selector(dismissAlert), name: NSNotification.Name("FetchVoiceList"), object: nil)

    }

  }

  @objc func presentAlert() {
    //Showing the alert until token is received
    if alert.isViewLoaded == false {
      self.present(alert, animated: true, completion: nil)
    }
  }

  @objc func dismissAlert() {
    alert.dismiss(animated: true, completion: nil)
  }

  func setUpNavigationBarAndItems() {
    
    self.navigationController?.navigationBar.isTranslucent = false
    let attributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 17)!]
    UINavigationBar.appearance().titleTextAttributes = attributes
    self.title = Constants.Storyboard.settingsScreenTitle
    
  }

    func setUpElements() {
        
        // Style the UI Elements
        Utilities.styleFilledButton(getStartedButton)

    }
    
  func style(textInputController:MDCTextInputControllerFilled) {
//    textInputController.applyTheme(withScheme: containerScheme)
//    MDCContainedButtonThemer.applyScheme(ApplicationScheme.shared.buttonScheme, to: getStartedButton)
  }

  func setupTextFields() {

    view.addSubview(translateFromView)
    translateFromView.delegate = self
    translateFromController.placeholderText = Constants.translateFromPlaceholder
    allTextFieldControllers.append(translateFromController)

    view.addSubview(translateToView)
    translateToView.delegate = self
    translateToController.placeholderText = Constants.translateToPlaceholder
    allTextFieldControllers.append(translateToController)


    view.addSubview(synthNameView)
    synthNameView.delegate = self
    synthNameController.placeholderText = Constants.synthNamePlaceholder
    allTextFieldControllers.append(synthNameController)

    view.addSubview(voiceTypeView)
    voiceTypeView.delegate = self
    voiceTypeController.placeholderText = Constants.voiceTypePlaceholder
    allTextFieldControllers.append(voiceTypeController)

    var tag = 0
    for controller in allTextFieldControllers {
      guard let textField = controller.textInput as? MDCTextField else { continue }
      style(textInputController: controller);
      textField.tag = tag
      tag += 1
    }

    if selectedVoiceType == "Default" {
      voiceTypeView.textColor = .gray
    }

    let views = [ "translateFromView": translateFromView,
                  "translateToView": translateToView,
                  "synthNameView": synthNameView,
                  "voiceTypeView": voiceTypeView ]
    var constraints = NSLayoutConstraint.constraints(withVisualFormat:
      "V:[translateFromView]-[translateToView]-[synthNameView]-[voiceTypeView]",
                                                     options: [.alignAllLeading, .alignAllTrailing],
                                                     metrics: nil,
                                                     views: views)
    constraints += [NSLayoutConstraint(item: translateFromView,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: view,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: 0)]
    constraints += [NSLayoutConstraint(item: translateFromView,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: view,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: 0)]
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[translateFromView]|",
                                                  options: [],
                                                  metrics: nil,
                                                  views: views)
    constraints += [NSLayoutConstraint(item: translateFromView,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: view,
                                       attribute: .topMargin,
                                       multiplier: 1,
                                       constant: 80)]
    NSLayoutConstraint.activate(constraints)
    self.allTextFieldControllers.forEach({ (controller) in
      controller.isFloatingEnabled = true
    })
  }

  @IBAction func getStarted(_ sender: Any) {
    print("selectedTransFrom: \(selectedTransFrom)")
    print("selectedTransTo: \(selectedTransTo)")
    print("selectedVoiceType: \(selectedVoiceType)")
    print("selectedSynthName: \(selectedSynthName)")
    if selectedTransFrom.isEmpty || selectedTransTo.isEmpty ||
      selectedVoiceType.isEmpty || selectedSynthName.isEmpty {
      let alertVC = UIAlertController(title: "Infomation needed", message: "Please fill all the fields", preferredStyle: .alert)
      alertVC.addAction(UIAlertAction(title: "OK", style: .default))
      present(alertVC, animated: true)
      return

    }
    UserDefaults.standard.set([Constants.selectedTransFrom: selectedTransFrom, Constants.selectedTransTo: selectedTransTo, Constants.selectedSynthName: selectedSynthName, Constants.selectedVoiceType : selectedVoiceType], forKey: Constants.userLanguagePreferences)
    if let speechVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.speechViewController) as? SpeechViewController {
      navigationController?.pushViewController(speechVC, animated: true)
//        speechVC.modalPresentationStyle = .fullScreen
//        self.present(speechVC, animated: true, completion: nil)
    }

  }

  func thirtyOptions(optionsType: OptionsType, completionHandler: @escaping (MDCActionSheetAction) -> Void) -> MDCActionSheetController {
    let actionSheet = MDCActionSheetController(title: optionsType.getTitle(), message: optionsType.getMessage())
    for i in optionsType.getOptions(selectedTransTo: selectedTransTo) {
      let action = MDCActionSheetAction(title: i,
                                        image: nil,
                                        handler: completionHandler)
      actionSheet.addAction(action)
    }
    return actionSheet
  }

}

extension SettingsViewController: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    let index = textField.tag
    if let optionType = OptionsType(rawValue: index) {
      if optionType == .synthName || optionType == .voiceType {
        if self.selectedTransTo.isEmpty {
          self.showNoTranslateToError()
          return false
        }
      }
      let  actionSheet = thirtyOptions(optionsType: optionType, completionHandler: {action in
        switch optionType {
        case .translateFrom:
          self.selectedTransFrom = action.title
        case .translateTo:
          self.selectedTransTo = action.title
          let synthNames = OptionsType.synthName.getOptions(selectedTransTo: self.selectedTransTo)//optionType.synthName.getOptions(selectedTransTo: self.selectedTransTo)
          self.selectedSynthName = synthNames.contains("Wavenet") ? "Wavenet" : "Standard"
          self.selectedVoiceType = "Default"
          self.synthNameView.text = self.selectedSynthName
          self.voiceTypeView.text = self.selectedVoiceType
          self.voiceTypeView.textColor = .gray
        case .synthName:
          self.selectedSynthName = action.title
        case .voiceType:
          self.selectedVoiceType = action.title
          self.voiceTypeView.textColor = self.synthNameView.textColor
        }
        textField.text = action.title
      })
      present(actionSheet, animated: true, completion: nil)
    }
    return false
  }

  func showNoTranslateToError() {
    let alertVC = UIAlertController(title: "Information needed", message: "Please select translate to first", preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: "OK", style: .default))
    present(alertVC, animated: true)
  }
}

enum OptionsType: Int {
  case translateFrom = 0, translateTo, synthName, voiceType

  func getTitle() -> String {
    switch self {
    case .translateFrom:
      return "Translate from"
    case .translateTo:
      return "Translate to"
    case .synthName:
      return "Synthesis name"
    case .voiceType:
      return "Voice type"
    }
  }

  func getMessage() -> String {
    switch self {
    case .translateFrom:
      return "Choose one option for Translate from"
    case .translateTo:
      return "Choose one option for Translate to"
    case .synthName:
      return "Choose one option for Synthesis name"
    case .voiceType:
      return "Choose one option for Voice type"
    }
  }

  func getOptions(selectedTransTo: String = "") -> [String] {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let voiceList = appDelegate.voiceLists else { return [] }
    switch self {
    case .translateFrom, .translateTo:
      let from = voiceList.map { (formattedVoice) -> String in
        return formattedVoice.languageName
      }
      return from
    case .synthName:
      let synthName = voiceList.filter {
        return $0.languageName == selectedTransTo
      }
      if let synthesis = synthName.first {
        return synthesis.synthesisName
      }
      return []
    case .voiceType:
      let synthName = voiceList.filter {
        return $0.languageName == selectedTransTo
      }
      if let synthesis = synthName.first {
        return synthesis.synthesisGender
      }
      return []
    }
  }
}

