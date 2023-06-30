//
//  PermissionStep.swift
//  MTBValidation
//

import Foundation
import Research
import JsonModel
import ResultModel
import MobilePassiveData

extension RSDStepType {
    static let permission: RSDStepType = "permission"
}

struct PermissionStep: SerializableStep, RSDUIStep, RSDDesignableUIStep {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case stepType = "type", identifier, permissionType, title, detail, image
    }
    public private(set) var stepType: RSDStepType = .permission

    let identifier: String
    let permissionType: StandardPermissionType
    let title: String?
    let detail: String?
    let image: RSDFetchableImageThemeElementObject
    
    init(permissionType: StandardPermissionType) {
        let identifier = permissionType == .locationWhenInUse ? "weather" : permissionType.rawValue
        self.identifier = identifier
        self.permissionType = permissionType
        let entry = permissionsText.first(where: { $0["identifier"] == identifier })
        self.title = entry?["title"]
        self.detail = entry?["detail"]
        self.image = RSDFetchableImageThemeElementObject(imageName: "permissions_\(identifier)")
    }
    
    func instantiateStepResult() -> ResultData {
        ResultObject(identifier: self.identifier)
    }
    
    var imageTheme: RSDImageThemeElement? { self.image }
    
    var viewTheme: RSDViewThemeElement? { nil }
    
    var colorMapping: RSDColorMappingThemeElement? { nil }
    
    // Ignored - required by protocol
    
    func validate() throws {
    }
    
    var subtitle: String? { nil }
    var footnote: String? { nil }
    
    func action(for actionType: RSDUIActionType, on step: RSDStep) -> RSDUIAction? {
        nil
    }
    
    func shouldHideAction(for actionType: RSDUIActionType, on step: RSDStep) -> Bool? {
        nil
    }
}

struct InstructionStep : RSDDesignableUIStep {
    
    let identifier: String
    let title: String?
    let detail: String?
    let imageTheme: RSDImageThemeElement?
    
    init(_ identifier: String, title: String? = nil, detail: String? = nil, hasImage: Bool = true) {
        self.identifier = identifier
        let entry = permissionsText.first(where: { $0["identifier"] == identifier })
        self.title = title ?? entry?["title"]
        self.detail = detail ?? entry?["detail"]
        self.imageTheme = hasImage ? RSDFetchableImageThemeElementObject(imageName: "permissions_\(identifier)", bundle: Bundle.module) : nil
    }
    
    var viewTheme: RSDViewThemeElement? { nil }
    
    var colorMapping: RSDColorMappingThemeElement? { nil }
    
    var subtitle: String? { nil }
    
    var footnote: String? { nil }

    var stepType: RSDStepType { .instruction }
    
    func instantiateStepResult() -> ResultData {
        ResultObject(identifier: self.identifier)
    }
    
    func validate() throws {
    }
    
    func action(for actionType: RSDUIActionType, on step: RSDStep) -> RSDUIAction? {
        nil
    }
    
    func shouldHideAction(for actionType: RSDUIActionType, on step: RSDStep) -> Bool? {
        nil
    }
}

let onboardingData: [ContentNode] = [
    PermissionStep(permissionType: .notifications),
    InstructionStep("intro"),
    PermissionStep(permissionType: .locationWhenInUse),
    PermissionStep(permissionType: .microphone),
    PermissionStep(permissionType: .motion)
]

let permissionsText =  [
    [
      "identifier": "notifications",
      "title": "Notifications",
      "detail": "We will send you a daily reminder or notification on your phone to complete your activities.\n\nYou can choose to make it an alert, a sound, or an icon badge.\n\nYou can say no and still be in the study."
    ],
    [
      "identifier": "intro",
      "title": "Environmental Factors",
      "detail": "The environment around you, such as weather pollution in your area or how close you are to a grocery store or park, can affect your health and well-being.\n\nOn the next screens we will ask for your permission to collect a variety of data. This is optional, you can say no and still be in the study."
    ],
    [
      "identifier": "weather",
      "title": "Weather and Air Quality",
      "detail": "We'd like to know the weather and air quality around you.\n\nWe will only collect this data when you are using the app."
    ],
    [
      "identifier": "microphone",
      "title": "Microphone",
      "detail": "Noise can be distracting. We'd like to use the phone microphone to record the noise level around you.\n\nWe only measure noise when you are doing the activities. We do not keep the recordings."
    ],
    [
      "identifier": "motion",
      "title": "Motion & Fitness Activity",
      "detail": "We’d like to measure your movements while you use the app.\n\nThis will give us an idea of your physical activity that may distract you while you are using the app."
    ]
  ]
