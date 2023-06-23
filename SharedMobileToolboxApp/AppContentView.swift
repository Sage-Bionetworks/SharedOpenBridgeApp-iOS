// Created 6/23/23
// swift-tools-version:5.0

import SwiftUI
import BridgeClientExtension
import BridgeClientUI

public protocol AssessmentPresenterView : View {
    init(todayViewModel: TodayTimelineViewModel)
}

public struct AppContentView<Presenter : AssessmentPresenterView>: View {
    @EnvironmentObject var bridgeManager: SingleStudyAppManager
    @StateObject var todayViewModel: TodayTimelineViewModel = .init()
    @State var isPresentingAssessment: Bool = false
    
    public init() {}
    
    public var body: some View {
        switch bridgeManager.appState {
        case .launching:
            LaunchView()
        case .login:
            if let externalId = bridgeManager.userSessionInfo.externalId,
               externalId.contains(":"),
               bridgeManager.userSessionInfo.loginState == .reauthFailed {
                let parts = externalId.components(separatedBy: ":")
                ReauthRecoveryView(studyId: parts.first!, participantId: parts.last!)
            }
            else {
                SingleStudyLoginView()
            }
        case .onboarding:
            OnboardingView()
                .onAppear {
                    // Start fetching records and schedules on login
                    todayViewModel.onAppear(bridgeManager: bridgeManager)
                }
        case .main:
            MainView()
                .environmentObject(todayViewModel)
                .fullScreenCover(isPresented: $isPresentingAssessment) {
                    Presenter(todayViewModel: todayViewModel)
                }
                .onChange(of: todayViewModel.isPresentingAssessment) { newValue in
                    if newValue, let info = todayViewModel.selectedAssessment {
                        Logger.log(severity: .info,
                                   message: "Presenting Assessment \(info.assessmentIdentifier)",
                                   metadata: [
                                    "instanceGuid": info.instanceGuid,
                                    "assessmentIdentifier": info.assessmentIdentifier,
                                    "sessionInstanceGuid": info.session.instanceGuid,
                                   ])
                    }
                    isPresentingAssessment = newValue
                }
        case .error:
            AppErrorView()
        }
    }
}

