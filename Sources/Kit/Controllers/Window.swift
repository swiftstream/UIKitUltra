#if os(macOS) || os(iOS) || os(tvOS)
//
//  Window.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 13.08.2020.
//

#if os(macOS)
import Cocoa

@MainActor
public class Window: AppBuilderContent {
    public var appBuilderContent: AppBuilderItem { .windows([self]) }
    
    public var windows: [Window] { [self] }
    
    public let window: NSWindow
    
    private let _stateBindingHolder = TempStatesHolder()

    var stateBindingHolder: TempStatesHolder {
        _stateBindingHolder
    }

    lazy var _backgroundColorState: State<UColor> = .init(wrappedValue: UColor.init(window.backgroundColor))
    private var _titlebarBackgroundColor: UColor?
    
//    public init (_ viewController: () -> ViewController?) {
//        if let viewController = viewController() {
//            window = .init(contentViewController: viewController)
//        } else {
//            window = .init()
//        }
//    }
    
    public init (_ viewController: (() -> NSViewController)? = nil) {
        if let viewController = viewController?() {
            window = .init(contentViewController: viewController)
        } else {
            window = .init()
        }
    }

    @MainActor
    public convenience init(@BodyBuilder block: BodyBuilder.SingleView) {
        self.init()
        window.contentView?.body { block() }
    }

    @MainActor
    init(existing window: NSWindow) {
        self.window = window
    }
    
    @discardableResult
    @MainActor
    public func body(@BodyBuilder block: BodyBuilder.SingleView) -> Self {
        window.contentView?.body { block() }
        return self
    }
    
    // MARK: Frame
    
    public func size(_ value: NSRect, display: Bool = true) -> Self {
        window.setFrame(value, display: display)
        return self
    }
    
    // MARK: Size
    
    public func size(_ value: NSSize, display: Bool = true) -> Self {
        size(value.width, value.height, display: display)
    }
    
    public func size(_ value: CGFloat, display: Bool = true) -> Self {
        size(value, value, display: display)
    }
    
    public func size(_ width: CGFloat, _ height: CGFloat, display: Bool = true) -> Self {
        window.setFrame(.init(origin: window.frame.origin, size: .init(width: width, height: height)), display: display)
        return self
    }
    
    // MARK: Point
    
    public func origin(_ value: NSPoint) -> Self {
        window.setFrameOrigin(value)
        return self
    }

    // MARK: Frame Autosave

    /// Sets the AppKit name used to persist and restore this window's frame.
    ///
    /// AppKit restores the saved frame when the name is installed and keeps
    /// saving later moves and resizes under the same name. Apply this
    /// modifier after the default `size`/`center` modifiers so a stored frame
    /// wins when one exists while a first launch still has a deterministic
    /// default.
    /// - Parameter value: A stable autosave key for this window role.
    @discardableResult
    public func frameAutosaveName(_ value: NSWindow.FrameAutosaveName) -> Self {
        _ = window.setFrameAutosaveName(value)
        return self
    }

    /// Binds the AppKit frame autosave name to a state.
    ///
    /// The current key is applied immediately and later state assignments
    /// switch the persistence key for the same native window. Repeated calls
    /// add bindings retained by the window until teardown.
    /// - Parameter state: The state supplying the stable autosave key.
    @discardableResult
    public func frameAutosaveName(_ state: UState<NSWindow.FrameAutosaveName>) -> Self {
        _ = frameAutosaveName(state.wrappedValue)
        state.listen { [weak self] in
            _ = self?.frameAutosaveName($0)
        }
        .hold(in: stateBindingHolder)
        return self
    }
    
    // MARK: Title

    /// Sets the title displayed by the window.
    ///
    /// For a newly created window, place this modifier after initial
    /// presentation methods when the explicit title must override AppKit's
    /// default application title.
    /// - Parameter value: The text to display in the window title bar.
    public func title(_ value: String) -> Self {
        window.title = value
        return self
    }

    /// Binds the displayed window title to a string state.
    ///
    /// The current value is applied immediately, and later assignments update
    /// the same window one way. Repeated calls add independent bindings. The
    /// `Window` retains each listener token, not its source state; a binding
    /// ends when either object is released or the source removes its listeners.
    /// For a newly created window, install this binding after initial
    /// presentation methods when its initial value must override AppKit's
    /// default application title.
    /// - Parameter state: The `UState<String>` that supplies the window title.
    public func title(_ state: UState<String>) -> Self {
        _ = title(state.wrappedValue)
        state.listen { [weak self] in
            _ = self?.title($0)
        }
        .hold(in: stateBindingHolder)
        return self
    }
    
    // MARK: Title Visibility
    
    public func titleVisibility(_ value: NSWindow.TitleVisibility = .visible) -> Self {
        window.titleVisibility = value
        return self
    }
    
    // MARK: Title Transparency
    
    public func titlebarAppearsTransparent(_ value: Bool = true) -> Self {
        window.titlebarAppearsTransparent = value
        return self
    }

    // MARK: Titlebar Background

    /// Sets the background color used by AppKit's native title and tab chrome.
    ///
    /// The color is applied to the titlebar container that owns the standard
    /// window buttons, which also covers the native tab strip when AppKit
    /// groups project windows into one tabbed window.
    ///
    /// Ultra uses a best-effort heuristic over AppKit's titlebar view
    /// hierarchy because AppKit does not expose a public titlebar-background
    /// setter. That hierarchy is not a stable API contract: use this modifier
    /// with caution and verify it on every supported macOS release. If the
    /// color no longer reaches the intended native chrome, please report it at
    /// https://github.com/MihaelIsaev/UIKitPlus/issues.
    /// When the process is not hosted by a Ultra `App`, dynamic colors
    /// resolve to their light variant rather than force-casting `NSApp`.
    /// - Parameter value: The color to use for the native title/tab chrome.
    @discardableResult
    public func titlebarBackground(_ value: UColor) -> Self {
        _titlebarBackgroundColor?.changeHandler = nil
        _titlebarBackgroundColor = value
        applyTitlebarBackground(value.current)
        value.onChange { [weak self] color in
            self?.applyTitlebarBackground(color)
        }
        return self
    }

    /// Binds the native title/tab chrome background to a color state.
    ///
    /// The current color is applied immediately and later state assignments
    /// update the same native titlebar. The binding is retained by the window
    /// until teardown, matching the other state-aware `Window` modifiers.
    /// The underlying titlebar lookup is heuristic and should be verified on
    /// every supported macOS release; report regressions at
    /// https://github.com/MihaelIsaev/UIKitPlus/issues.
    /// - Parameter state: The `UState<UColor>` that supplies the chrome color.
    @discardableResult
    public func titlebarBackground(_ state: UState<UColor>) -> Self {
        _ = titlebarBackground(state.wrappedValue)
        state.listen { [weak self] in
            _ = self?.titlebarBackground($0)
        }
        .hold(in: stateBindingHolder)
        return self
    }

    /// Applies a color to the native titlebar container and tab strip.
    ///
    /// AppKit creates this container lazily, so a missing standard button is
    /// intentionally treated as a no-op. The next state update or window
    /// configuration pass can apply the color once the chrome exists.
    private func applyTitlebarBackground(_ color: NSColor) {
        guard var view: NSView? = window.standardWindowButton(.closeButton)
            else { return }

        // The titlebar button is nested below AppKit's titlebar/tab
        // containers. Six ancestors reaches the shared native chrome on
        // current macOS while avoiding the content view itself.
        for _ in 0..<6 {
            view = view?.superview
            view?.wantsLayer = true
            view?.layer?.backgroundColor = color.cgColor
            view?.needsDisplay = true
        }
    }

    // MARK: Represented URL
    
    public func representedURL(_ value: URL?) -> Self {
        window.representedURL = value
        return self
    }
    
    // MARK: Represented Filename
    
    public func representedFilename(_ value: String, asTitle: Bool = false) -> Self {
        window.representedFilename = value
        if asTitle {
            window.setTitleWithRepresentedFilename(window.representedFilename)
        }
        return self
    }
    
    // MARK: Excluded From Windows Menu
    
    public func excludedFromWindowsMenu(_ value: Bool = true) -> Self {
        window.isExcludedFromWindowsMenu = value
        return self
    }
    
    // MARK: Movable
    
    public func movable(_ value: Bool = true) -> Self {
        window.isMovable = value
        return self
    }

    // MARK: Movable by Window Background
    
    public func movableByWindowBackground(_ value: Bool = true) -> Self {
        window.isMovableByWindowBackground = value
        return self
    }

    // MARK: Hides On Deactivate
    
    public func hidesOnDeactivate(_ value: Bool = true) -> Self {
        window.hidesOnDeactivate = value
        return self
    }

    // MARK: Can Hide
    
    public func canHide(_ value: Bool = true) -> Self {
        window.canHide = value
        return self
    }
    
    // MARK: Center
    
    public func center() -> Self {
        window.center()
        return self
    }

    // MARK: Make Key And Order Front
    
    public func makeKeyAndOrderFront() -> Self {
        window.makeKeyAndOrderFront(nil)
        return self
    }

    // MARK: Order Front
    
    public func orderFront() -> Self {
        window.orderFront(nil)
        return self
    }

    // MARK: Order Back
    
    public func orderBack() -> Self {
        window.orderBack(nil)
        return self
    }

    // MARK: Order Out
    
    public func orderOut() -> Self {
        window.orderOut(nil)
        return self
    }

    // MARK: Order
    
    public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) -> Self {
        window.order(place, relativeTo: otherWin)
        return self
    }

    // MARK: Order Front Regardless
    
    public func orderFrontRegardless() -> Self {
        window.center()
        return self
    }

    // MARK: Miniwindow Image
    
    public func miniwindowImage(_ value: NSImage?) -> Self {
        window.miniwindowImage = value
        return self
    }

    // MARK: Miniwindow Title
    
    public func miniwindowTitle(_ value: String) -> Self {
        window.miniwindowTitle = value
        return self
    }
    
    // MARK: Document Edited
    
    public func documentEdited(_ value: Bool = true) -> Self {
        window.isDocumentEdited = value
        return self
    }
    
    // MARK: Make Key
    
    public func makeKey() -> Self {
        window.makeKey()
        return self
    }

    // MARK: Make Main
    
    public func makeMain() -> Self {
        window.makeMain()
        return self
    }

    // MARK: Become Key
    
    public func becomeKey() -> Self {
        window.becomeKey()
        return self
    }

    // MARK: Resign Key
    
    public func resignKey() -> Self {
        window.resignKey()
        return self
    }

    // MARK: Become Main
    
    public func becomeMain() -> Self {
        window.becomeMain()
        return self
    }

    // MARK: Resign Main
    
    public func resignMain() -> Self {
        window.resignMain()
        return self
    }
    
    // MARK: Prevents Application Termination When Modal
    
    public func preventsApplicationTerminationWhenModal(_ value: Bool = true) -> Self {
        window.preventsApplicationTerminationWhenModal = value
        return self
    }
    
    // MARK: Allows Tool Tips When Application Is Inactive
    
    public func allowsToolTipsWhenApplicationIsInactive(_ value: Bool = true) -> Self {
        window.allowsToolTipsWhenApplicationIsInactive = value
        return self
    }

    // MARK: Accepts Mouse Moved Events

    /// Sets whether the window receives mouse-moved events.
    /// - Parameter value: `true` to receive mouse-moved events; otherwise,
    ///   `false`. The default is `true`.
    public func acceptsMouseMovedEvents(_ value: Bool = true) -> Self {
        window.acceptsMouseMovedEvents = value
        return self
    }

    /// Binds mouse-moved event acceptance to a Boolean state.
    ///
    /// The current value is applied immediately, and later assignments update
    /// the same window one way. Repeated calls add independent bindings. The
    /// `Window` retains each listener token, not its source state; a binding
    /// ends when either object is released or the source removes its listeners.
    /// - Parameter state: The `UState<Bool>` that controls whether the window
    ///   receives mouse-moved events.
    public func acceptsMouseMovedEvents(_ state: UState<Bool>) -> Self {
        _ = acceptsMouseMovedEvents(state.wrappedValue)
        state.listen { [weak self] in
            _ = self?.acceptsMouseMovedEvents($0)
        }
        .hold(in: stateBindingHolder)
        return self
    }
    
    // MARK: Level
    
    public func level(_ value: NSWindow.Level) -> Self {
        window.level = value
        return self
    }
    
    // MARK: Depth Limit

    public func depthLimit(_ value: NSWindow.Depth) -> Self {
        window.depthLimit = value
        return self
    }

    // MARK: Dynamic Depth Limit
    
    public func dynamicDepthLimit(_ value: Bool = true) -> Self {
        window.setDynamicDepthLimit(value)
        return self
    }
    
    // MARK: Has Shadow
    
    public func hasShadow(_ value: Bool = true) -> Self {
        window.hasShadow = value
        return self
    }
    
    // MARK: Alpha
    
    public func alpha(_ value: CGFloat) -> Self {
        window.alphaValue = value
        return self
    }

    // MARK: Opaque
    
    public func opaque(_ value: Bool = true) -> Self {
        window.isOpaque = value
        return self
    }

    // MARK: Sharing Type
    
    public func sharingType(_ value: NSWindow.SharingType) -> Self {
        window.sharingType = value
        return self
    }

    // MARK: Allows Concurrent View Drawing
    
    public func allowsConcurrentViewDrawing(_ value: Bool = true) -> Self {
        window.allowsConcurrentViewDrawing = value
        return self
    }

    // MARK: Displays When Screen Profile Changes
    
    public func displaysWhenScreenProfileChanges(_ value: Bool = true) -> Self {
        window.displaysWhenScreenProfileChanges = value
        return self
    }

    // MARK: Disable Screen Updates Until Flush
    
    public func disableScreenUpdatesUntilFlush() -> Self {
        window.disableScreenUpdatesUntilFlush()
        return self
    }

    // MARK: Can Become Visible Without Login
    
    public func canBecomeVisibleWithoutLogin(_ value: Bool = true) -> Self {
        window.canBecomeVisibleWithoutLogin = value
        return self
    }
    
    // MARK: Min Size
    
    public func minSize(_ width: CGFloat, _ height: CGFloat) -> Self {
        window.minSize = .init(width: width, height: height)
        return self
    }

    public func minSize(_ value: NSSize) -> Self {
        window.minSize = value
        return self
    }
    
    // MARK: Max Size

    public func maxSize(_ width: CGFloat, _ height: CGFloat) -> Self {
        window.maxSize = .init(width: width, height: height)
        return self
    }

    public func maxSize(_ value: NSSize) -> Self {
        window.maxSize = value
        return self
    }
    
    // MARK: Content Min Size

    public func contentMinSize(_ width: CGFloat, _ height: CGFloat) -> Self {
        window.contentMinSize = .init(width: width, height: height)
        return self
    }

    public func contentMinSize(_ value: NSSize) -> Self {
        window.contentMinSize = value
        return self
    }

    // MARK: Content Max Size
    
    public func contentMaxSize(_ width: CGFloat, _ height: CGFloat) -> Self {
        window.contentMaxSize = .init(width: width, height: height)
        return self
    }

    public func contentMaxSize(_ value: NSSize) -> Self {
        window.contentMaxSize = value
        return self
    }

    // MARK: Min Full Screen Content Size
    
    public func minFullScreenContentSize(_ width: CGFloat, _ height: CGFloat) -> Self {
        window.minFullScreenContentSize = .init(width: width, height: height)
        return self
    }

    public func minFullScreenContentSize(_ value: NSSize) -> Self {
        window.minFullScreenContentSize = value
        return self
    }

    // MARK: Max Full Screen Content Size
    
    public func maxFullScreenContentSize(_ width: CGFloat, _ height: CGFloat) -> Self {
        window.maxFullScreenContentSize = .init(width: width, height: height)
        return self
    }

    public func maxFullScreenContentSize(_ value: NSSize) -> Self {
        window.maxFullScreenContentSize = value
        return self
    }
    
    // MARK: Color Space
    
    public func colorSpace(_ value: NSColorSpace?) -> Self {
        window.colorSpace = value
        return self
    }
    
    // MARK: Toolbar
    
//    open var toolbar: NSToolbar? // TODO: with block builder
    public func toolbar(_ value: NSToolbar?) -> Self {
        window.toolbar = value
        return self
    }

    public func toolbar() -> Self {
        window.toolbar = NSToolbar()
        return self
    }
    
    // MARK: Shows Toolbar Button
    
    public func showsToolbarButton(_ value: Bool = true) -> Self {
        window.showsToolbarButton = value
        return self
    }
    
    // MARK: Tabbing Mode

    /// Sets the AppKit tabbing mode used when this window is shown.
    @discardableResult
    public func tabbingMode(_ value: NSWindow.TabbingMode) -> Self {
        window.tabbingMode = value
        return self
    }

    /// Binds AppKit tabbing mode to a state.
    ///
    /// The current value is applied immediately and later writes update the
    /// same window one way. Repeated calls add independent bindings retained
    /// by the window's state-binding holder until teardown.
    @discardableResult
    public func tabbingMode(_ state: UState<NSWindow.TabbingMode>) -> Self {
        _ = tabbingMode(state.wrappedValue)
        state.listen { [weak self] in _ = self?.tabbingMode($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    // MARK: Tabbing Identifier

    /// Sets the identifier used by AppKit to associate compatible windows.
    @discardableResult
    public func tabbingIdentifier(_ value: NSWindow.TabbingIdentifier) -> Self {
        window.tabbingIdentifier = value
        return self
    }

    /// Binds the AppKit tabbing identifier to a string state. The current
    /// value is applied immediately; future writes flow one way into the
    /// window. Repeated calls add bindings retained by the window's
    /// state-binding holder until teardown.
    @discardableResult
    public func tabbingIdentifier(_ state: UState<NSWindow.TabbingIdentifier>) -> Self {
        _ = tabbingIdentifier(state.wrappedValue)
        state.listen { [weak self] in _ = self?.tabbingIdentifier($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    // MARK: Appearance

    /// Sets the native appearance used by the window and its system chrome.
    @discardableResult
    public func appearance(_ value: NSAppearance?) -> Self {
        window.appearance = value
        return self
    }

    /// Binds the native appearance to an optional appearance state. The
    /// current value is applied immediately; future writes flow one way into
    /// the window. Repeated calls add bindings retained by the window's
    /// state-binding holder until teardown.
    @discardableResult
    public func appearance(_ state: UState<NSAppearance?>) -> Self {
        _ = appearance(state.wrappedValue)
        state.listen { [weak self] in _ = self?.appearance($0) }
            .hold(in: stateBindingHolder)
        return self
    }
    
    // MARK: Style Mask
    
    public func styleMask(_ value: NSWindow.StyleMask...) -> Self {
        window.styleMask = .init(value)
        return self
    }
    
    // MARK: Backing Type
    
    public func backingType(_ value: NSWindow.BackingStoreType) -> Self {
        window.backingType = value
        return self
    }
    
    // MARK: Hide Standard Button
    
    public func hideStandardButtons(_ type: NSWindow.ButtonType..., hide: Bool = true) -> Self {
        type.forEach {
            window.standardWindowButton($0)?.isHidden = hide
        }
        return self
    }
}

extension Window: _StateBindingOwner {}

extension Window: _BackgroundColorable {
    func _setBackgroundColor(_ v: NSColor?) {
        window.backgroundColor = v
    }
}
#endif
#endif
