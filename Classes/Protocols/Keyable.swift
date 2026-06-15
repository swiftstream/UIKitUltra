#if os(macOS)
import Cocoa

public protocol Keyable: AnyObject {
    @discardableResult
    func key(_ text: String) -> Self
    
    @discardableResult
    func key(_ state: State<String>) -> Self
}

@MainActor
protocol _Keyable: Keyable {
    func _setKey(_ v: String)
}

@MainActor
extension Keyable {
    @discardableResult
    public func key(_ text: String) -> Self {
        guard let s = self as? _Keyable else { return self }
        s._setKey(text)
        return self
    }

    @discardableResult
    public func key(_ state: State<String>) -> Self {
        key(state.wrappedValue)
        state.listen { [weak self] in
            self?.key($0)
        }
        .holdIfOwned(by: self)
        return self
    }
}
#endif
