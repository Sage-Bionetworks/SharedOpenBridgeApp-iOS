//
//  ContentView.swift
//

import SwiftUI
import BridgeClientExtension
import BridgeClientUI
import Research
import AssessmentModel
import AssessmentModelUI

public let kAssessmentInfoMap: AssessmentInfoMap = .init(extensions: MTBIdentifier.allCases, defaultColor: MTBIdentifier.defaultColor)

public struct ContentView: View {
    @EnvironmentObject var bridgeManager: SingleStudyAppManager
    @StateObject var todayViewModel: TodayTimelineViewModel = .init()
    @State var isPresentingAssessment: Bool = false
    
    public init() {}
    
    public var body: some View {
        switch bridgeManager.appState {
        case .launching:
            LaunchView()
        case .login:
            SingleStudyLoginView()
        case .onboarding:
            OnboardingView()
                .onAppear {
                    // Start fetching records and schedules on login
                    todayViewModel.onAppear(bridgeManager: bridgeManager)
                }
        case .main:
            MainView()
                .environmentObject(todayViewModel)
                .assessmentInfoMap(kAssessmentInfoMap)
                .fullScreenCover(isPresented: $isPresentingAssessment) {
                    assessmentView()
                }
                .onChange(of: todayViewModel.isPresentingAssessment) { newValue in
                    isPresentingAssessment = newValue
                }
        }
    }
    
    @ViewBuilder
    func assessmentView() -> some View {
        switch todayViewModel.selectedAssessmentViewType {
        case .mtb:
            PreferenceUIHostingControllerView {
                MTBAssessmentView(todayViewModel)
                    .edgesIgnoringSafeArea(.all)
            }
            .edgesIgnoringSafeArea(.all)
            .statusBar(hidden: todayViewModel.isPresentingAssessment)
        case .survey(let info):
            SurveyView<AssessmentView>(info, handler: todayViewModel)
        default:
            emptyAssessment()
        }
    }
    
    @ViewBuilder
    func emptyAssessment() -> some View {
        VStack {
            Text("This assessment is not supported by this app version")
            Button("Dismiss", action: { todayViewModel.isPresentingAssessment = false })
        }
    }
}

enum AssessmentViewType {
    case mtb
    case survey(AssessmentScheduleInfo)
    case empty
}

extension TodayTimelineViewModel {
    
    var selectedAssessmentViewType : AssessmentViewType {
        guard let info = selectedAssessment else { return .empty }
        
        let assessmentId = info.assessmentInfo.identifier
        if let _ = MTBIdentifier(rawValue: assessmentId) {
            return .mtb
        }
        else if taskVendor.taskTransformerMapping[assessmentId] != nil {
            return .mtb
        }
        else {
            return .survey(info)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(SingleStudyAppManager(appId: kPreviewStudyId))
        }
    }
}
