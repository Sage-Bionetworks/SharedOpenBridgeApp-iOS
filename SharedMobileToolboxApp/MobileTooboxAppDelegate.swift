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
import MobileToolboxKit

// Leaving these here commented out - if recorders are ever supported again, these will
// need to be uncommented and the package and plist will need to include them. syoung 05/19/2023
//import LocationAuthorization
//import MotionSensor
//import AudioRecorder

open class MobileToolboxAppDelegate: RSDAppDelegate, ReauthPasswordHandler {
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
    
    open func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    open override func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        AppOrientationLockUtility.shouldAutorotate = true
        return super.application(application, willFinishLaunchingWithOptions: launchOptions)
    }
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Setup bridge
        bridgeManager.finishLaunchingApp(launchOptions)
        
        // Set up notifications handling
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().delegate = bridgeManager.localNotificationManager
        PermissionAuthorizationHandler.registerAdaptorIfNeeded(NotificationsAuthorization())
        
        // Leaving these here commented out - if recorders are ever supported again, these will
        // need to be uncommented and the package and plist will need to include them. syoung 05/19/2023
        //PermissionAuthorizationHandler.registerAdaptorIfNeeded(MotionAuthorization.shared)
        //PermissionAuthorizationHandler.registerAdaptorIfNeeded(AudioRecorderAuthorization.shared)
        //PermissionAuthorizationHandler.registerAdaptorIfNeeded(LocationAuthorization())
        
        // Listen for sign out and clear caches if needed
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
