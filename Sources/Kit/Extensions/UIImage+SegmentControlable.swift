#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension _UImage: SegmentControlable {
    public var item: SegmentControlableItem { .image(self) }
}
#endif
