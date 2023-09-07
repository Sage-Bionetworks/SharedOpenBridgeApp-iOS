//
//  OpenBridgeAppDelegate.swift
//

import SwiftUI
import BridgeClientExtension
import BridgeClient
import BridgeClientUI
import Research
import ResearchUI
import MobilePassiveData

// Leaving these here commented out - if recorders are ever supported again, these will
// need to be uncommented and the package and plist will need to include them. syoung 05/19/2023
//import LocationAuthorization
//import MotionSensor
//import AudioRecorder

open class OpenBridgeAppDelegate: RSDAppDelegate, ReauthPasswordHandler {
    open class var appId: String { "" }
    open class var pemPath: String { "" }
    open class var backgroundProcessId: String { "" }
    
    public let bridgeManager: SingleStudyAppManager
    
    public override init() {
        let appId = Self.appId
        let pemPath = Self.pemPath
        let backgroundProcessId = Self.backgroundProcessId
        self.bridgeManager = SingleStudyAppManager(appId: appId, pemPath: pemPath, backgroundProcessId: backgroundProcessId)

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
