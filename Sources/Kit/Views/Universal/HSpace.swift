#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@available(*, deprecated, renamed: "UHSpace")
@MainActor public func HSpace(_ width: CGFloat) -> UView { UHSpace(width) }
@available(*, deprecated, renamed: "UHSpace")
@MainActor public func HSpace(_ width: State<CGFloat>) -> UView { UHSpace(width) }

@MainActor public func UHSpace(_ width: CGFloat) -> UView { UView().width(width) }
@MainActor public func UHSpace(_ width: State<CGFloat>) -> UView { UView().width(width) }
#endif
