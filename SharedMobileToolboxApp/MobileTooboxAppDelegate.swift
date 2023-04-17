//
//  MobileToolboxAppDelegate.swift
//

import SwiftUI
import BridgeClientExtension
import BridgeClient
import BridgeClientUI
import Research
import ResearchUI
import MobilePassiveData
import LocationAuthorization
import MotionSensor
import AudioRecorder
import MobileToolboxKit

open class MobileToolboxAppDelegate: RSDSwiftUIAppDelegate, ReauthPasswordHandler {
    open class var appId: String { "" }
    open class var pemPath: String { "" }
    
    public let bridgeManager: SingleStudyAppManager
    
    public override init() {
        let appId = type(of: self).appId
        let pemPath = type(of: self).pemPath
        self.bridgeManager = SingleStudyAppManager(appId: appId, pemPath: pemPath)
        super.init()
        self.bridgeManager.reauthPasswordHandler = self
    }
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Setup bridge
        bridgeManager.finishLaunchingApp(launchOptions)
        
        // Set up notifications handling
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().delegate = bridgeManager.localNotificationManager
        
        PermissionAuthorizationHandler.registerAdaptorIfNeeded(MotionAuthorization.shared)
        PermissionAuthorizationHandler.registerAdaptorIfNeeded(AudioRecorderAuthorization.shared)
        PermissionAuthorizationHandler.registerAdaptorIfNeeded(LocationAuthorization())
        PermissionAuthorizationHandler.registerAdaptorIfNeeded(NotificationsAuthorization())
        
        NotificationCenter.default.addObserver(forName: UploadAppManager.BridgeClientWillSignOut, object: nil, queue: .main) { _ in
            taskVendor.clearCachedData()
        }

        return true
    }
    
    open func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String,
            completionHandler: @escaping () -> Void) {
        bridgeManager.handleEvents(for: identifier, completionHandler: completionHandler)
    }
    
    public func storedPassword(for session: UserSessionInfoObserver) -> String? {
        session.externalId
    }
    
    public func clearStoredPassword() {
        // TODO: syoung 03/21/2022 Decide what should happen if reauth fails.
    }
}
