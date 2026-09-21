#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
import UniformTypeIdentifiers

/// A declarative wrapper around `NSOpenPanel` for Ultra-first macOS flows.
@MainActor
public final class OpenPanel {
    /// The native panel owned by this wrapper.
    public let panel: NSOpenPanel

    private let stateBindingHolder = TempStatesHolder()

    /// Creates an open panel wrapper.
    public init(_ panel: NSOpenPanel = NSOpenPanel()) {
        self.panel = panel
    }

    /// Sets the identifier used by AppKit to persist this panel's location.
    ///
    /// AppKit permits changing the identifier only during the configuration
    /// phase, before the panel is presented, so this is intentionally scalar
    /// only.
    @discardableResult
    public func identifier(_ value: NSUserInterfaceItemIdentifier?) -> Self {
        panel.identifier = value
        return self
    }

    /// Sets the delegate used for native URL validation and selection events.
    ///
    /// Delegates are lifecycle/configuration objects rather than value state;
    /// Ultra therefore preserves AppKit's weak, scalar delegate property
    /// instead of inventing a state overload.
    @discardableResult
    public func delegate(_ value: (any NSOpenSavePanelDelegate)?) -> Self {
        panel.delegate = value
        return self
    }

    /// Sets the content types enabled by the panel.
    @available(macOS 11.0, *)
    @discardableResult
    public func allowedContentTypes(_ value: [UTType]) -> Self {
        panel.allowedContentTypes = value
        return self
    }

    /// Binds enabled content types one way to a state.
    ///
    /// The current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown.
    @available(macOS 11.0, *)
    @discardableResult
    public func allowedContentTypes(_ state: UState<[UTType]>) -> Self {
        _ = allowedContentTypes(state.wrappedValue)
        state.listen { [weak self] in _ = self?.allowedContentTypes($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets the legacy file-type filters used before `allowedContentTypes`.
    ///
    /// Prefer `allowedContentTypes(_:)` on macOS 11 and later. This deprecated
    /// bridge remains available for the package's macOS 10.15 deployment
    /// target and forwards directly to AppKit.
    @available(macOS, introduced: 10.3, deprecated: 12.0,
        message: "Use allowedContentTypes(_:) on macOS 11 and later")
    @discardableResult
    public func allowedFileTypes(_ value: [String]?) -> Self {
        panel.allowedFileTypes = value
        return self
    }

    /// Binds the legacy file-type filters one way to a state.
    ///
    /// The current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown. Prefer `allowedContentTypes(_:)`
    /// on macOS 11 and later.
    @available(macOS, introduced: 10.3, deprecated: 12.0,
        message: "Use allowedContentTypes(_:) on macOS 11 and later")
    @discardableResult
    public func allowedFileTypes(_ state: UState<[String]?>) -> Self {
        _ = allowedFileTypes(state.wrappedValue)
        state.listen { [weak self] in _ = self?.allowedFileTypes($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets the panel's accessory view.
    @discardableResult
    public func accessoryView(_ value: NSView?) -> Self {
        panel.accessoryView = value
        return self
    }

    /// Binds the panel's accessory view one way to an optional view state.
    ///
    /// The current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown.
    @discardableResult
    public func accessoryView(_ state: UState<NSView?>) -> Self {
        _ = accessoryView(state.wrappedValue)
        state.listen { [weak self] in _ = self?.accessoryView($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets whether the panel displays the New Folder control.
    @discardableResult
    public func canCreateDirectories(_ value: Bool = true) -> Self {
        panel.canCreateDirectories = value
        return self
    }

    /// Binds New Folder control visibility one way to a Boolean state.
    ///
    /// The current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown.
    @discardableResult
    public func canCreateDirectories(_ state: UState<Bool>) -> Self {
        _ = canCreateDirectories(state.wrappedValue)
        state.listen { [weak self] in _ = self?.canCreateDirectories($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets whether file packages can be navigated as directories.
    @discardableResult
    public func treatsFilePackagesAsDirectories(_ value: Bool = true) -> Self {
        panel.treatsFilePackagesAsDirectories = value
        return self
    }

    /// Binds package-navigation behavior one way to a Boolean state.
    ///
    /// The current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown.
    @discardableResult
    public func treatsFilePackagesAsDirectories(_ state: UState<Bool>) -> Self {
        _ = treatsFilePackagesAsDirectories(state.wrappedValue)
        state.listen { [weak self] in _ = self?.treatsFilePackagesAsDirectories($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets whether files may be selected.
    @discardableResult
    public func canChooseFiles(_ value: Bool = true) -> Self {
        panel.canChooseFiles = value
        return self
    }

    /// Binds file-selection permission to a Boolean state. The current value
    /// is applied immediately; repeated calls add bindings held by this
    /// wrapper until teardown.
    @discardableResult
    public func canChooseFiles(_ state: UState<Bool>) -> Self {
        _ = canChooseFiles(state.wrappedValue)
        state.listen { [weak self] in _ = self?.canChooseFiles($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets whether directories may be selected.
    @discardableResult
    public func canChooseDirectories(_ value: Bool = true) -> Self {
        panel.canChooseDirectories = value
        return self
    }

    /// Binds directory-selection permission to a Boolean state. The current
    /// value is applied immediately; repeated calls add bindings held by this
    /// wrapper until teardown.
    @discardableResult
    public func canChooseDirectories(_ state: UState<Bool>) -> Self {
        _ = canChooseDirectories(state.wrappedValue)
        state.listen { [weak self] in _ = self?.canChooseDirectories($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets whether more than one URL may be selected.
    @discardableResult
    public func allowsMultipleSelection(_ value: Bool = true) -> Self {
        panel.allowsMultipleSelection = value
        return self
    }

    /// Binds multiple-selection permission to a Boolean state. The current
    /// value is applied immediately; repeated calls add bindings held by this
    /// wrapper until teardown.
    @discardableResult
    public func allowsMultipleSelection(_ state: UState<Bool>) -> Self {
        _ = allowsMultipleSelection(state.wrappedValue)
        state.listen { [weak self] in _ = self?.allowsMultipleSelection($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets whether aliases are resolved before URLs are returned.
    @discardableResult
    public func resolvesAliases(_ value: Bool = true) -> Self {
        panel.resolvesAliases = value
        return self
    }

    /// Binds alias-resolution behavior to a Boolean state. The current value
    /// is applied immediately; repeated calls add bindings held by this
    /// wrapper until teardown.
    @discardableResult
    public func resolvesAliases(_ state: UState<Bool>) -> Self {
        _ = resolvesAliases(state.wrappedValue)
        state.listen { [weak self] in _ = self?.resolvesAliases($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets the panel title.
    @discardableResult
    public func title(_ value: String?) -> Self {
        panel.title = value
        return self
    }

    /// Binds the panel title one way to an optional string state.
    ///
    /// The current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown.
    @discardableResult
    public func title(_ state: UState<String?>) -> Self {
        _ = title(state.wrappedValue)
        state.listen { [weak self] in _ = self?.title($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets whether hidden files are displayed.
    @discardableResult
    public func showsHiddenFiles(_ value: Bool = true) -> Self {
        panel.showsHiddenFiles = value
        return self
    }

    /// Binds hidden-file visibility one way to a Boolean state.
    ///
    /// The current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown.
    @discardableResult
    public func showsHiddenFiles(_ state: UState<Bool>) -> Self {
        _ = showsHiddenFiles(state.wrappedValue)
        state.listen { [weak self] in _ = self?.showsHiddenFiles($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets whether the panel resolves ubiquitous document conflicts.
    @available(macOS 10.10, *)
    @discardableResult
    public func canResolveUbiquitousConflicts(_ value: Bool = true) -> Self {
        panel.canResolveUbiquitousConflicts = value
        return self
    }

    /// Binds ubiquitous-conflict resolution one way to a Boolean state.
    ///
    /// The current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown.
    @available(macOS 10.10, *)
    @discardableResult
    public func canResolveUbiquitousConflicts(_ state: UState<Bool>) -> Self {
        _ = canResolveUbiquitousConflicts(state.wrappedValue)
        state.listen { [weak self] in _ = self?.canResolveUbiquitousConflicts($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets whether the panel downloads ubiquitous contents before opening.
    @available(macOS 10.10, *)
    @discardableResult
    public func canDownloadUbiquitousContents(_ value: Bool = true) -> Self {
        panel.canDownloadUbiquitousContents = value
        return self
    }

    /// Binds ubiquitous-content downloading one way to a Boolean state.
    ///
    /// The current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown.
    @available(macOS 10.10, *)
    @discardableResult
    public func canDownloadUbiquitousContents(_ state: UState<Bool>) -> Self {
        _ = canDownloadUbiquitousContents(state.wrappedValue)
        state.listen { [weak self] in _ = self?.canDownloadUbiquitousContents($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets whether the accessory view is disclosed.
    @available(macOS 10.11, *)
    @discardableResult
    public func accessoryViewDisclosed(_ value: Bool = true) -> Self {
        panel.isAccessoryViewDisclosed = value
        return self
    }

    /// Binds accessory disclosure one way to a Boolean state.
    ///
    /// The current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown.
    @available(macOS 10.11, *)
    @discardableResult
    public func accessoryViewDisclosed(_ state: UState<Bool>) -> Self {
        _ = accessoryViewDisclosed(state.wrappedValue)
        state.listen { [weak self] in _ = self?.accessoryViewDisclosed($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets the panel's action-button title.
    @discardableResult
    public func prompt(_ value: String?) -> Self {
        panel.prompt = value
        return self
    }

    /// Binds the panel's action-button title to an optional string state. The
    /// current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown.
    @discardableResult
    public func prompt(_ state: UState<String?>) -> Self {
        _ = prompt(state.wrappedValue)
        state.listen { [weak self] in _ = self?.prompt($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets explanatory text shown below the panel title.
    @discardableResult
    public func message(_ value: String?) -> Self {
        panel.message = value
        return self
    }

    /// Binds explanatory panel text to an optional string state. The current
    /// value is applied immediately; repeated calls add bindings held by this
    /// wrapper until teardown.
    @discardableResult
    public func message(_ state: UState<String?>) -> Self {
        _ = message(state.wrappedValue)
        state.listen { [weak self] in _ = self?.message($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets the initial directory displayed by the panel.
    @discardableResult
    public func directoryURL(_ value: URL?) -> Self {
        panel.directoryURL = value
        return self
    }

    /// Runs the panel modally and returns the response and selected URLs.
    public func runModal() -> (NSApplication.ModalResponse, [URL]) {
        let response = panel.runModal()
        return (response, panel.urls)
    }

    /// Presents the panel as an application-modal sheet.
    @discardableResult
    public func beginSheetModal(
        for window: NSWindow,
        completion: @escaping (NSApplication.ModalResponse, [URL]) -> Void
    ) -> Self {
        panel.beginSheetModal(for: window) { [weak panel] response in
            completion(response, panel?.urls ?? [])
        }
        return self
    }

    /// Validates and refreshes the panel's visible columns.
    @discardableResult
    public func validateVisibleColumns() -> Self {
        panel.validateVisibleColumns()
        return self
    }

    /// Presents the panel as a modeless window and returns selected URLs.
    @discardableResult
    public func begin(
        completion: @escaping (NSApplication.ModalResponse, [URL]) -> Void
    ) -> Self {
        panel.begin { [weak panel] response in
            completion(response, panel?.urls ?? [])
        }
        return self
    }

    /// The first selected URL, or `nil` when no selection exists.
    public var url: URL? { panel.url }

    /// All selected URLs in AppKit's native order.
    public var urls: [URL] { panel.urls }

    /// Activates the panel's default action button.
    @discardableResult
    public func ok() -> Self {
        panel.ok(nil)
        return self
    }

    /// Activates the panel's cancel action.
    @discardableResult
    public func cancel() -> Self {
        panel.cancel(nil)
        return self
    }
}
#endif
#endif
