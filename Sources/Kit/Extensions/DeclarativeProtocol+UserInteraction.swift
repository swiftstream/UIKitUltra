#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

extension DeclarativeProtocol {
    public var userInteraction: State<Bool> { properties.$userInteraction }
    
    @discardableResult
    public func userInteraction(_ enabled: Bool = true) -> Self {
        declarativeView.isUserInteractionEnabled = enabled
        properties.userInteraction = enabled
        return self
    }
    
    @discardableResult
    public func userInteraction(_ state: State<Bool>) -> Self {
        declarativeView.isUserInteractionEnabled = state.wrappedValue
        properties.userInteraction = state.wrappedValue
        state.listen { [weak self] new in
            self?.declarativeView.isUserInteractionEnabled = new
            self?.properties.userInteraction = new
        }
        .hold(in: _declarativeView._properties.stateBindingHolder)
        return self
    }
}
#endif
#endif
