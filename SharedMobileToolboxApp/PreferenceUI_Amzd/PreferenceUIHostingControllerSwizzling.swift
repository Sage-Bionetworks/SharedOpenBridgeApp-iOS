import SwiftUI

/// If you are unable to access window.rootViewController this is a method using swizzling
struct PreferenceUIHostingControllerView<Wrapped: View>: UIViewControllerRepresentable {
    init(@ViewBuilder wrappedView: @escaping () -> Wrapped) {
        _ = UIViewController.preferenceSwizzling
        self.wrappedView = wrappedView
    }
    
    var wrappedView: () -> Wrapped
    
    func makeUIViewController(context: Context) -> PreferenceUIHostingController {
        PreferenceUIHostingController(wrappedView: wrappedView())
    }
    
    func updateUIViewController(_ uiViewController: PreferenceUIHostingController, context: Context) {}
}

extension UIViewController {
    static var preferenceSwizzling: Void = {
        Swizzle(UIViewController.self) {
            #selector(getter: childForScreenEdgesDeferringSystemGestures) <-> #selector(childForScreenEdgesDeferringSystemGestures_Amzd)
            #selector(getter: childForHomeIndicatorAutoHidden) <-> #selector(childForHomeIndicatorAutoHidden_Amzd)
        }
    }()
}

extension UIViewController {
    @objc func childForScreenEdgesDeferringSystemGestures_Amzd() -> UIViewController? {
        if self is PreferenceUIHostingController {
            // dont continue searching
            return nil
        } else {
            return search()
        }
    }
    @objc func childForHomeIndicatorAutoHidden_Amzd() -> UIViewController? {
        if self is PreferenceUIHostingController {
            // dont continue searching
            return nil
        } else {
            return search()
        }
    }
    
    private func search() -> PreferenceUIHostingController? {
        if let result = children.compactMap({ $0 as? PreferenceUIHostingController }).first {
            return result
        }
        
        for child in children {
            if let result = child.search() {
                return result
            }
        }
        
        return nil
    }
}
