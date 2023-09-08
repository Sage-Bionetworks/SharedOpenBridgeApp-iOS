//
//  SettingsView.swift
//

import SwiftUI
import SharedMobileUI
import MobilePassiveData
import AssessmentModel

struct SettingsView : View {
    let node: ContentNode
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            PermissionsView(node: node)
                .padding(.top, 20)
            Button(action: openSettings) {
                Text("Change", bundle: .module)
            }
            .buttonStyle(RoundedButtonStyle(self.backgroundColor))
            .padding(.top, 32)
            .padding(.bottom, 41)
        }
    }
    
    var backgroundColor: Color {
        switch node.standardPermissionType {
        case .notifications:
            return .btnLavender
        case .motion:
            return .btnOrange
        case .microphone:
            return .btnBlue
        case .locationWhenInUse, .location:
            return .btnGreen
        default:
            return .accentColor
        }
    }
    
    func openSettings() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier,
            let url = URL(string:UIApplication.openSettingsURLString + bundleIdentifier),
              UIApplication.shared.canOpenURL(url)
        else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(node: notificationsPermissionNode)
    }
}
