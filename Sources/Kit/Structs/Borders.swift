#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public class Borders {
    public enum Side {
        case top, left, right, bottom
    }
    
    var views: [Side: UView] = [:]
}
#endif
