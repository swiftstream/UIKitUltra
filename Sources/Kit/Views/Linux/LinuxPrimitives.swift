#if os(Linux) && ULTRA_GTK_BACKEND

import Foundation
import UltraCore
import UltraGTK

private final class GTKDesiredText: @unchecked Sendable {
    private let lock = NSLock()
    private var value: String

    init(_ value: String) {
        self.value = value
    }

    func set(_ value: String) {
        lock.lock()
        self.value = value
        lock.unlock()
    }

    var snapshot: String {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
}

private final class GTKStackDesiredConfiguration: @unchecked Sendable {
    struct Snapshot: Sendable {
        let spacing: Int32
        let margin: Int32
        let centered: Bool
    }

    private let lock = NSLock()
    private var spacing: Int32 = 0
    private var margin: Int32 = 0
    private var centered = false

    func setSpacing(_ value: Int32) {
        lock.lock()
        spacing = value
        lock.unlock()
    }

    func setMargin(_ value: Int32) {
        lock.lock()
        margin = value
        lock.unlock()
    }

    func setCentered() {
        lock.lock()
        centered = true
        lock.unlock()
    }

    var snapshot: Snapshot {
        lock.lock()
        defer { lock.unlock() }
        return Snapshot(spacing: spacing, margin: margin, centered: centered)
    }
}

private final class GTKButtonActionStorage: @unchecked Sendable {
    private let lock = NSLock()
    private weak var button: UButton?
    private var noArgumentHandler: (() -> Void)?
    private var selfHandler: ((UButton) -> Void)?

    func attach(_ button: UButton) {
        lock.lock()
        self.button = button
        lock.unlock()
    }

    @MainActor
    func set(noArgumentHandler: @escaping () -> Void) {
        lock.lock()
        self.noArgumentHandler = noArgumentHandler
        self.selfHandler = nil
        lock.unlock()
    }

    @MainActor
    func set(selfHandler: @escaping (UButton) -> Void) {
        lock.lock()
        self.noArgumentHandler = nil
        self.selfHandler = selfHandler
        lock.unlock()
    }

    @MainActor
    func invoke() {
        lock.lock()
        let noArgumentHandler = self.noArgumentHandler
        let selfHandler = self.selfHandler
        let button = self.button
        lock.unlock()

        if let noArgumentHandler {
            noArgumentHandler()
        } else if let selfHandler, let button {
            selfHandler(button)
        }
    }

    func clear() {
        lock.lock()
        noArgumentHandler = nil
        selfHandler = nil
        button = nil
        lock.unlock()
    }
}

@MainActor
open class UView: GTKView {}

@MainActor
open class UButton: GTKButton {
    private let actionStorage = GTKButtonActionStorage()
    private var attachedRuntime: GTKMainActorRuntime?
    private var signalConnection: GTKSignalConnection?

    public override init(_ label: String) {
        super.init(label)
        actionStorage.attach(self)
    }

    @discardableResult
    public func onAction(_ handler: @escaping () -> Void) -> Self {
        actionStorage.set(noArgumentHandler: handler)
        return self
    }

    @discardableResult
    public func onAction(_ handler: @escaping (UButton) -> Void) -> Self {
        actionStorage.set(selfHandler: handler)
        return self
    }

    deinit {
        signalConnection?.disconnect()
        signalConnection = nil
        actionStorage.clear()
        attachedRuntime = nil
    }
}

@MainActor
open class UText: GTKLabel {
    private let desiredText = GTKDesiredText("")
    private let stateBindingHolder = TempStatesHolder()
    private var attachedRuntime: GTKMainActorRuntime?
    private var textBinding: LinuxGTKFluentPropertyBinding<String>?

    public override init(_ text: String) {
        super.init(text)
        desiredText.set(text)
    }

    public init(_ state: State<String>) {
        super.init(state.wrappedValue)
        desiredText.set(state.wrappedValue)

        let desiredText = self.desiredText
        let binding = LinuxGTKFluentPropertyBinding<String> { [weak self] value in
            self?.text = value
        }
        textBinding = binding
        state.listen { _, newValue in
            desiredText.set(newValue)
            binding.publish(newValue)
        }
        .hold(in: stateBindingHolder)
    }

    private func applyDesiredText() {
        text = desiredText.snapshot
    }

    deinit {
        textBinding?.invalidate()
        attachedRuntime = nil
    }
}

public typealias ULabel = UText

@MainActor
open class UStackView: GTKBox {
    private let desiredConfiguration = GTKStackDesiredConfiguration()
    private let stateBindingHolder = TempStatesHolder()
    private var attachedRuntime: GTKMainActorRuntime?
    private var spacingBindings: [LinuxGTKFluentPropertyBinding<Int32>] = []
    private var marginBindings: [LinuxGTKFluentPropertyBinding<Int32>] = []

    package init(_ orientation: GTKBoxOrientation) {
        super.init(orientation: orientation)
    }

    public init() {
        super.init(orientation: .horizontal)
    }

    public init(@BodyBuilder block: BodyBuilder.SingleView) {
        super.init(orientation: .horizontal)
        _appendBodyBuilderItem(block())
    }

    @discardableResult
    public func spacing(_ value: CGFloat) -> Self {
        let converted = gtkNonNegativeInt32(value)
        desiredConfiguration.setSpacing(converted)
        super.spacing = converted
        return self
    }

    @discardableResult
    public func spacing(_ state: State<CGFloat>) -> Self {
        let converted = gtkNonNegativeInt32(state.wrappedValue)
        desiredConfiguration.setSpacing(converted)
        let configuration = desiredConfiguration
        let binding = LinuxGTKFluentPropertyBinding<Int32> { [weak self] value in
            self?.superSpacing(value)
        }
        spacingBindings.append(binding)
        state.listen { _, newValue in
            let converted = gtkNonNegativeInt32(newValue)
            configuration.setSpacing(converted)
            binding.publish(converted)
        }
        .hold(in: stateBindingHolder)
        if let attachedRuntime {
            binding.attach(to: attachedRuntime)
            applyDesiredConfiguration()
        }
        return self
    }

    @discardableResult
    public func layoutMargin(_ value: CGFloat) -> Self {
        let converted = gtkNonNegativeInt32(value)
        desiredConfiguration.setMargin(converted)
        GTKLayout.setAllSidesMargin(converted, on: self)
        return self
    }

    @discardableResult
    public func layoutMargin(_ state: State<CGFloat>) -> Self {
        let converted = gtkNonNegativeInt32(state.wrappedValue)
        desiredConfiguration.setMargin(converted)
        let configuration = desiredConfiguration
        let binding = LinuxGTKFluentPropertyBinding<Int32> { [weak self] value in
            self?.superMargin(value)
        }
        marginBindings.append(binding)
        state.listen { _, newValue in
            let converted = gtkNonNegativeInt32(newValue)
            configuration.setMargin(converted)
            binding.publish(converted)
        }
        .hold(in: stateBindingHolder)
        if let attachedRuntime {
            binding.attach(to: attachedRuntime)
            applyDesiredConfiguration()
        }
        return self
    }

    @discardableResult
    public func centerInSuperview() -> Self {
        desiredConfiguration.setCentered()
        GTKLayout.center(self)
        return self
    }

    @discardableResult
    public func subviews(@BodyBuilder block: BodyBuilder.SingleView) -> Self {
        _appendBodyBuilderItem(block())
        return self
    }

    package func _appendBodyBuilderItem(_ item: BodyBuilderItemable) {
        for child in item.bodyBuilderItem._flatten() {
            guard let view = child as? GTKView else {
                preconditionFailure("UIKitUltra GTK stack child is not a GTKView")
            }
            append(view)
            if let attachable = view as? _GTKRuntimeAttachable,
               let attachedRuntime {
                attachable._attachGTKRuntime(attachedRuntime)
            }
        }
    }

    private func applyDesiredConfiguration() {
        let snapshot = desiredConfiguration.snapshot
        super.spacing = snapshot.spacing
        GTKLayout.setAllSidesMargin(snapshot.margin, on: self)
        if snapshot.centered {
            GTKLayout.center(self)
        }
    }

    private func superSpacing(_ value: Int32) {
        super.spacing = value
    }

    private func superMargin(_ value: Int32) {
        GTKLayout.setAllSidesMargin(value, on: self)
    }

    deinit {
        spacingBindings.forEach { $0.invalidate() }
        marginBindings.forEach { $0.invalidate() }
        attachedRuntime = nil
    }
}

@MainActor
open class UVStack: UStackView {
    public override init() {
        super.init(.vertical)
    }

    public override init(@BodyBuilder block: BodyBuilder.SingleView) {
        super.init(.vertical)
        _appendBodyBuilderItem(block())
    }
}

@MainActor
open class UHStack: UStackView {
    public override init() {
        super.init(.horizontal)
    }

    public override init(@BodyBuilder block: BodyBuilder.SingleView) {
        super.init(.horizontal)
        _appendBodyBuilderItem(block())
    }
}

@MainActor
extension UStackView: _GTKRuntimeAttachable {
    package func _attachGTKRuntime(_ runtime: GTKMainActorRuntime) {
        if let attachedRuntime {
            precondition(attachedRuntime === runtime, "GTK view attached to a different runtime")
            return
        }
        attachedRuntime = runtime
        spacingBindings.forEach { $0.attach(to: runtime) }
        marginBindings.forEach { $0.attach(to: runtime) }
        applyDesiredConfiguration()
        for child in children {
            (child as? _GTKRuntimeAttachable)?._attachGTKRuntime(runtime)
        }
    }

    package func _detachGTKRuntime() {
        guard attachedRuntime != nil else { return }
        for child in children.reversed() {
            (child as? _GTKRuntimeAttachable)?._detachGTKRuntime()
        }
        spacingBindings.forEach { $0.detach() }
        marginBindings.forEach { $0.detach() }
        attachedRuntime = nil
    }
}

@MainActor
extension UText: _GTKRuntimeAttachable {
    package func _attachGTKRuntime(_ runtime: GTKMainActorRuntime) {
        if let attachedRuntime {
            precondition(attachedRuntime === runtime, "GTK text attached to a different runtime")
            return
        }
        attachedRuntime = runtime
        textBinding?.attach(to: runtime)
        applyDesiredText()
    }

    package func _detachGTKRuntime() {
        textBinding?.detach()
        attachedRuntime = nil
    }
}

@MainActor
extension UButton: _GTKRuntimeAttachable {
    package func _attachGTKRuntime(_ runtime: GTKMainActorRuntime) {
        if let attachedRuntime {
            precondition(attachedRuntime === runtime, "GTK button attached to a different runtime")
            return
        }
        attachedRuntime = runtime
        let actionStorage = actionStorage
        guard let signalConnection = GTKSignalConnection.connectClicked(
            to: self,
            runtime: runtime,
            callback: { [actionStorage] in
                actionStorage.invoke()
            }
        ) else {
            attachedRuntime = nil
            preconditionFailure("Failed to connect GTK button signal")
        }
        self.signalConnection = signalConnection
    }

    package func _detachGTKRuntime() {
        let signalConnection = self.signalConnection
        self.signalConnection = nil
        signalConnection?.disconnect()
        attachedRuntime = nil
    }
}

package func gtkRoundedInt32OrNil(_ value: CGFloat) -> Int32? {
    guard value.isFinite else { return nil }
    let rounded = value.rounded()
    guard rounded >= CGFloat(Int32.min), rounded <= CGFloat(Int32.max) else {
        return nil
    }
    return Int32(rounded)
}

package func gtkPositiveInt32OrNil(_ value: CGFloat) -> Int32? {
    guard let converted = gtkRoundedInt32OrNil(value), converted > 0 else {
        return nil
    }
    return converted
}

package func gtkNonNegativeInt32OrNil(_ value: CGFloat) -> Int32? {
    guard let converted = gtkRoundedInt32OrNil(value), converted >= 0 else {
        return nil
    }
    return converted
}

package func gtkPositiveInt32(_ value: CGFloat) -> Int32 {
    guard let converted = gtkPositiveInt32OrNil(value) else {
        preconditionFailure("Expected a finite positive GTK integer")
    }
    return converted
}

package func gtkNonNegativeInt32(_ value: CGFloat) -> Int32 {
    guard let converted = gtkNonNegativeInt32OrNil(value) else {
        preconditionFailure("Expected a finite non-negative GTK integer")
    }
    return converted
}

#endif
