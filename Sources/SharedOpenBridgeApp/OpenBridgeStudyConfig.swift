//
//  OpenBridgeStudyConfig.swift
//

import Foundation
import BridgeClient
import BridgeClientUI

struct OpenBridgeStudyConfig : Codable, Hashable {
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
    var studyConfig: OpenBridgeStudyConfig? {
        guard let data = clientData else { return nil }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(OpenBridgeStudyConfig.self, from: data)
        } catch let err {
            print("WARNING! Failed to decode `OpenBridgeStudyConfig`. \(err) ")
            return nil
        }
    }
}
