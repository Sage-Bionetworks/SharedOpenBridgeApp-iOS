//
//  OnboardingView.swift
//

import SwiftUI
import SharedMobileUI
import BridgeClientExtension
import BridgeClientUI

struct OnboardingView: View {
    @EnvironmentObject private var bridgeManager: SingleStudyAppManager
    @State private var section: Section = .welcome
    @State private var selectedPrivacyTab: PrivacyNotice.Category = .weWill
    
    private enum Section : Int, CaseIterable {
        case welcome, privacyNotice, permissions
    }
    
    var body: some View {
        switch section {
        case .welcome:
            if let study = bridgeManager.study {
                StudyWelcomeOnboardingView(study: study, goForward: { section = .privacyNotice })
            }
            else {
                LaunchView()
            }
        case .privacyNotice:
            PrivacyNoticeOnboardingView(selectedTab: $selectedPrivacyTab,
                                        goNextSection: { section = .permissions },
                                        goPreviousSection: { section = .welcome })
        case .permissions:
            PermissionsOnboardingView(handleFinished: {
                bridgeManager.isOnboardingFinished = true
            }, goPreviousSection: {
                section = .privacyNotice
            })
        }
    }
}

struct OnboardingNavigationView <Content: View> : View {
    @ObservedObject private var navigator: PagedNavigationViewModel
    private let content: Content
    
    init(navigator: PagedNavigationViewModel, @ViewBuilder content: () -> Content) {
        self.navigator = navigator
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
            PagedNavigationBar()
                .frame(width: 160+48+48)
                .padding(.vertical)
                .environmentObject(navigator)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(SingleStudyAppManager(appId: kPreviewStudyId))
    }
}
