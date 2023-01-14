// Created 1/13/23
// swift-version:5.0

import SwiftUI

struct AttributedTextView: View {
    let html: String
    
    var body: some View {
        AttributedLabel {
            $0.attributedText = NSAttributedString(html: html)
        }
    }
}

extension NSAttributedString {
    convenience init(html: String)  {
        do {
            let data = Data(html.utf8)
            try self.init(data: data,
                          options: [.documentType: NSAttributedString.DocumentType.html],
                          documentAttributes: nil)
        }
        catch {
            self.init(string: html)
        }
    }
}

// work-around for HTML - https://stackoverflow.com/questions/59531122/how-to-use-attributed-string-in-swiftui
struct AttributedLabel: UIViewRepresentable {

    typealias TheUIView = UILabel
    fileprivate var configuration = { (view: TheUIView) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> TheUIView { TheUIView() }
    func updateUIView(_ uiView: TheUIView, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
    }
}

struct AttributedTextView_Previews: PreviewProvider {
    static var previews: some View {
        AttributedTextView(html: "To <b>withdraw</b> from this study, please contact your Study Contact from the <u><b>Study Info page.</b></u>")
    }
}
