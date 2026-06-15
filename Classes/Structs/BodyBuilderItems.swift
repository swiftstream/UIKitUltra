#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public struct BodyBuilderItems: BodyBuilderItemable {
    var items: [BodyBuilderItemable] = []
    
    public var bodyBuilderItem: BodyBuilderItem {
        .nested(items)
    }
}
