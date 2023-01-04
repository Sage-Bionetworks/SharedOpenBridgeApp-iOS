//
//  MobileToolboxStudyConfig.swift
//

import Foundation
import BridgeClient
import JsonModel
import MobilePassiveData
import BridgeClientUI

struct MobileToolboxStudyConfig : Codable, Hashable {
    let welcomeScreenData: WelcomeScreenData?
    let backgroundRecorders: [String : Bool]?
}

struct WelcomeScreenData : Codable, Hashable {
    private enum CodingKeys : String, CodingKey {
        case welcomeScreenHeader, welcomeScreenBody, welcomeScreenFromText, welcomeScreenSalutation, _useOptionalDisclaimer = "useOptionalDisclaimer", _isUsingDefaultMessage = "isUsingDefaultMessage"
    }
    let welcomeScreenHeader: String?
    let welcomeScreenBody: String?
    let welcomeScreenFromText: String?
    let welcomeScreenSalutation: String?
    
    var isUsingDefaultMessage: Bool { _isUsingDefaultMessage ?? false }
    private let _isUsingDefaultMessage: Bool?
    
    var useOptionalDisclaimer: Bool { _useOptionalDisclaimer ?? true }
    private let _useOptionalDisclaimer: Bool?
}

extension StudyObserver {
    var studyConfig: MobileToolboxStudyConfig? {
        guard let data = clientData else { return nil }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(MobileToolboxStudyConfig.self, from: data)
        } catch let err {
            print("WARNING! Failed to decode `MobileToolboxStudyConfig`. \(err) ")
            return nil
        }
    }
}
