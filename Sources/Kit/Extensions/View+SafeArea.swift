#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
extension BaseView {
    #if os(macOS)
    public struct ViewEdgeInsets {
        public var top: CGFloat = 0
        public var left: CGFloat = 0
        public var bottom: CGFloat = 0
        public var right: CGFloat = 0

        public init() {}
    }
    
    public var safeInsets: ViewEdgeInsets {
        ViewEdgeInsets()
    }
    #else
    public var safeInsets: UIEdgeInsets {
        var insets = UIEdgeInsets()
        if #available(iOS 11.0, *) {
            insets.top = safeAreaInsets.top
        }
        if #available(iOS 11.0, *) {
            insets.left = safeAreaInsets.left
        }
        if #available(iOS 11.0, *) {
            insets.right = safeAreaInsets.right
        }
        if #available(iOS 11.0, *) {
            insets.bottom = safeAreaInsets.bottom
        }
        return insets
    }
    #endif
    
    @MainActor
    public class SafeAnchors {
        let view: BaseView
        
        init (_ view: BaseView) {
            self.view = view
        }
        
        public var leadingAnchor: NSLayoutXAxisAnchor {
            #if !os(macOS)
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.leadingAnchor
            }
            #endif
            return view.leadingAnchor
        }
        
        public var trailingAnchor: NSLayoutXAxisAnchor {
            #if !os(macOS)
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.trailingAnchor
            }
            #endif
            return view.trailingAnchor
        }
        
        public var leftAnchor: NSLayoutXAxisAnchor {
            #if !os(macOS)
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.leftAnchor
            }
            #endif
            return view.leftAnchor
        }
        
        public var rightAnchor: NSLayoutXAxisAnchor {
            #if !os(macOS)
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.rightAnchor
            }
            #endif
            return view.rightAnchor
        }
        
        public var topAnchor: NSLayoutYAxisAnchor {
            #if !os(macOS)
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.topAnchor
            }
            #endif
            return view.topAnchor
        }
        
        public var bottomAnchor: NSLayoutYAxisAnchor {
            #if !os(macOS)
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.bottomAnchor
            }
            #endif
            return view.bottomAnchor
        }
        
        public var widthAnchor: NSLayoutDimension {
            #if !os(macOS)
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.widthAnchor
            }
            #endif
            return view.widthAnchor
        }
        
        public var heightAnchor: NSLayoutDimension {
            #if !os(macOS)
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.heightAnchor
            }
            #endif
            return view.heightAnchor
        }
        
        public var centerXAnchor: NSLayoutXAxisAnchor {
            #if !os(macOS)
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.centerXAnchor
            }
            #endif
            return view.centerXAnchor
        }
        
        public var centerYAnchor: NSLayoutYAxisAnchor {
            #if !os(macOS)
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.centerYAnchor
            }
            #endif
            return view.centerYAnchor
        }
    }
    
    public var safeArea: SafeAnchors { .init(self) }
}
#endif
