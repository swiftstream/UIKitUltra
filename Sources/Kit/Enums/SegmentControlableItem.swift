#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)

#else
import UIKit
#endif

public enum SegmentControlableItem {
    case title(String)
    case image(_UImage)
}
#endif
