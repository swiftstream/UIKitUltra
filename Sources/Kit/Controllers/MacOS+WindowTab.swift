#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

/// A lazy native window that participates in a `WindowTabGroup`.
@MainActor
public final class WindowTab<ID: Hashable>: Window, AnyWindowTab, WindowTabBuilderContent {
    /// Stable identity used by topology and source-array reconciliation.
    public let id: ID

    private var contentFactory: (() -> NSViewController)?
    /// Whether this tab's lazy content controller has been created.
    private(set) public var isMaterialized = false
    /// Whether AppKit close actions may close this tab.
    private(set) public var closeAllowed = true

    /// Creates a native window tab without constructing its content controller.
    public init(id: ID, content: (() -> NSViewController)? = nil) {
        self.id = id
        self.contentFactory = content
        super.init()
        // WindowTab keeps the NSWindow object in the declarative runtime after
        // AppKit closes its native presentation. AppKit must not release the
        // object behind the retained Window/WindowProxy wrappers first.
        window.isReleasedWhenClosed = false
        window.tabbingMode = .preferred
    }

    /// The type-erased stable identity used by a containing group.
    public var anyID: AnyHashable { AnyHashable(id) }

    /// Installs or replaces the lazy content factory before first materialization.
    /// Once materialized, repeated calls preserve the existing controller and UI state.
    @discardableResult
    public func content(_ factory: @escaping () -> NSViewController) -> Self {
        if !isMaterialized {
            contentFactory = factory
        }
        return self
    }

    /// Materializes the content controller exactly once on the main actor.
    public func materialize() {
        guard !isMaterialized, let contentFactory else { return }
        let presentationFrame = window.frame
        window.contentViewController = contentFactory()
        // Force the first layout pass before AppKit presents a newly selected
        // native tab. This keeps an expensive declarative view tree from
        // exposing an empty content surface for a frame (or more) after the
        // tab selection has already changed.
        window.contentView?.layoutSubtreeIfNeeded()
        // Assigning a content view controller lets AppKit derive a fitting
        // window size. Preserve the frame that was already chosen by the
        // user, autosave restoration, or the native tab group instead of
        // allowing lazy materialization to resize or recenter the window.
        window.setFrame(presentationFrame, display: false)
        window.contentView?.layoutSubtreeIfNeeded()
        self.contentFactory = nil
        isMaterialized = true
    }

    /// Sets whether native close actions are currently permitted.
    @discardableResult
    public func canClose(_ value: Bool) -> Self {
        closeAllowed = value
        return self
    }

    /// Binds native close permission to a Boolean state.
    ///
    /// The current value is applied immediately and future state writes update
    /// this tab one way. Repeated calls add listeners and are released with the
    /// tab. Programmatic source-array removal remains an explicit force-close.
    @discardableResult
    public func canClose(_ state: UState<Bool>) -> Self {
        _ = canClose(state.wrappedValue)
        state.listen { [weak self] in _ = self?.canClose($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets the title shown in the native tab bar.
    @discardableResult
    public func tabTitle(_ value: String?) -> Self {
        window.tab.title = value
        return self
    }

    /// Binds the native tab-bar title to a string state.
    ///
    /// The optional state overload intentionally mirrors the scalar overload,
    /// so autocomplete exposes the exact value type accepted by the native
    /// tab title instead of hiding it behind a generic Stateable abstraction.
    /// The current value is applied immediately; future writes flow one way
    /// into the tab. Repeated calls add bindings retained by the tab until
    /// teardown.
    @discardableResult
    public func tabTitle(_ state: UState<String?>) -> Self {
        _ = tabTitle(state.wrappedValue)
        state.listen { [weak self] in _ = self?.tabTitle($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Binds a required string state to the native tab-bar title. The current
    /// value is applied immediately; future writes flow one way into the tab.
    /// Repeated calls add bindings retained by the tab until teardown.
    @discardableResult
    public func tabTitle(_ state: UState<String>) -> Self {
        _ = tabTitle(state.wrappedValue)
        state.listen { [weak self] in _ = self?.tabTitle($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets an attributed native tab-bar title.
    @discardableResult
    public func tabAttributedTitle(_ value: NSAttributedString?) -> Self {
        window.tab.attributedTitle = value
        return self
    }

    /// Binds an attributed native tab-bar title. The current value is applied
    /// immediately; future writes flow one way into the tab. Repeated calls
    /// add bindings retained by the tab until teardown.
    @discardableResult
    public func tabAttributedTitle(_ state: UState<NSAttributedString?>) -> Self {
        _ = tabAttributedTitle(state.wrappedValue)
        state.listen { [weak self] in _ = self?.tabAttributedTitle($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets the native tab-bar tooltip.
    @discardableResult
    public func tabToolTip(_ value: String?) -> Self {
        window.tab.toolTip = value
        return self
    }

    /// Binds the native tab-bar tooltip. The current value is applied
    /// immediately; future writes flow one way into the tab. Repeated calls
    /// add bindings retained by the tab until teardown.
    @discardableResult
    public func tabToolTip(_ state: UState<String?>) -> Self {
        _ = tabToolTip(state.wrappedValue)
        state.listen { [weak self] in _ = self?.tabToolTip($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Binds a required string state to the native tab-bar tooltip. The
    /// current value is applied immediately; future writes flow one way into
    /// the tab. Repeated calls add bindings retained by the tab until teardown.
    @discardableResult
    public func tabToolTip(_ state: UState<String>) -> Self {
        _ = tabToolTip(state.wrappedValue)
        state.listen { [weak self] in _ = self?.tabToolTip($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets the native tab accessory view.
    @discardableResult
    public func tabAccessoryView(_ value: NSView?) -> Self {
        window.tab.accessoryView = value
        return self
    }

    /// Binds the native tab accessory view to an optional view state. The
    /// current value is applied immediately; future writes flow one way into
    /// the tab. Repeated calls add bindings retained by the tab until teardown.
    @discardableResult
    public func tabAccessoryView(_ state: UState<NSView?>) -> Self {
        _ = tabAccessoryView(state.wrappedValue)
        state.listen { [weak self] in _ = self?.tabAccessoryView($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Erases this concrete tab into a builder item.
    public var windowTabBuilderItem: WindowTabBuilderItem { .tab(self) }
}
#endif
#endif
