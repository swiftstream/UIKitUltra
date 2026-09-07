#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

public struct ImageReloadingStyle: Equatable {
    let value: Int
    
    public init (_ value: Int) {
        self.value = value
    }
    
    /// Releases image to nil or default before loading the new one
    public static var release: ImageReloadingStyle { .init(0) }
    
    /// Immediately changes image to the new one
    public static var immediate: ImageReloadingStyle { .init(1) }
    
    /// Shows next image through the fade animation
    public static var fade: ImageReloadingStyle { .init(2) }
    
    // MARK: Equatable
    
    public static func == (lhs: ImageReloadingStyle, rhs: ImageReloadingStyle) -> Bool {
        lhs.value == rhs.value
    }
}
#endif
