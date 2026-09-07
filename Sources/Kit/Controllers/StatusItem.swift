#if os(macOS) || os(iOS) || os(tvOS)
//
//  StatusItem.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 13.08.2020.
//

#if os(macOS)
import Cocoa

@MainActor
public class StatusItem: AppBuilderContent {
    public var appBuilderContent: AppBuilderItem { .statusItems([self]) }
    
    lazy var _tintState: State<UColor> = .init(wrappedValue: .init(item.button?.contentTintColor ?? .cyan))
    lazy var _hiddenState: State<Bool> = .init(wrappedValue: !item.isVisible)

    private let _stateBindingHolder = TempStatesHolder()

    var stateBindingHolder: TempStatesHolder {
        _stateBindingHolder
    }
    
    let item: NSStatusItem
    
    public init (_ statusBar: NSStatusBar = .system, length: CGFloat = NSStatusItem.squareLength) {
        item = statusBar.statusItem(withLength: length)
    }
    
    public init (_ statusBar: NSStatusBar = .system, length: CGFloat = NSStatusItem.squareLength, @MenuBuilder content: @escaping MenuBuilder.Block) {
        item = statusBar.statusItem(withLength: length)
        let menu = Menu()
        item.menu = menu.menu
        menu.parseMenuBuilder(content().menuBuilderContent)
    }
    
    var length: CGFloat {
        item.length
    }
    
    /// The amount of space in the status bar that should be allocated to the receiver.
    /// `NSStatusItem.variableLength` will adjust the length to the size of the status item's contents and
    /// `NSStatusItem.squareLength` will keep the length the same as the status bar's height.
    public func length(_ value: CGFloat) -> Self {
        item.length = value
        return self
    }
    
    public func variableLength() -> Self {
        item.length = NSStatusItem.variableLength
        return self
    }
    
    public func squareLength() -> Self {
        item.length = NSStatusItem.squareLength
        return self
    }
    
    /// The drop down menu that is displayed when the status item is pressed or clicked.
    public func menu(_ value: NSMenu) -> Self {
        item.menu = value
        return self
    }
    
    /// Specifies the behavior of the status item.
    public func behavior(_ value: NSStatusItem.Behavior) -> Self {
        item.behavior = value
        return self
    }
    
    /// Specifies a unique name for persisting visibility information.
    /// If none is specified, one is automatically chosen.
    /// Apps with multiple status bar items should set an autosave after creation.
    /// Setting to nil resets the automatically chosen name and clears saved information.
    public func autosaveName(_ value: NSStatusItem.AutosaveName) -> Self {
        item.autosaveName = value
        return self
    }
    
    public func title(_ value: String) -> Self {
        item.button?.title = value
        return self
    }
    
    public func title(_ state: UState<String>) -> Self {
        title(state.wrappedValue)
        state.listen { [weak self] in
            self?.title($0)
        }
        .hold(in: stateBindingHolder)
        return self
    }
    
    public func attributedTitle(_ value: NSAttributedString) -> Self {
        item.button?.attributedTitle = value
        return self
    }
    
    public func attributedTitle(_ state: UState<NSAttributedString>) -> Self {
        self.attributedTitle(state.wrappedValue)
        state.listen { [weak self] in
            self?.attributedTitle($0)
        }
        .hold(in: stateBindingHolder)
        return self
    }
    
    public func image(_ value: NSImage?) -> Self {
        item.button?.image = value
        return self
    }
    
    public func image(_ state: UState<NSImage?>) -> Self {
        image(state.wrappedValue)
        state.listen { [weak self] in
            self?.image($0)
        }
        .hold(in: stateBindingHolder)
        return self
    }
    
    public func alternateImage(_ value: NSImage?) -> Self {
        item.button?.alternateImage = value
        return self
    }
    
    public func alternateImage(_ state: UState<NSImage?>) -> Self {
        alternateImage(state.wrappedValue)
        state.listen { [weak self] in
            self?.alternateImage($0)
        }
        .hold(in: stateBindingHolder)
        return self
    }
    
    public func enabled(_ value: Bool = true) -> Self {
        item.button?.isEnabled = value
        return self
    }
    
    public func enabled(_ state: UState<Bool>) -> Self {
        self.enabled(state.wrappedValue)
        state.listen { [weak self] in
            self?.enabled($0)
        }
        .hold(in: stateBindingHolder)
        return self
    }
    
    public func visible(_ value: Bool = true) -> Self {
        item.isVisible = value
        return self
    }
    
    public func visible(_ state: UState<Bool>) -> Self {
        self.visible(state.wrappedValue)
        state.listen { [weak self] in
            self?.visible($0)
        }
        .hold(in: stateBindingHolder)
        return self
    }
    
    public func highlight(_ value: Bool = true) -> Self {
        item.button?.highlight(value)
        return self
    }
    
    public func toolTip(_ value: String? = nil) -> Self {
        item.button?.toolTip = value
        return self
    }
    
    public func toolTip(_ state: UState<String>) -> Self {
        toolTip(state.wrappedValue)
        state.listen { [weak self] in
            self?.toolTip($0)
        }
        .hold(in: stateBindingHolder)
        return self
    }
    
    public func sendAction(on value: NSEvent.EventTypeMask) -> Self {
        item.button?.sendAction(on: value)
        return self
    }
    
    // MARK: - Menu Methods
    
    public func menuTitle(_ value: String) -> Self {
        item.menu?.title = value
        return self
    }
    
    /// Set and get whether the menu autoenables items.
    /// If a menu autoenables items, then calls to -[NSMenuItem setEnabled:] are ignored,
    /// and the enabled state is computed via the NSMenuValidation informal protocol below.
    /// Autoenabling is on by default.
    public func autoenablesItems(_ value: Bool = true) -> Self {
        item.menu?.autoenablesItems = value
        return self
    }
    
    /// Set the minimum width of the menu, in screen coordinates.
    /// The menu will prefer to not draw smaller than its minimum width,
    /// but may draw larger if it needs more space.
    /// The default value is 0.
    public func minimumWidth(_ value: CGFloat) -> Self {
        item.menu?.minimumWidth = value
        return self
    }
    
    /// Sets the font for the menu.
    /// This also affects the font of all submenus that do not have their own font.
    public func font(_ value: NSFont) -> Self {
        item.menu?.font = value
        return self
    }
    
    /// Determines whether contextual menu plugins may be appended to the menu,
    /// if used as a context menu.
    /// The default is YES.
    public func allowsContextMenuPlugIns(_ value: Bool) -> Self {
        item.menu?.allowsContextMenuPlugIns = value
        return self
    }

    
    /// Determines whether the menu contains a column for the state image.
    /// The default is YES.
    public func showsStateColumn(_ value: Bool) -> Self {
        item.menu?.showsStateColumn = value
        return self
    }

    
    /// Determines the layout direction for menu items in the menu.
    /// If no layout direction is explicitly set, the menu will default to the value of [NSApp userInterfaceLayoutDirection].
    public func userInterfaceLayoutDirection(_ value: NSUserInterfaceLayoutDirection) -> Self {
        item.menu?.userInterfaceLayoutDirection = value
        return self
    }
}

extension StatusItem: _StateBindingOwner {}

extension StatusItem: _Tintable, Tintable {
    func _setTint(_ v: NSColor?) {
        item.button?.contentTintColor = v
    }
}

extension StatusItem: _Hiddenable, Hiddenable {
    func _setHidden(_ v: Bool) {
        item.isVisible = !v
    }
}
#endif
#endif
