//
//  AccountView.swift
//

import SwiftUI
import BridgeClientUI
import SharedMobileUI
import MobilePassiveData

struct AccountView: View {
    @EnvironmentObject var bridgeManager: SingleStudyAppManager
    @EnvironmentObject var mainViewModel: MainView.ViewModel
    @StateObject var viewModel: ViewModel = .init()
    @State var hiddenTabs: Set<Tab> = []
    @Binding var selectedTab: Tab
    
    init(_ selectedTab: Binding<Tab>) {
        self._selectedTab = selectedTab
    }
    
    enum Tab : String, CaseIterable, EnumTabItem {
        case profile, notifications, settings
        
        var bundle: Bundle? { .module }
        
        func title() -> Text {
            switch self {
            case .profile:
                return Text("PROFILE", bundle: .module)
            case .notifications:
                return Text("NOTIFICATIONS", bundle: .module)
            case .settings:
                return Text("SETTINGS", bundle: .module)
            }
        }
    }
    
    var body: some View {
        CustomTabView(selectedTab: $selectedTab,
                      tabs: Tab.allCases.filter { !hiddenTabs.contains($0) },
                      placement: .top) { tab in
            ScreenBackground {
                ScrollView {
                    switch tab {
                    case .profile:
                        profileView()
                    case .notifications:
                        SettingsView(node: viewModel.notifications)
                    case .settings:
                        settingsView()
                    }
                }
            }
        }
        .onAppear {
            viewModel.onAppear(bridgeManager)
            if viewModel.settings.count == 0 {
                hiddenTabs.insert(.settings)
            }
        }
    }

    @ViewBuilder
    private func profileView() -> some View {
        VStack(spacing: 0) {
            accountInfoView()
            withdrawalView()
        }
    }
    
    @ViewBuilder
    private func accountInfoView() -> some View {
        let columns = [
            GridItem(.fixed(120)),
            GridItem(.flexible()),
        ]
        
        LazyVGrid(columns: columns, alignment: .leading, spacing: 19) {
            profileInfo(Text("Study ID:", bundle: .module), viewModel.studyId)
            if let participantId = viewModel.participantId {
                profileInfo(Text("Participant ID:", bundle: .module), participantId)
            }
            if let phoneNumber = viewModel.phoneNumber {
                profileInfo(Text("Phone Number:", bundle: .module), phoneNumber)
            }
            profileInfo(Text("Version:", bundle: .module), viewModel.version)
        }
        .foregroundColor(.textForeground)
        .padding(.horizontal, 31)
        .padding(.vertical, 21)
        .background(Color.sageWhite)
        .cornerRadius(10)
        .padding(.top, 29)
        .padding(.horizontal, 25)
        .padding(.bottom, 19)
    }
    
    @ViewBuilder
    private func profileInfo(_ label: Text, _ value: String) -> some View {
        label
            .font(DesignSystem.fontRules.headerFont(at: 5))
        Text(value)
            .font(DesignSystem.fontRules.bodyFont(at: 1, isEmphasis: false))
    }
    
    @ViewBuilder
    private func withdrawalView() -> some View {
        HStack {
            Image("withdrawal", bundle: .module)
            ZStack {
                withdrawalText()
                    .frame(alignment: .leading)
                    .font(DesignSystem.fontRules.bodyFont(at: 2, isEmphasis: false))
                    .foregroundColor(.textForeground)
                Button(action: mainViewModel.showContactInfo) {
                    Color.clear
                }
            }
        }
        .padding(.top, 31)
        .padding(.bottom, 36)
        .padding(.leading, 30)
        .padding(.trailing, 39)
        .background(Color.appLavender)
        .padding(.bottom, 22)
    }
    
    @ViewBuilder
    func withdrawalText() -> some View {
        let html = NSLocalizedString("To <b>withdraw</b> from this study, please contact your Study Contact from the <u><b>Study Info page.</b></u>", bundle: .module, comment: "")
        AttributedTextView(html: html)
    }
    
    @ViewBuilder
    private func settingsView() -> some View {
        LazyVStack {
            ForEach(viewModel.settings, id: \.identifier) { node in
                SettingsView(node: node)
                LineView().padding(.horizontal, 16)
            }
        }
    }

    class ViewModel : ObservableObject {
            
        // MARK: Profile tab
        
        @Published var studyId: String = ""
        @Published var participantId: String?
        @Published var phoneNumber: String?
        
        var version: String {
            "\(versionNumber).\(buildNumber)"
        }
        private let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        private let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        
        // MARK: Settings
        
        @Published var notifications: PermissionStep = PermissionStep(permissionType: .notifications)
        @Published var settings: [PermissionStep] = [
            PermissionStep(permissionType: .locationWhenInUse),
            PermissionStep(permissionType: .microphone),
            PermissionStep(permissionType: .motion),
        ]
        
        // MARK: Set up
        
        func onAppear(_ bridgeManager: SingleStudyAppManager) {
            self.settings = bridgeManager.onboardingSteps().compactMap {
                guard let step = $0 as? PermissionStep else { return nil }
                if step.permissionType == .notifications {
                    self.notifications = step
                    return nil
                } else {
                    return step
                }
            }
            self.studyId = bridgeManager.studyId ?? ""
            self.participantId = bridgeManager.userSessionInfo.participantId(for: self.studyId)
            self.phoneNumber = bridgeManager.userSessionInfo.phone
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World")
    }
}
