//
//  PermissionsOnboardingView.swift
//

import SwiftUI
import BridgeClientExtension
import BridgeClientUI
import AssessmentModel
import SharedMobileUI
import MobilePassiveData

struct PermissionsOnboardingView: View {
    @EnvironmentObject private var bridgeManager: SingleStudyAppManager
    @StateObject private var navigator: PagedNavigationViewModel = .init()
    @State private var currentNode: ContentNode? = nil
    @State private var steps: [ContentNode] = []
    
    private let handleFinished: (() -> Void)
    private let goPreviousSection: (() -> Void)?
    
    private var isXcodePreview: Bool =
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    
    init(handleFinished: @escaping (() -> Void), goPreviousSection: (() -> Void)? = nil) {
        self.handleFinished = handleFinished
        self.goPreviousSection = goPreviousSection
    }
    
    var body: some View {
        OnboardingNavigationView(navigator: navigator) {
            if let node = currentNode {
                ScrollView {
                    PermissionsView(node: node)
                }
            }
            else {
                EmptyView()
            }
        }
        .onAppear {
            setupNavigator()
        }
    }
    
    func setupNavigator() {
        steps = bridgeManager.onboardingSteps()
        self.navigator.pageCount = steps.count
        self.navigator.goForward = goForward
        self.navigator.goBack = goBack
        self.navigator.progressHidden = (steps.count == 1)
        _finishNavigation()
    }
    
    func goForward() {
        if !isXcodePreview, let permissionType = self.currentNode?.standardPermissionType {
            requestPermission(for: permissionType)
        }
        else {
            self._moveForward()
        }
    }
    
    func _moveForward() {
        guard self.navigator.currentIndex + 1 < steps.count else {
            handleFinished()
            return
        }
        self.navigator.increment()
        _finishNavigation()
    }
    
    func goBack() {
        if self.navigator.currentIndex > 0 {
            self.navigator.decrement()
            _finishNavigation()
        }
        else {
            goPreviousSection?()
        }
    }
    
    private func _finishNavigation() {
        self.navigator.backEnabled = (goPreviousSection != nil) || (self.navigator.currentIndex > 0)
        if self.navigator.currentIndex < steps.count {
            self.currentNode = steps[self.navigator.currentIndex]
        }
        else {
            self.handleFinished()
        }
    }
    
    func requestPermission(for permissionType: StandardPermissionType) {
        PermissionAuthorizationHandler.requestAuthorization(for: StandardPermission(permissionType: permissionType)) { (status, error) in
            DispatchQueue.main.async {
                debugPrint("Permission returned; permission=\(permissionType.identifier), status=\(status.rawValue), error=\(String(describing: error))")
                self._moveForward()
            }
        }
    }
}

extension ContentNode {
    var standardPermissionType: StandardPermissionType? {
        switch self.identifier {
        case "microphone":
            return .microphone
        case "weather":
            return .locationWhenInUse
        case "notifications":
            return .notifications
        default:
            return nil
        }
    }
}

extension ContentNode {
    var titleKey: LocalizedStringKey {
        LocalizedStringKey(title ?? "")
    }
    var detailKey: LocalizedStringKey {
        LocalizedStringKey(detail ?? "")
    }
    var imageName: String? {
        self.imageInfo?.imageName
    }
    var bundle: Bundle? {
        .module
    }
}

struct PermissionsOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PermissionsOnboardingView(handleFinished: {})
                .environmentObject(SingleStudyAppManager(mockType: .preview))
        }
    }
}

let optionalRecorderIdentifiers = ["weather", "microphone", "motion"]

extension SingleStudyAppManager {
    func onboardingSteps() -> [ContentNode] {
        let onboardingSteps = appConfig.decodeOnboardingSteps()
        
        // syoung 05/19/2023 - leaving this here in case background recorders ever come back.
        return onboardingSteps.first.map { [$0] } ?? [notificationsPermissionNode]
//        let recorders = study?.studyConfig?.backgroundRecorders ?? [:]
//        var filteredSteps = onboardingSteps.filter {
//            !optionalRecorderIdentifiers.contains($0.identifier) ||
//            (recorders[$0.identifier] ?? false)
//        }
//        if filteredSteps.count == 2 {
//            // If none of the background recorders are included then *only*
//            // show permission for notifications.
//            filteredSteps.removeLast()
//        }
//        return filteredSteps
    }
}
