#if os(Linux) && ULTRA_GTK_BACKEND

import Foundation
import UltraCore
import UltraGTK

@MainActor
public final class Window: AppBuilderContent {
    public var appBuilderContent: AppBuilderItem { .windows([self]) }

    private var bodyResult: BodyBuilderItemable?
    private var retainedRoot: BodyBuilderItemable?
    private var hasInstalledGTKHierarchy = false
    private let desiredConfiguration = GTKWindowDesiredConfiguration()
    private let stateBindingHolder = TempStatesHolder()
    private var nativeWindow: GTKWindow?
    private var runtime: GTKMainActorRuntime?
    private var attachBindings: [(GTKMainActorRuntime) -> Void] = []
    private var detachBindings: [() -> Void] = []
    private var invalidateBindingClosures: [() -> Void] = []

    public init() {}

    public init(@BodyBuilder block: BodyBuilder.SingleView) {
        bodyResult = block()
    }

    @discardableResult
    public func title(_ value: String) -> Self {
        desiredConfiguration.setTitle(value)
        applyTitleIfInstalled(value)
        return self
    }

    @discardableResult
    public func title(_ state: UState<String>) -> Self {
        desiredConfiguration.setTitle(state.wrappedValue)
        let configuration = desiredConfiguration
        let binding = LinuxGTKFluentPropertyBinding<String> { [weak self] value in
            self?.applyTitleIfInstalled(value)
        }
        retain(binding)
        state.listen { _, newValue in
            configuration.setTitle(newValue)
            binding.publish(newValue)
        }
        .hold(in: stateBindingHolder)
        if let runtime {
            binding.attach(to: runtime)
            applyDesiredConfiguration()
        }
        return self
    }

    @discardableResult
    public func size(_ value: CGFloat) -> Self {
        let converted = gtkPositiveInt32(value)
        return size(converted, converted)
    }

    @discardableResult
    public func size(_ state: State<CGFloat>) -> Self {
        let converted = gtkPositiveInt32(state.wrappedValue)
        desiredConfiguration.setSize(width: converted, height: converted)
        let configuration = desiredConfiguration
        let binding = LinuxGTKFluentPropertyBinding<(Int32, Int32)> { [weak self] pair in
            self?.applySizeIfInstalled(width: pair.0, height: pair.1)
        }
        retain(binding)
        state.listen { _, newValue in
            let converted = gtkPositiveInt32(newValue)
            configuration.setSize(width: converted, height: converted)
            binding.publish((converted, converted))
        }
        .hold(in: stateBindingHolder)
        if let runtime {
            binding.attach(to: runtime)
            applyDesiredConfiguration()
        }
        return self
    }

    @discardableResult
    public func size(_ width: CGFloat, _ height: CGFloat) -> Self {
        let convertedWidth = gtkPositiveInt32(width)
        let convertedHeight = gtkPositiveInt32(height)
        return size(convertedWidth, convertedHeight)
    }

    @discardableResult
    public func size(_ width: State<CGFloat>, _ height: State<CGFloat>) -> Self {
        let convertedWidth = gtkPositiveInt32(width.wrappedValue)
        let convertedHeight = gtkPositiveInt32(height.wrappedValue)
        desiredConfiguration.setSize(width: convertedWidth, height: convertedHeight)

        let widthConfiguration = desiredConfiguration
        let widthBinding = LinuxGTKFluentPropertyBinding<(Int32, Int32)> { [weak self] pair in
            self?.applySizeIfInstalled(width: pair.0, height: pair.1)
        }
        retain(widthBinding)
        width.listen { _, newValue in
            let converted = gtkPositiveInt32(newValue)
            widthConfiguration.setWidth(converted)
            bindingPublish(widthBinding, configuration: widthConfiguration)
        }
        .hold(in: stateBindingHolder)

        let heightConfiguration = desiredConfiguration
        let heightBinding = LinuxGTKFluentPropertyBinding<(Int32, Int32)> { [weak self] pair in
            self?.applySizeIfInstalled(width: pair.0, height: pair.1)
        }
        retain(heightBinding)
        height.listen { _, newValue in
            let converted = gtkPositiveInt32(newValue)
            heightConfiguration.setHeight(converted)
            bindingPublish(heightBinding, configuration: heightConfiguration)
        }
        .hold(in: stateBindingHolder)

        if let runtime {
            widthBinding.attach(to: runtime)
            heightBinding.attach(to: runtime)
            applyDesiredConfiguration()
        }
        return self
    }

    @discardableResult
    public func body(@BodyBuilder block: BodyBuilder.SingleView) -> Self {
        precondition(
            !hasInstalledGTKHierarchy,
            "Ultra GTK Window body cannot be changed after installation"
        )
        bodyResult = block()
        return self
    }

    package func _installGTKHierarchy(
        into nativeWindow: GTKWindow,
        runtime: GTKMainActorRuntime
    ) {
        precondition(
            !hasInstalledGTKHierarchy,
            "Ultra GTK Window hierarchy was installed more than once"
        )
        hasInstalledGTKHierarchy = true
        self.nativeWindow = nativeWindow
        self.runtime = runtime

        attachBindings.forEach { $0(runtime) }
        applyDesiredConfiguration()

        guard let bodyResult else {
            nativeWindow.setChild(nil)
            return
        }

        let roots = bodyResult.bodyBuilderItem._flatten()
        precondition(
            roots.count <= 1,
            "Ultra GTK Window requires exactly one effective root view"
        )
        guard let root = roots.first else {
            nativeWindow.setChild(nil)
            return
        }
        guard let rootView = root as? GTKView else {
            preconditionFailure("Unsupported Ultra GTK public root view")
        }

        retainedRoot = root
        nativeWindow.setChild(rootView)
        (rootView as? _GTKRuntimeAttachable)?._attachGTKRuntime(runtime)
    }

    package func _teardownGTKHierarchy() {
        guard hasInstalledGTKHierarchy else { return }
        if let rootView = retainedRoot as? _GTKRuntimeAttachable {
            rootView._detachGTKRuntime()
        }
        detachBindings.forEach { $0() }
        invalidateBindingClosures.forEach { $0() }
        stateBindingHolder.invalidateStates()
        nativeWindow?.setChild(nil)
        retainedRoot = nil
        nativeWindow = nil
        runtime = nil
        attachBindings.removeAll(keepingCapacity: false)
        detachBindings.removeAll(keepingCapacity: false)
        invalidateBindingClosures.removeAll(keepingCapacity: false)
        hasInstalledGTKHierarchy = false
    }

    private func size(_ width: Int32, _ height: Int32) -> Self {
        desiredConfiguration.setSize(width: width, height: height)
        applySizeIfInstalled(width: width, height: height)
        return self
    }

    private func applyDesiredConfiguration() {
        let snapshot = desiredConfiguration.snapshot
        if let title = snapshot.title {
            applyTitleIfInstalled(title)
        }
        if let width = snapshot.width, let height = snapshot.height {
            applySizeIfInstalled(width: width, height: height)
        }
    }

    private func applyTitleIfInstalled(_ title: String) {
        guard let nativeWindow, runtime != nil else { return }
        nativeWindow.title = title
    }

    private func applySizeIfInstalled(width: Int32, height: Int32) {
        guard let nativeWindow, runtime != nil else { return }
        nativeWindow.setDefaultSize(width: width, height: height)
    }

    private func retain<Value>(_ binding: LinuxGTKFluentPropertyBinding<Value>) {
        attachBindings.append { runtime in binding.attach(to: runtime) }
        detachBindings.append { binding.detach() }
        invalidateBindingClosures.append { binding.invalidate() }
    }
}

private final class GTKWindowDesiredConfiguration: @unchecked Sendable {
    struct Snapshot: Sendable {
        let title: String?
        let width: Int32?
        let height: Int32?
    }

    private let lock = NSLock()
    private var title: String?
    private var width: Int32?
    private var height: Int32?

    var snapshot: Snapshot {
        lock.lock()
        defer { lock.unlock() }
        return Snapshot(title: title, width: width, height: height)
    }

    func setTitle(_ value: String) {
        lock.lock()
        title = value
        lock.unlock()
    }

    func setSize(width: Int32, height: Int32) {
        lock.lock()
        self.width = width
        self.height = height
        lock.unlock()
    }

    func setWidth(_ value: Int32) {
        lock.lock()
        width = value
        lock.unlock()
    }

    func setHeight(_ value: Int32) {
        lock.lock()
        height = value
        lock.unlock()
    }
}

private func bindingPublish(
    _ binding: LinuxGTKFluentPropertyBinding<(Int32, Int32)>,
    configuration: GTKWindowDesiredConfiguration
) {
    let snapshot = configuration.snapshot
    binding.publish((snapshot.width ?? 0, snapshot.height ?? 0))
}

#endif
