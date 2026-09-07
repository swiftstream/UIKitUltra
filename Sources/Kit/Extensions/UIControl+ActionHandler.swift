#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit
import ObjectiveC

extension UIControl {
    private final class ActionHandlerBox {
        let action: () -> Void

        init(_ action: @escaping () -> Void) {
            self.action = action
        }
    }

    private var actionHandlerKey: UnsafeRawPointer {
        UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
    }

    private func actionHandler(action: (() -> Void)? = nil) {
        if let action = action {
            objc_setAssociatedObject(
                self,
                actionHandlerKey,
                ActionHandlerBox(action),
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        } else {
            (objc_getAssociatedObject(self, actionHandlerKey) as? ActionHandlerBox)?.action()
        }
    }
    
    @objc func triggerActionHandler() {
        actionHandler()
    }
    
    func actionHandler(controlEvents control: UIControl.Event, forAction action: @escaping () -> Void) {
        actionHandler(action: action)
        addTarget(self, action: #selector(triggerActionHandler), for: control)
    }
}
#endif
#endif
