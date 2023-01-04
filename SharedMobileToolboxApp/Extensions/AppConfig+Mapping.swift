//
//  AppConfig+Mapping.swift
//
//

import Foundation
import BridgeClient
import BridgeClientExtension
import BridgeClientUI
import JsonModel
import Research

extension AppConfigObserver {
    
    func decodeOnboardingSteps() -> [ContentNode]? {

        do {
            guard let data = self.configElementJson(identifier: "PermissionsOnboarding")
            else {
                return nil
            }
            let factory = RSDFactory()
            factory.stepSerializer.add(PermissionStep(permissionType: .motion))
            let decoder = factory.createJSONDecoder()
            let task =  try decoder.decode(AssessmentTaskObject.self, from: data)
            return task.steps.compactMap { $0 as? ContentNode }
        }
        catch let err {
            print("WARNING! Failed to decode config: \(err)")
            return nil
        }
    }
}
