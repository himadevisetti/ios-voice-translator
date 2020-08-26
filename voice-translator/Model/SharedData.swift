//
//  SharedData.swift
//  voice-translator
//
//  Created by user178116 on 8/22/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import Foundation

class SharedData {
    
    static var instance: SharedData = {
        let instance = SharedData()
        // Setup code
        
        return instance
    }()
    
    private init() {}
    
    var userName: String?
    var fileName: String?
    var statusForUser: [String]?
    
}
