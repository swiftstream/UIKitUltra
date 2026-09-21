#if os(Linux) && ULTRA_GTK_BACKEND

import Foundation
import UltraGTK

@MainActor
package protocol _GTKRuntimeAttachable: AnyObject {
    func _attachGTKRuntime(_ runtime: GTKMainActorRuntime)
    func _detachGTKRuntime()
}

package protocol LinuxGTKFluentPropertyBindingInvalidating: AnyObject {
    func invalidate()
}

package final class LinuxGTKFluentPropertyBinding<Value: Sendable>:
    LinuxGTKFluentPropertyBindingInvalidating,
    @unchecked Sendable
{
    private let lock = NSLock()
    private let applyBody: @MainActor @Sendable (Value) -> Void
    private var runtime: GTKMainActorRuntime?
    private var attachmentEpoch: UInt64 = 0
    private var invalidated = false

    package init(
        applyBody: @escaping @MainActor @Sendable (Value) -> Void
    ) {
        self.applyBody = applyBody
    }

    package func attach(to runtime: GTKMainActorRuntime) {
        lock.lock()
        guard !invalidated else {
            lock.unlock()
            return
        }
        if let current = self.runtime {
            lock.unlock()
            precondition(current === runtime, "GTK binding attached to a different runtime")
            return
        }
        self.runtime = runtime
        attachmentEpoch &+= 1
        lock.unlock()
    }

    package func detach() {
        lock.lock()
        guard !invalidated else {
            lock.unlock()
            return
        }
        runtime = nil
        attachmentEpoch &+= 1
        lock.unlock()
    }

    package func publish(_ value: Value) {
        lock.lock()
        guard !invalidated, let runtime else {
            lock.unlock()
            return
        }
        let epoch = attachmentEpoch
        lock.unlock()

        guard runtime.isActive else { return }

        if runtime.isProcessEntryThread {
            runtime.withValidatedMainActor {
                self.applyIfValid(value, runtime: runtime, epoch: epoch)
            }
            return
        }

        runtime.submit { [weak self] in
            self?.applyIfValid(value, runtime: runtime, epoch: epoch)
        }
    }

    package func invalidate() {
        lock.lock()
        invalidated = true
        runtime = nil
        attachmentEpoch &+= 1
        lock.unlock()
    }

    @MainActor
    private func applyIfValid(
        _ value: Value,
        runtime: GTKMainActorRuntime,
        epoch: UInt64
    ) {
        lock.lock()
        let valid = !invalidated
            && self.runtime === runtime
            && attachmentEpoch == epoch
        lock.unlock()

        guard valid, runtime.isActive else { return }
        applyBody(value)
    }
}

#endif
