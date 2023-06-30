//
//  LaunchView.swift
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        ZStack {
            Image("Launching")
                .fixedSize()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
