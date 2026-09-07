#if os(macOS) || os(iOS) || os(tvOS)
extension DeclarativeProtocol {
    internal var _declarativeView: DeclarativeProtocolInternal { self as! DeclarativeProtocolInternal }
}
#endif
