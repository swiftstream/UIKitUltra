#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol TextBindable {
    @discardableResult
    func bind<A: AnyString>(_ to: UIKitPlus.State<A>) -> Self
}

@MainActor
protocol _TextBindable: TextBindable {
    func _setTextBind<A: AnyString>(_ binding: State<A>?)
}

@available(iOS 13.0, *)
@MainActor
extension TextBindable {
    @discardableResult
    public func bind<A: AnyString>(_ to: State<A>) -> Self {
        guard let s = self as? _TextBindable else { return self }
        s._setTextBind(to)
        return self
    }
}

// for iOS lower than 13
@MainActor
extension _TextBindable {
    @discardableResult
    public func bind<A: AnyString>(_ to: State<A>) -> Self {
        _setTextBind(to)
        return self
    }
}
