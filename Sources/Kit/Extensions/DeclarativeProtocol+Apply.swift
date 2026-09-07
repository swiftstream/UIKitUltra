#if os(macOS) || os(iOS) || os(tvOS)
//
// Created by Kevin Guo on 2022/1/3.
//

extension DeclarativeProtocol {
    /// Helper method where you could change the object non-declarative way
    ///
    /// ```swift
    /// view1.apply {
    ///     $0.backgroundColor = .red
    /// }
    /// ```
    @discardableResult
    public func apply(_ closure: (V) -> Void) -> Self {
        closure(declarativeView)
        return self
    }
}
#endif
