// Created 6/23/23
// swift-tools-version:5.0

import Foundation
import MobileToolboxKit
import MSSMobileKit
import BridgeClientExtension

let taskVendor = MSSTaskVender(taskConfigLoader: MTBStaticTaskConfigLoader.default)

public final class MTBAssessmentManager {
    public static let shared: MTBAssessmentManager = .init()
    
    private var observer: Any?
    
    public func hasAssessment(with assessmentId: String) -> Bool {
        return (MTBIdentifier(rawValue: assessmentId) != nil) ||
               (taskVendor.taskTransformerMapping[assessmentId] != nil)
    }
    
    public func onLaunch() {
        guard observer == nil else { return }
        
        // Listen for sign out and clear caches if needed
        observer = NotificationCenter.default.addObserver(forName: UploadAppManager.BridgeClientWillSignOut, object: nil, queue: .main) { _ in
            taskVendor.clearCachedData()
        }
    }
}
