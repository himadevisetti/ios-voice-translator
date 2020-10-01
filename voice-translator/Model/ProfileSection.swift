//
//  ProfileSection.swift
//  voice-translator
//
//  Created by Hima Devisetti on 9/30/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

enum ProfileSection: Int, CaseIterable, CustomStringConvertible {
    case Agreements
    case Profile
    
    var description: String {
        switch self {
        case .Agreements: return "Agreements"
        case .Profile: return "User Activity"
        }
    }
}

enum AgreementsOptions: Int, CaseIterable, CustomStringConvertible {
    case privacyPolicy
    case termsAndConditions
    
    var description: String {
        switch self {
        case .privacyPolicy: return "Privacy Policy"
        case .termsAndConditions: return "Terms and Conditions"
        }
    }
}

enum ProfileOptions: Int, CaseIterable, CustomStringConvertible {
    case checkStatus
    case logOut
    
    var description: String {
        switch self {
        case .checkStatus: return "Check Status"
        case .logOut: return "Log Out"
        }
    }
}
