#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol WrappedViewControllerable {
    var protocolView: UView { get }
    var protocolController: BaseViewController? { get }
}
