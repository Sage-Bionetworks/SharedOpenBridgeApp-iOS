//
//  TextEntryLoginView.swift
//
//

import SwiftUI
import BridgeClient
import BridgeClientUI
import SharedMobileUI

struct TextEntryLoginView: View {
    @EnvironmentObject var navigator: PagedNavigationViewModel
    @Binding var value: String
    @Binding var status: ResourceStatus?
    let label: Text
    let error: Text
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            label
                .font(DesignSystem.fontRules.headerFont(at: 5))
                .foregroundColor((status == .failed) ? .errorRed : .textForeground)
            
            TextField("", text: $value, onEditingChanged: { isEditing in
                if isEditing && (status == .failed) {
                    self.status = nil // When the user starts editing, hide the error.
                }
            }, onCommit: {
                self.navigator.goForward()
            })
            .keyboardType(.asciiCapable)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .lineLimit(1)
            .padding(.horizontal)
            .padding(.vertical)
            .border((status == .failed) ? Color.errorRed : Color.sageBlack, width: 1)
            
            if (status == .failed) {
                error
                    .font(DesignSystem.fontRules.bodyFont(at: 1, isEmphasis: false))
                    .foregroundColor(.errorRed)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 12)
            }
            else {
                Spacer()
                    .frame(height: 16)
            }
        }
        .animation(.easeInOut)
    }
}

struct TextEntryLoginView_Preview : View {
    @StateObject var navigator: PagedNavigationViewModel = .init(pageCount: 2, progressHidden: true)
    @State var value: String
    @State var status: ResourceStatus?
    let label: LocalizedStringKey
    let error: LocalizedStringKey
    
    var body: some View {
        TextEntryLoginView(value: $value, status: $status, label: Text(label), error: Text(error))
            .environmentObject(navigator)
    }
}

struct TextEntryLoginView_Previews: PreviewProvider {
    static var previews: some View {
        TextEntryLoginView_Preview(value: "", status: nil, label: "Study ID", error: "This is an error preview. Something went wrong.")
    }
}
