//
//  StudyWelcomeOnboardingView.swift
//

import SwiftUI
import BridgeClient
import BridgeClientExtension
import BridgeClientUI
import SharedMobileUI


struct StudyWelcomeOnboardingView: View {
    @StateObject var study: StudyObserver
    
    var goForward: (() -> Void)
    
    var body: some View {
        VStack {
            if study.allLoaded {
                header()
                welcomeContent()
                Button(action: goForward) {
                    Text("Continue", bundle: .module)
                }
                .buttonStyle(NavigationButtonStyle(.text))
                .padding(.vertical, 32)
            }
            else {
                LaunchView()
            }
        }
    }
    
    @ViewBuilder
    func welcomeContent() -> some View {
        ScrollView {
            Spacer()
                .frame(height: 50)
            VStack(alignment: .leading, spacing: 27) {
                let name = study.name ?? Bundle.localizedAppName
                let welcome = study.studyConfig?.welcomeScreenData
                welcomeSalutation(studyName: name, welcome: welcome)
                    .font(DesignSystem.fontRules.headerFont(at: 1))
                    .fixedSize(horizontal: false, vertical: true)

                welcomeBody(studyName: name, welcome: welcome)
                    .font(DesignSystem.fontRules.bodyFont(at: 1, isEmphasis: false))
                    .fixedSize(horizontal: false, vertical: true)

                if welcome?.useOptionalDisclaimer ?? true {
                    disclaimer()
                        .font(DesignSystem.fontRules.bodyFont(at: 1, isEmphasis: false))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .foregroundColor(.textForeground)
            .padding(.horizontal, 48)
        }
    }
    
    @ViewBuilder
    func header() -> some View {
        let headerColor: Color = study.backgroundColor
        LogoImage(url: study.studyLogoUrl)
            .background(headerColor.edgesIgnoringSafeArea(.top))
    }
        
    @ViewBuilder
    func welcomeSalutation(studyName: String, welcome: WelcomeScreenData?) -> some View {
        if let welcome = welcome, !welcome.isUsingDefaultMessage {
            Text(welcome.welcomeScreenHeader ?? "")
        }
        else {
            let format = NSLocalizedString("Welcome to %@!", bundle: .module, comment: "")
            Text(String(format: format, studyName))
        }
    }
    
    @ViewBuilder
    func welcomeBody(studyName: String, welcome: WelcomeScreenData?) -> some View {
        if let welcome = welcome, !welcome.isUsingDefaultMessage {
            Text(welcome.welcomeScreenBody ?? "")
            Text(welcome.welcomeScreenSalutation ?? "")
            Text(welcome.welcomeScreenFromText ?? "")
        }
        else {
            Text("We are excited that you will be participating. We hope that you find this study helpful.", bundle: .module)
            Text("Sincerely,", bundle: .module)
            let format = NSLocalizedString("The %@ team", bundle: .module, comment: "")
            Text(String(format: format, studyName))
        }
    }
    
    @ViewBuilder
    func disclaimer() -> some View {
        Text("This is a research study. It does not provide medical advice, diagnosis, or treatment.", bundle: .module)
    }
}

struct StudyWelcomeOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        StudyWelcomeOnboardingView(study: previewStudyObserver, goForward: {})
    }
}

let previewStudyObserver: StudyObserver = {
    let observer = StudyObserver(identifier: kPreviewStudyId)
    observer.update(from: previewStudy)
    return observer
}()
let previewStudy = Study(identifier: kPreviewStudyId,
                         name: "Xcode Preview Study",
                         phase: StudyPhase.design,
                         version: 1,
                         details: "Description about the study. Lorem ipsum about the study written by the research team that they want to share to participants.\n\nLorem ipsum about the study written by the research team that they want to share to participants. Lorem ipsum about the study written by the research team that they want to share to participants.",
                         clientData: nil,
                         irbName: "University of San Diego",
                         irbDecisionOn: nil,
                         irbExpiresOn: nil,
                         irbDecisionType: nil,
                         irbProtocolName: nil,
                         irbProtocolId: "2039480923",
                         studyLogoUrl: "https://docs.sagebridge.org/5rht4Xajwu2N69EPlHXfjT-Y.1632172103361",
                         colorScheme: nil,
                         institutionId: nil,
                         scheduleGuid: nil,
                         keywords: nil,
                         diseases: nil,
                         studyDesignTypes: nil,
                         signInTypes: nil,
                         contacts: nil,
                         deleted: nil,
                         createdOn: nil,
                         modifiedOn: nil,
                         type: nil)

