// Created 1/13/23
// swift-version:5.0

import SwiftUI

// TODO: syoung 01/18/2022 Revisit this when no longer supporting iOS 14 - might be handled better with AttributedString and iOS 15?

struct AttributedTextView: View {
    let html: String
    
    @State var htmlText = Text("")
    
    var body: some View {
        htmlText
            .onAppear {
                // Can't build the string while initializing so instead, build on next loop
                DispatchQueue.main.async {
                    htmlText = .init(html: html)
                }
            }
    }
}

fileprivate extension NSAttributedString {
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

fileprivate extension Text {
    init(html: String) {
        self.init("")

        let attributedString = NSAttributedString(html: html)
        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length), options: []) { (attrs, range, _) in

            var chunk = Text(attributedString.attributedSubstring(from: range).string)

            if let color = attrs[NSAttributedString.Key.foregroundColor] as? UIColor {
                chunk  = chunk.foregroundColor(Color(color))
            }

            if let font = attrs[NSAttributedString.Key.font] as? UIFont {
                if font.isBold {
                    chunk = chunk.bold()
                }
                if font.isItalic {
                    chunk = chunk.italic()
                }
            }

            if let underline = attrs[NSAttributedString.Key.underlineStyle] as? NSNumber, underline != 0 {
                chunk = chunk.underline()
            }

            self = self + chunk
        }
    }
}

fileprivate extension UIFont {
    var isBold: Bool {
        fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool {
        fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
}

struct AttributedTextView_Previews: PreviewProvider {
    static var previews: some View {
        AttributedTextView(html: "To <b>withdraw</b> from this study, please contact your Study Contact from the <u><b>Study Info page.</b></u>")
    }
}
