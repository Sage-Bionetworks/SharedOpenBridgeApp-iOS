// Created 6/13/23
// swift-tools-version:5.0

import UIKit
import SwiftUI
import BridgeClientUI
import SharedMobileUI

// TODO: syoung 06/14/2023 Revisit this each year until we no longer need to support a work-around.
// syoung 06/13/2023 This allows supported orientation to be honored.
// Adapted from https://www.polpiella.dev/changing-orientation-for-a-single-screen-in-swiftui

public protocol OpenBridgeContentView : View {
    init()
}

open class OpenBridgeSceneDelegate<Content: OpenBridgeContentView>: UIResponder, UIWindowSceneDelegate {
    public var window: UIWindow?

    open func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = OrientationLockedController(rootView: Content())
        window.makeKeyAndVisible()
        self.window = window
    }
}

class OrientationLockedController<Content: View>: UIHostingController<OrientationLockedController.Root<Content>> {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        AppOrientationLockUtility.currentOrientationLock
    }
    
    init(rootView: Content) {
        super.init(rootView: .init(contentView: rootView, bridgeManager: (UIApplication.shared.delegate! as! OpenBridgeAppDelegate).bridgeManager))
    }
    
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Root<Content: View> : View {
        let contentView: Content
        @ObservedObject var bridgeManager: SingleStudyAppManager
        
        var body: some View {
            contentView
                .environmentObject(bridgeManager)
        }
    }
}
