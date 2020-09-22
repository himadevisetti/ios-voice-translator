//
//  Utilities.swift
//  voice-translator
//
//  Created by user178116 on 8/17/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import Foundation
import UIKit
import CryptoKit
import Firebase

class Utilities {
    
    static func styleTextField(_ textField:UITextField) {
        
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 2)
        // bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        // bottomLine.backgroundColor = UIColor.init(red: 30/255, green: 144/255, blue: 255/255, alpha: 1).cgColor
        bottomLine.backgroundColor = UIColor.systemIndigo.cgColor
        textField.borderStyle = .none
        
        textField.layer.addSublayer(bottomLine)
        
    }
    
    static func styleTextFieldNoBorder(_ textField:UITextField) {
        
        textField.borderStyle = .none
        
    }
    
    static func styleFilledButton(_ button:UIButton) {
        
        button.backgroundColor = UIColor.systemIndigo
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
        
    }
    
    static func styleFilledLeftButton(_ button:UIButton) {
        
        button.roundedLeftButton()
        
    }
    
    static func styleFilledRightButton(_ button:UIButton) {
        
        button.roundedRightButton()
        
    }
    
    static func styleHollowButton(_ button:UIButton) {
        
        button.layer.borderWidth = 2
        button.backgroundColor = UIColor.white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.black
        
    }
    
    // validate email for the right format
    static func isValidEmail(_ email:String?) -> Bool {
        
        guard email != nil else { return false }
        
        // There’s some text before the @
        // There’s some text after the @
        // There’s at least 2 alpha characters after a .
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
        
    }
    
    // validate password
    static func isValidPassword(_ password:String) -> Bool {
        
        // ^ - Start Anchor.
        // (?=.*[a-z])- Ensure string has one character.
        // (?=.*[0-9]) - Ensure string has one digit.
        // (?=.[$@$#!%?&])- Ensure string has one special character.
        // {8,} - Ensure password length is 8.
        // $ - End Anchor.
        
        let passwordRegEx = "^(?=.*[a-z])(?=.*[0-9])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
        
    }
    
    // validate filename for the right format
    static func isValidFile(_ filename:String?) -> Bool {
        
        guard filename != nil else { return false }
        
        // There’s some text before the . (basename)
        // There’s at least 3 characters after the . (extension)
        let regEx = "[A-Z0-9a-z._%+-]+\\.[A-Za-z0-9]{3,}"
        
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: filename)
        
    }
    
    // resize an image
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    static func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    // save users to firestore
    static func saveUserToFirestore(email: String, firstName: String, lastName: String, uid: String) -> String? {
        // User was created successfully. Store the firstname, lastname and email in Firestore
        let db = Firestore.firestore()
        var errMessage: String? = nil
        
        // Create a reference to the users collection
        let docRef = db.collection("users")

        // Create a query against the collection.
        let query = docRef.whereField("email", isEqualTo: email)
        
        query.getDocuments(completion: { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let numDocs = querySnapshot?.documents.count
                
                if numDocs == 0 {
                    docRef.addDocument(data: ["email": email,  "firstname": firstName, "lastname": lastName, "uid": uid]) { (error) in
                        if error != nil {
                            errMessage = "Error saving user data"
                        }
                    }
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    }
                }
            }
        })
        
        return errMessage
    }
    
    // return formatted License Agreement
    static func formattedLicenseAgreement() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let messageText = NSAttributedString(
            string: Constants.licenseAgreement,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor : UIColor.black,
                NSAttributedString.Key.font : UIFont(name: "Avenir Next", size: 14)!
            ]
        )
        
        return messageText
    }
    
    // Not using this currently because of the way html is formatted to show both Privacy Policy and Terms
    static func licensedAgreementFromHtmlString() -> NSAttributedString {
        
        var htmlString: String = ""
        if let url = URL(string: "https://teak-mantis-279104.firebaseapp.com") {
            do {
                htmlString = try String(contentsOf: url)
            } catch {
                // contents could not be loaded
                let error = "Privacy policy could not be loaded"
                let errorAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.red ]
                let errorAttrString = NSAttributedString(string: error, attributes: errorAttribute)
                return errorAttrString
            }
        } else {
            // the URL was bad!
            let error = "Found bad URL while loading privacy policy"
            let errorAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.red ]
            let errorAttrString = NSAttributedString(string: error, attributes: errorAttribute)
            return errorAttrString
        }
        
        print(htmlString)
        
        let data = htmlString.data(using: String.Encoding.unicode)!
        let mattrStr = try! NSMutableAttributedString(
            data: data,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        let normalFont = UIFontMetrics.default.scaledFont(for: UIFont(name: "Avenir Next", size: 14.0)!)
        let boldFont = UIFontMetrics.default.scaledFont(for: UIFont(name: "AvenirNext-DemiBold", size: 15.0)!)
        mattrStr.beginEditing()
        mattrStr.enumerateAttribute(.font, in: NSRange(location: 0, length: mattrStr.length), options: .longestEffectiveRangeNotRequired) { (value, range, _) in
            if let oFont = value as? UIFont {
                mattrStr.removeAttribute(.font, range: range)
                if oFont.fontName.contains("Bold"){
                    mattrStr.addAttribute(.font, value: boldFont, range: range)
                }
                else{
                    mattrStr.addAttribute(.font, value: normalFont, range: range)
                }

            }
        }
        
        return mattrStr
    }
    
}

extension UIButton{
    func roundedLeftButton() {
        let maskPath1 = UIBezierPath(roundedRect: bounds,
            byRoundingCorners: [.topLeft, .bottomLeft],
            cornerRadii: CGSize(width: 25, height: 25))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    func roundedRightButton() {
        let maskPath1 = UIBezierPath(roundedRect: bounds,
            byRoundingCorners: [.topRight, .bottomRight],
            cornerRadii: CGSize(width: 25, height: 25))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
}
