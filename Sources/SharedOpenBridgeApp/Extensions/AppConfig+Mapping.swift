//
//  AppConfig+Mapping.swift
//
//

import Foundation
import BridgeClient
import BridgeClientExtension
import BridgeClientUI
import JsonModel
import AssessmentModel

extension AppConfigObserver {
    
    func decodeOnboardingSteps() -> [ContentNode] {
        do {
            let data = self.configElementJson(identifier: "PermissionsOnboarding") ?? permissionsJson
            let factory = AssessmentFactory()
            let decoder = factory.createJSONDecoder()
            let task = try decoder.decode(AssessmentObject.self, from: data)
            return task.children.compactMap { $0 as? ContentNode }
        }
        catch let err {
            print("WARNING! Failed to decode config: \(err)")
            return []
        }
    }
}

fileprivate let permissionsJson = """
{
  "identifier": "PermissionsOnboarding",
  "type": "assessment",
  "steps": [
    {
      "identifier": "notifications",
      "type": "permission",
      "permissionType": "notifications",
      "image": {
        "type": "fetchable",
        "imageName": "permissions_notifications"
      },
      "title": "Notifications",
      "detail": "We may send you periodic reminders or notifications on your phone to complete your activities.\n\nYou can choose to make it an alert, a sound, or an icon badge.\n\nYou can say no and still be in the study."
    },
    {
      "identifier": "intro",
      "type": "instruction",
      "image": {
        "type": "fetchable",
        "imageName": "permissions_intro"
      },
      "title": "Environmental Factors",
      "detail": "The environment around you, such as weather or air pollution in your area or how close you are to a grocery store or park, can affect your health and well-being.\n\nOn the next screens we will ask for your permission to collect a variety of data. This is optional. You can say no and still be in the study."
    },
    {
      "identifier": "weather",
      "type": "permission",
      "permissionType": "locationWhenInUse",
      "image": {
        "type": "fetchable",
        "imageName": "permissions_weather"
      },
      "title": "Weather and Air Quality",
      "detail": "We'd like to know the weather and air quality around you.\n\nWe will only collect this data when you are using the app."
    },
    {
      "identifier": "microphone",
      "type": "permission",
      "permissionType": "microphone",
      "image": {
        "type": "fetchable",
        "imageName": "permissions_microphone"
      },
      "title": "Microphone",
      "detail": "Noise can be distracting. We'd like to use the phone microphone to record the noise level around you.\n\nWe only measure noise when you are doing the activities. We do not keep the recordings."
    },
    {
      "identifier": "motion",
      "type": "permission",
      "permissionType": "motion",
      "image": {
        "type": "fetchable",
        "imageName": "permissions_motion"
      },
      "title": "Motion & Fitness Activity",
      "detail": "We’d like to measure your movements while you use the app.\n\nThis will give us an idea of your physical activity that may distract you while you are using the app."
    }
  ]
}
""".data(using: .utf8)!
