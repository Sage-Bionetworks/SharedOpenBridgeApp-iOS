//
//  ExternalIdLoginView.swift
//
//

import SwiftUI
import BridgeClient
import BridgeClientUI
import SharedMobileUI

public struct ExternalIdLoginView: View {
    
    @Binding var externalId: String
    @Binding var status: ResourceStatus?
    @Binding var studyInfo: StudyObserver?
    
    private var studyId: String? {
        studyInfo?.identifier
    }
    
    private var studyName: String {
        studyInfo?.name ?? Bundle.localizedAppName
    }

    public var body: some View {
        VStack(spacing: 0) {
            
            VStack(alignment: .leading, spacing: 8) {
                Text(studyName)
                    .font(DesignSystem.fontRules.headerFont(at: 3))
                    .fixedSize(horizontal: false, vertical: true)
                studyHeader()
                    .font(DesignSystem.fontRules.bodyFont(at: 1, isEmphasis: false))
                    .opacity(studyId != nil ? 1 : 0)
            }
            .foregroundColor(.textForeground)
            .padding(.horizontal, 32)
            .padding(.bottom, 34)
            
            TextEntryLoginView(value: $externalId, status: $status,
                               label: Text("Participant ID", bundle: .module),
                               error: Text("Sorry, we cannot find this Participant ID. Please try again or contact your Study Coordinator.", bundle: .module))
        }
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder
    func studyHeader() -> some View {
        let currentStudy = " \(studyId ?? "")"
        Text("Study ID:", bundle: .module) +
        Text(currentStudy)
    }
}

struct ExternalIdLoginView_Preview : View {
    @State var externalId: String = ""
    @State var status: ResourceStatus?
    @State var studyInfo: StudyObserver?
    
    init(studyInfo: BridgeClient.StudyInfo) {
        self.studyInfo = StudyObserver(identifier: studyInfo.identifier!)
        self.studyInfo!.update(from: studyInfo)
    }
    
    var body: some View {
        ExternalIdLoginView(externalId: $externalId, status: $status, studyInfo: $studyInfo)
    }
}

struct ExternalIdLoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExternalIdLoginView_Preview(studyInfo: previewStudyInfo_ExternalId)
        }
    }
}
