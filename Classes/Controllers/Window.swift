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
    
    // MARK: Title
    
    public func title(_ value: String) -> Self {
        window.title = value
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
    
    public func tabbingMode(_ value: NSWindow.TabbingMode) -> Self {
        window.tabbingMode = value
        return self
    }

    // MARK: Tabbing Identifier
    
    public func tabbingIdentifier(_ value: NSWindow.TabbingIdentifier) -> Self {
        window.tabbingIdentifier = value
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
