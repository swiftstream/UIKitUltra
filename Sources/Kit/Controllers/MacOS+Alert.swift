#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

/// A declarative wrapper around `NSAlert` for UIKitPlus-first macOS flows.
@MainActor
public final class Alert {
    /// The native alert owned by this wrapper.
    public let alert: NSAlert

    private let stateBindingHolder = TempStatesHolder()

    /// Creates an alert with optional initial message and informative text.
    public init(
        messageText: String? = nil,
        informativeText: String? = nil,
        style: NSAlert.Style = .informational
    ) {
        alert = NSAlert()
        alert.messageText = messageText ?? ""
        alert.informativeText = informativeText ?? ""
        alert.alertStyle = style
    }

    /// Sets the main alert message.
    @discardableResult
    public func messageText(_ value: String?) -> Self {
        alert.messageText = value ?? ""
        return self
    }

    /// Binds the main alert message to an optional string state. The current
    /// value is applied immediately; repeated calls add bindings held by this
    /// wrapper until teardown.
    @discardableResult
    public func messageText(_ state: UState<String?>) -> Self {
        _ = messageText(state.wrappedValue)
        state.listen { [weak self] in _ = self?.messageText($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets the explanatory alert text.
    @discardableResult
    public func informativeText(_ value: String?) -> Self {
        alert.informativeText = value ?? ""
        return self
    }

    /// Binds explanatory alert text to an optional string state. The current
    /// value is applied immediately; repeated calls add bindings held by this
    /// wrapper until teardown.
    @discardableResult
    public func informativeText(_ state: UState<String?>) -> Self {
        _ = informativeText(state.wrappedValue)
        state.listen { [weak self] in _ = self?.informativeText($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets the native alert style.
    @discardableResult
    public func style(_ value: NSAlert.Style) -> Self {
        alert.alertStyle = value
        return self
    }

    /// Binds the native alert style one way to a state.
    ///
    /// The current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown.
    @discardableResult
    public func style(_ state: UState<NSAlert.Style>) -> Self {
        _ = style(state.wrappedValue)
        state.listen { [weak self] in _ = self?.style($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets the weak delegate used for native help-button handling.
    ///
    /// Delegates are lifecycle/configuration objects rather than value state;
    /// UIKitPlus therefore preserves AppKit's scalar weak delegate property
    /// instead of inventing a state overload.
    @discardableResult
    public func delegate(_ value: (any NSAlertDelegate)?) -> Self {
        alert.delegate = value
        return self
    }

    /// Sets the custom icon displayed by the alert.
    @discardableResult
    public func icon(_ value: NSImage?) -> Self {
        alert.icon = value
        return self
    }

    /// Binds the custom alert icon one way to an optional image state.
    ///
    /// The current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown.
    @discardableResult
    public func icon(_ state: UState<NSImage?>) -> Self {
        _ = icon(state.wrappedValue)
        state.listen { [weak self] in _ = self?.icon($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets whether the alert displays its help button.
    @discardableResult
    public func showsHelp(_ value: Bool = true) -> Self {
        alert.showsHelp = value
        return self
    }

    /// Binds help-button visibility one way to a Boolean state.
    ///
    /// The current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown.
    @discardableResult
    public func showsHelp(_ state: UState<Bool>) -> Self {
        _ = showsHelp(state.wrappedValue)
        state.listen { [weak self] in _ = self?.showsHelp($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets the native help anchor used by the alert.
    @discardableResult
    public func helpAnchor(_ value: NSHelpManager.AnchorName?) -> Self {
        alert.helpAnchor = value
        return self
    }

    /// Binds the native help anchor one way to an optional state.
    ///
    /// The current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown.
    @discardableResult
    public func helpAnchor(_ state: UState<NSHelpManager.AnchorName?>) -> Self {
        _ = helpAnchor(state.wrappedValue)
        state.listen { [weak self] in _ = self?.helpAnchor($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Sets the optional accessory view displayed by the alert.
    @discardableResult
    public func accessoryView(_ value: NSView?) -> Self {
        alert.accessoryView = value
        return self
    }

    /// Binds the alert accessory view one way to an optional view state.
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

    /// Sets whether the alert displays its suppression checkbox.
    @discardableResult
    public func showsSuppressionButton(_ value: Bool = true) -> Self {
        alert.showsSuppressionButton = value
        return self
    }

    /// Binds suppression-checkbox visibility one way to a Boolean state.
    ///
    /// The current value is applied immediately; repeated calls add bindings
    /// held by this wrapper until teardown.
    @discardableResult
    public func showsSuppressionButton(_ state: UState<Bool>) -> Self {
        _ = showsSuppressionButton(state.wrappedValue)
        state.listen { [weak self] in _ = self?.showsSuppressionButton($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// Adds a button with a concrete title.
    @discardableResult
    public func addButton(_ title: String) -> Self {
        alert.addButton(withTitle: title)
        return self
    }

    /// The response buttons in the order in which they were added.
    public var buttons: [NSButton] { alert.buttons }

    /// The native suppression checkbox, when suppression is enabled.
    public var suppressionButton: NSButton? { alert.suppressionButton }

    /// The native alert window while the alert is presented.
    public var window: NSWindow { alert.window }

    /// Forces AppKit to lay out the alert immediately.
    @discardableResult
    public func layout() -> Self {
        alert.layout()
        return self
    }

    /// Runs the alert modally and returns the native response.
    public func runModal() -> NSApplication.ModalResponse {
        alert.runModal()
    }

    /// Presents the alert as an application-modal sheet.
    @discardableResult
    public func beginSheetModal(
        for window: NSWindow,
        completion: @escaping (NSApplication.ModalResponse) -> Void
    ) -> Self {
        alert.beginSheetModal(for: window, completionHandler: completion)
        return self
    }
}
#endif
#endif
