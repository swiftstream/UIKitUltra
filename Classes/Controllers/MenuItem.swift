//
//  MenuItem.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 13.08.2020.
//

#if os(macOS)
import Cocoa

class _MenuItem: NSMenuItem {
    init() {
        super.init(title: "", action: nil, keyEquivalent: "")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MenuItemHelper: NSObject, NSMenuItemValidation {
    override init() {
        super.init()
    }
    
    /// See `NSMenuItemValidation`
    
    public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        menuItem.isEnabled
    }
    
    var _actionHandler: () -> Void = {}
    
    @objc func action() {
        _actionHandler()
    }
}

public class MenuItem {
    private(set) lazy var item: NSMenuItem = _MenuItem()
    private lazy var helper: MenuItemHelper = .init()
    
    var _statedTitle: AnyStringBuilder.Handler?
    lazy var _stateState: State<NSControl.StateValue> = .init(wrappedValue: item.state)
    
    public static func separator() -> MenuItem {
        .init(.separator())
    }
    
    public init(_ item: NSMenuItem) {
        self.item = item
    }
    
    public init (_ title: String? = nil) {
        if let title = title {
            item.title = title
        }
    }
    
    public init (@MenuBuilder content: @escaping MenuBuilder.Block) {
        submenu(content: content)
    }
    
    public func submenu(@MenuBuilder content: @escaping MenuBuilder.Block) -> Self {
        let menu = Menu()
        menu.title(item.title)
        item.submenu = menu.menu
        menu.parseMenuBuilder(content().menuBuilderContent)
        return self
    }
    
    public var title: String { item.title }
    
    /// Set (and get) the view for a menu item.
    ///
    /// By default, a menu item has a nil view.
    ///
    /// A menu item with a view does not draw its title, state, font,
    /// or other standard drawing attributes, and assigns drawing responsibility entirely to the view.
    ///
    /// Keyboard equivalents and type-select continue to use the key equivalent and title as normal.
    ///
    /// A menu item with a view sizes itself according to the view's frame, and the width of the other menu items.
    /// The menu item will always be at least as wide as its view, but it may be wider.
    /// If you want your view to auto-expand to fill the menu item, then make sure
    /// that its autoresizing mask has NSViewWidthSizable set;
    /// in that case, the view's width at the time setView: is called will be treated as the minimum width for the view.
    /// A menu will resize itself as its containing views change frame size.
    /// Changes to the view's frame during tracking are reflected immediately in the menu.
    ///
    /// A view in a menu item will receive mouse and keyboard events normally.
    /// During non-sticky menu tracking (manipulating menus with the mouse button held down),
    /// a view in a menu item will receive mouseDragged: events.
    ///
    /// Animation is possible via the usual mechanism (set a timer to call setNeedsDisplay: or display),
    /// but because menu tracking occurs in the NSEventTrackingRunLoopMode,
    /// you must add the timer to the run loop in that mode.
    ///
    /// When the menu is opened, the view is added to a window;
    /// when the menu is closed the view is removed from the window.
    /// Override viewDidMoveToWindow in your view for a convenient place to start/stop animations,
    /// reset tracking rects, etc., but do not attempt to move or otherwise modify the window.
    ///
    /// When a menu item is copied via NSCopying, any attached view is copied via archiving/unarchiving.
    /// Menu item views are not supported in the Dock menu.
    public func view(@BodyBuilder block: BodyBuilder.SingleView) -> Self {
        item.view = UView(block: block)
        return self
    }
    
    public func view(@BodyBuilder block: (Self) -> BodyBuilder.Result) -> Self {
        item.view = UView().body { block(self) }
        return self
    }
    
//    @NSCopying open var attributedTitle: NSAttributedString?
    
    /// By default, when a menu item is hidden, its key equivalent is ignored.
    /// By setting this property to YES, you allow a hidden item's key equivalent
    /// to be considered when searching for a menu item that matches a key event.
    /// This is useful to provide a keyboard shortcut when it's not necessary
    /// to have a visible menu item in the menubar. Note that Apple HI guidelines generally recommend
    /// that keyboard shortcuts should be clearly indicated in a menu, so this property should be used only rarely.
//    @available(OSX 10.13, *)
//    open var allowsKeyEquivalentWhenHidden: Bool
    
//    open var image: NSImage?
    
//    open var onStateImage: NSImage! // checkmark by default
//
//    open var offStateImage: NSImage? // none by default
//
//    open var mixedStateImage: NSImage! // horizontal line by default
    
//    open var toolTip: String?
    
    public func onAction(_ handler: @escaping (MenuItem) -> Void) -> Self {
        item.target = helper
        item.action = #selector(MenuItemHelper.action)
        helper._actionHandler = { [weak self] in
            guard let self else { return }
            handler(self)
        }
        return self
    }
    
    public func onAction(_ handler: @escaping () -> Void) -> Self {
        item.target = helper
        item.action = #selector(MenuItemHelper.action)
        helper._actionHandler = handler
        return self
    }
    
    public func onAction(target: AnyObject? = nil, selector: Selector? = nil) -> Self {
        item.target = target
        item.action = selector
        return self
    }
    
    public func indentationLevel(_ value: Int) -> Self {
        item.indentationLevel = value
        return self
    }
}

extension MenuItem: MenuBuilderContent {
    public var menuBuilderContent: MenuBuilderItem { .menuItems([self]) }
}

extension MenuItem: _Enableable, Enableable {
    func _setEnabled(_ v: Bool) {
        item.isEnabled = v
    }
}

extension MenuItem: _Alternateable, Alternateable {
    func _setAlternate(_ v: Bool) {
        item.isAlternate = v
    }
}

extension MenuItem: _ControlStateable, ControlStateable {
    func _setState(_ v: NSControl.StateValue) {
        item.state = v
    }
}

extension MenuItem: _Titleable, Titleable {
    func _setTitle(_ v: NSAttributedString?) {
        item.title = v?.string ?? ""
    }
}

extension MenuItem: _Keyable, Keyable {
    func _setKey(_ v: String) {
        item.keyEquivalent = v
    }
}

extension MenuItem: _KeyMaskable, KeyMaskable {
    func _setKeyMask(_ v: NSEvent.ModifierFlags) {
        item.keyEquivalentModifierMask = v
    }
}

//extension MenuItem: _Tagable, Tagable {
//    open var tag: Int
//}
#endif
