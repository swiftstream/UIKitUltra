#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension WrappedViewControllerable {
    @MainActor
    public func hidden(_ hidden: Bool = true) {
        guard hidden == !protocolView.isHidden else { return }
        protocolView.hidden(hidden)
        #if os(macOS)
        if hidden {
            protocolController?.viewWillDisappear()
            protocolController?.viewDidDisappear()
        } else {
            protocolController?.viewWillAppear()
            protocolController?.viewDidAppear()
        }
        #else
        if hidden {
            protocolController?.viewWillDisappear(false)
            protocolController?.viewDidDisappear(false)
        } else {
            protocolController?.viewWillAppear(false)
            protocolController?.viewDidAppear(false)
        }
        #endif
    }
}
