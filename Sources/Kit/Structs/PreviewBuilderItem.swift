#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if canImport(SwiftUI) && DEBUG
@available(iOS 13.0, macOS 10.15, *)
public protocol PreviewBuilderItem {
    var previewBuilderItems: [Preview] { get }
}

@available(iOS 13.0, macOS 10.15, *)
public struct PreviewBuilderItems: PreviewBuilderItem {
    public let items: [Preview]
    
    public init (items: [Preview]) {
        self.items = items
    }
    
    public var previewBuilderItems: [Preview] { items }
}

@available(iOS 13.0, macOS 10.15, *)
extension Preview: PreviewBuilderItem {
    public var previewBuilderItems: [Preview] { [self] }
}
#endif
#endif
