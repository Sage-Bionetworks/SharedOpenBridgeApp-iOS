//
//  MobileToolboxAppDelegate.swift
//

import SwiftUI
import BridgeClient
import BridgeClientUI
import Research
import ResearchUI
import MobilePassiveData
import LocationAuthorization
import MotionSensor
import AudioRecorder


open class MobileToolboxAppDelegate: RSDSwiftUIAppDelegate {
    
    open class var appId: String { "" }
    open class var pemPath: String { "" }
    
    public let bridgeManager: SingleStudyAppManager
    
    public override init() {
        let appId = type(of: self).appId
        let pemPath = type(of: self).pemPath
        self.bridgeManager = SingleStudyAppManager(appId: appId, pemPath: pemPath)
        super.init()
    }
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        bridgeManager.appWillFinishLaunching(launchOptions)
        
        // Set up notifications handling
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().delegate = bridgeManager.localNotificationManager
        
        PermissionAuthorizationHandler.registerAdaptorIfNeeded(MotionAuthorization.shared)
        PermissionAuthorizationHandler.registerAdaptorIfNeeded(AudioRecorderAuthorization.shared)
        PermissionAuthorizationHandler.registerAdaptorIfNeeded(LocationAuthorization())
        PermissionAuthorizationHandler.registerAdaptorIfNeeded(NotificationsAuthorization())

        return true
    }
    
    open func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String,
            completionHandler: @escaping () -> Void) {
        bridgeManager.handleEvents(for: identifier, completionHandler: completionHandler)
    }
}
