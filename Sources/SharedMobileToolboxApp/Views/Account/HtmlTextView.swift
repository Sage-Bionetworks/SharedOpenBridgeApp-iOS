// Created 1/13/23
// swift-version:5.0

import SwiftUI

public struct HtmlTextView: View {
    let html: String
    
    public init(html: String) {
        self.html = html
    }
    
    public var body: some View {
        Text(AttributedString(html: html))
    }
}

fileprivate extension AttributedString {
    init(html: String) {
        do {
            let data = Data(html.utf8)
            let str = try NSAttributedString(data: data,
                                             options: [.documentType: NSAttributedString.DocumentType.html],
                                             documentAttributes: nil)
            self.init(str)
        }
        catch {
            self.init(html)
        }
    }
}

struct HtmlTextView_Previews: PreviewProvider {
    static var previews: some View {
        HtmlTextView(html: "To <b>withdraw</b> from this study, <i>please</i> contact your Study Contact from the <u><b>Study Info page.</b></u>")
    }
}
