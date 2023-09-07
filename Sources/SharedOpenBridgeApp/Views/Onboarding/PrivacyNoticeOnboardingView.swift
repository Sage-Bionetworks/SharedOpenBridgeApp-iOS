//
//  PrivacyNoticeOnboardingView.swift
//

import SwiftUI
import BridgeClientExtension
import BridgeClientUI
import SharedMobileUI

struct PrivacyNoticeOnboardingView : View {
    @StateObject private var navigator: PagedNavigationViewModel = .init()
    @Binding var selectedTab: PrivacyNotice.Category

    var goNextSection: (() -> Void)?
    var goPreviousSection: (() -> Void)?
    
    var body: some View {
        OnboardingNavigationView(navigator: navigator) {
            PrivacyNoticeView(selectedTab: $selectedTab)
        }
        .onAppear {
            setupNavigator()
        }
    }
    
    func setupNavigator() {
        navigator.pageCount = 3
        navigator.progressHidden = true
        navigator.goForward = goForward
        navigator.goBack = goBack
        navigator.backEnabled = true
    }
    
    func goForward() {
        switch selectedTab {
        case .weWill:
            selectedTab = .weWont
        case .weWont:
            selectedTab = .youCan
        case .youCan:
            goNextSection?()
        }
    }
    
    func goBack() {
        switch selectedTab {
        case .weWill:
            goPreviousSection?()
        case .weWont:
            selectedTab = .weWill
        case .youCan:
            selectedTab = .weWont
        }
    }
}

struct PrivacyNoticeOnboardingPreviewer : View {
    @State var selectedTab: PrivacyNotice.Category = .weWill
    var body: some View {
        PrivacyNoticeOnboardingView(selectedTab: $selectedTab)
            .environmentObject(SingleStudyAppManager(mockType: .preview))
    }
}

struct PrivacyNoticeOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyNoticeOnboardingPreviewer()
    }
}
