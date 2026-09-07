#if os(macOS) || os(iOS) || os(tvOS)
extension DeclarativeProtocol {
    public func itself(_ itself: inout Self?) -> Self {
        itself = self
        return self
    }
}
#endif
