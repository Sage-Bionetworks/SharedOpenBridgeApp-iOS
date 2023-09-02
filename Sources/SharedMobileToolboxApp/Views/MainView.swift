//
//  MainView.swift
//

import SwiftUI
import BridgeClientExtension
import BridgeClientUI

struct MainView: View {
    @EnvironmentObject var bridgeManager: SingleStudyAppManager
    @StateObject var viewModel: ViewModel = .init()
    
    enum Tab: String, CaseIterable, EnumTabItem {
        case today, history, studyInfo, account
        
        var bundle: Bundle? { .module }
        
        func title() -> Text {
            switch self {
            case .today:
                return Text("Home", bundle: .module)
            case .history:
                return Text("Past Activities", bundle: .module)
            case .studyInfo:
                return Text("Study Info", bundle: .module)
            case .account:
                return Text("Account", bundle: .module)
            }
        }
    }
    
    class ViewModel : ObservableObject {
        @Published var selectedTab: Tab = .today
        @Published var selectedStudyInfoTab: StudyInfoView.Tab = .about
        @Published var selectedAccountTab: AccountView.Tab = .profile
        
        func showContactInfo() {
            self.selectedStudyInfoTab = .contact
            self.selectedTab = .studyInfo
        }
    }

    var body: some View {
        CustomTabView(selectedTab: $viewModel.selectedTab, tabs: Tab.allCases, placement: .bottom) { tab in
            switch tab {
            case .today:
                todayView()
            case .history:
                HistoryView()
            case .studyInfo:
                StudyInfoView($viewModel.selectedStudyInfoTab)
            case .account:
                AccountView($viewModel.selectedAccountTab)
            }
        }
        .environmentObject(viewModel)
    }
    
    @ViewBuilder
    func todayView() -> some View {
        if bridgeManager.isStudyComplete {
            EndOfStudyView()
                .transition(.opacity)
        }
        else {
            TodayView()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(SingleStudyAppManager(mockType: .preview))
            .environmentObject(TodayTimelineViewModel())
    }
}

