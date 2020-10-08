//
//  InfoPlistParser.swift
//  voice-translator
//
//  Created by Hima Devisetti on 10/5/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import Foundation

struct InfoPlistParser {
    
    static func getStringValue(forKey: String) -> String {
        guard let value = Bundle.main.infoDictionary?[forKey] as? String else {
            fatalError("No value found for key '\(forKey)' in the Info.plist file")
        }
        return value
    }
    
}
