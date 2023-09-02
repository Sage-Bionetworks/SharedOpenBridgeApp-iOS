// Created 2/3/23
// swift-tools-version:5.0

import SwiftUI
import BridgeClient
import BridgeClientExtension
import BridgeClientUI
import SharedMobileUI

struct ReauthRecoveryView: View {
    @EnvironmentObject var bridgeManager: SingleStudyAppManager
    @State var loginPending: Bool = false
    @State var loginFailed: Bool = false
    @State var errorMessage: Text?
    @State var studyId: String
    @State var participantId: String
    
    init(studyId: String, participantId: String) {
        self.studyId = studyId
        self.participantId = participantId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            HStack {
                Spacer()
                Image("Launching")
                    .fixedSize()
                Spacer()
            }
            .padding(.top, 64)
            .padding(.bottom, 32)
            
            Text("We're sorry. We need you to reauthorize your login credentials.", bundle: .module)
            
            VStack(spacing: 32) {
                loginCredentials()
                loginButton()
                    .padding()
            }
            
            Text("We're sorry. We cannot login to this account. Please check your internet connection and then contact your study coordinator for help.", bundle: .module)
                .foregroundColor(.red)
                .padding(.vertical)
                .opacity(loginFailed ? 1 : 0)
            
            Spacer()
        }
        .padding(.horizontal, 52)
    }
    
    @ViewBuilder
    func loginCredentials() -> some View {
        let columns = [
            GridItem(.fixed(120)),
            GridItem(.flexible()),
        ]
        
        LazyVGrid(columns: columns, alignment: .leading, spacing: 19) {
            Text("Study ID:", bundle: .module)
            Text(studyId)
            Text("Participant ID:", bundle: .module)
            Text(participantId)
        }
        .foregroundColor(.textForeground)
        .padding(.horizontal, 31)
        .padding(.vertical, 21)
        .background(Color.hexDEDEDE)
        .cornerRadius(10)
    }
    
    @ViewBuilder
    func loginButton() -> some View {
        Button(action: loginParticipant) {
            Text("Login", bundle: .module)
        }
        .buttonStyle(NavigationButtonStyle(.text))
        .buttonEnabled(!loginPending)
        .overlay(progressSpinner(), alignment: .trailing)
    }
    
    @ViewBuilder
    func progressSpinner() -> some View {
        ProgressView()
            .padding(.trailing, 8)
            .colorInvert()
            .opacity(loginPending ? 1.0 : 0.0)
    }
     
    func loginParticipant() {
        self.loginPending = true
        self.errorMessage = nil
        let password = "\(participantId):\(studyId)"
        self.bridgeManager.reauthWithCredentials(password: password) { status in
            self.loginPending = false
            self.loginFailed = (status == .failed)
        }
    }
}

struct ReauthRecoveryView_Previews: PreviewProvider {
    static var previews: some View {
        ReauthRecoveryView(studyId: kPreviewStudyId, participantId: "012345")
            .environmentObject(SingleStudyAppManager(mockType: .preview))
    }
}
