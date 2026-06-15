#if os(macOS)
import AppKit
#else
import UIKit
#endif

@available(*, deprecated, renamed: "USpace")
@MainActor
public func Space() -> UView { USpace() }

@MainActor
public func USpace() -> UView { UView() }
