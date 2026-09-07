#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension BaseView {
    public func addSubview(_ views: [BaseView]) {
        views.forEach { self.addSubview($0) }
    }
    
    public func addSubview(_ views: BaseView...) {
        addSubview(views)
    }
    
    public func addSubview<V>(_ view: ()->(V)) where V: DeclarativeProtocol {
        body { view().declarativeView }
    }
}


#endif
