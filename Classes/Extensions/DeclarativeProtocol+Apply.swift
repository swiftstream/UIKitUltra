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
    public func apply(_ closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}
