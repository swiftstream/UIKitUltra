#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

public typealias BaseView = NSView
#else
import UIKit

public typealias BaseView = UIView
#endif
#endif

#if os(Linux) && ULTRA_GTK_BACKEND
import UltraGTK

public typealias BaseView = GTKView
#endif
