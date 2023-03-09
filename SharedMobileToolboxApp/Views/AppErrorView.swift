// Created 3/9/23
// swift-tools-version:5.0

import SwiftUI
import SharedMobileUI

let appStoreLink = URL(string: "https://apps.apple.com/us/app/apple-store/id1578358408")!

struct AppErrorView: View {
    @State var canOpen: Bool = true
    
    var body: some View {
        VStack(spacing: 17) {
            Image("AppUpdateRequired", bundle: .module)
                .padding(.bottom)
            Text("We’re Getting Better!", bundle: .module)
                .font(DesignSystem.fontRules.headerFont(at: 1))
                .foregroundColor(.textForeground)
            Text("Update the app to unlock new features and continue your experience.", bundle: .module)
                .font(DesignSystem.fontRules.bodyFont(at: 1, isEmphasis: false))
                .foregroundColor(.textForeground)
            Spacer()
            Button(action: { UIApplication.shared.open(appStoreLink) }) {
                Text("Update Now", bundle: .module)
            }
            .buttonStyle(RoundedButtonStyle(.accentColor))
            .opacity(canOpen ? 1 : 0)
        }
        .padding(.horizontal, 49)
        .padding(.vertical, 42)
        .onAppear {
            canOpen = UIApplication.shared.canOpenURL(appStoreLink)
        }
    }
}

struct AppErrorView_Previews: PreviewProvider {
    static var previews: some View {
        AppErrorView()
    }
}
