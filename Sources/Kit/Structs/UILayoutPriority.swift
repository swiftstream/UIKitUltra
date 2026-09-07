#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

public struct UILayoutPriority : Hashable, Equatable, RawRepresentable {
    public var rawValue: Float
    
    public init(_ rawValue: Float) { self.rawValue = rawValue }
    public init(rawValue: Float) { self.rawValue = rawValue }
}
extension UILayoutPriority {
    // This is the priority level with which a button resists compressing its content.
    public static var defaultHigh: UILayoutPriority { .init(rawValue: 1000) }
    
    // This is the priority level at which a button hugs its contents horizontally.
    public static var defaultLow: UILayoutPriority { .init(rawValue: 10) }
}
#endif
#endif
