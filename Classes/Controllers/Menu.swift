//
//  Menu.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 13.08.2020.
//

#if os(macOS)
import Cocoa

private final class _NSMenu: NSMenu {
    final class Storage {
        var items: [MenuItem] = []
    }

    /// Retains declarative item owners for the lifetime of the native menu.
    let storage = Storage()
}

public class Menu: NSObject, NSMenuDelegate {
    public let menu: NSMenu
    private let storage: _NSMenu.Storage

    var items: [MenuItem] {
        storage.items
    }
    
    public init (_ menu: NSMenu) {
        self.menu = menu
        storage = (menu as? _NSMenu)?.storage ?? _NSMenu.Storage()
        super.init()
        self.menu.delegate = self
    }
    
    public override init () {
        let nativeMenu = _NSMenu(title: "")
        menu = nativeMenu
        storage = nativeMenu.storage
        super.init()
        menu.delegate = self
    }
    
    public init (_ title: String? = nil, @MenuBuilder content: @escaping MenuBuilder.Block) {
        let nativeMenu = _NSMenu(title: title ?? "")
        menu = nativeMenu
        storage = nativeMenu.storage
        super.init()
        menu.delegate = self
        menu.cancelTracking()
        parseMenuBuilder(content().menuBuilderContent)
    }
    
    func parseMenuBuilder(_ item: MenuBuilderItem) {
        switch item {
        case .menuItems(let items):
            storage.items.append(contentsOf: items)
            items.forEach { menu.addItem($0.item) }
        case .items(let items): items.forEach { parseMenuBuilder($0) }
        case .none: break
        }
    }
    
    @available(*, deprecated, message: "Please use `dismiss()`")
    public func cancelTracking() {
        menu.cancelTracking()
    }
    
    @available(*, deprecated, message: "Please use `dismiss()`")
    public func cancelTrackingWithoutAnimation() {
        menu.cancelTrackingWithoutAnimation()
    }
    
    public func dismiss(_ animated: Bool = true) {
        guard animated else {
            menu.cancelTrackingWithoutAnimation()
            return
        }
        menu.cancelTracking()
    }
        
    public func title(_ value: String) -> Self {
        menu.title = value
        return self
    }
    
    /// Set and get whether the menu autoenables items.
    /// If a menu autoenables items, then calls to -[NSMenuItem setEnabled:] are ignored,
    /// and the enabled state is computed via the NSMenuValidation informal protocol below.
    /// Autoenabling is on by default.
    public func autoenablesItems(_ value: Bool = true) -> Self {
        menu.autoenablesItems = value
        return self
    }
    
    /// Set the minimum width of the menu, in screen coordinates.
    /// The menu will prefer to not draw smaller than its minimum width,
    /// but may draw larger if it needs more space.
    /// The default value is 0.
    public func minimumWidth(_ value: CGFloat) -> Self {
        menu.minimumWidth = value
        return self
    }
    
    /// Sets the font for the menu.
    /// This also affects the font of all submenus that do not have their own font.
    public func font(_ value: NSFont) -> Self {
        menu.font = value
        return self
    }
    
    /// Determines whether contextual menu plugins may be appended to the menu,
    /// if used as a context menu.
    /// The default is YES.
    public func allowsContextMenuPlugIns(_ value: Bool) -> Self {
        menu.allowsContextMenuPlugIns = value
        return self
    }

    
    /// Determines whether the menu contains a column for the state image.
    /// The default is YES.
    public func showsStateColumn(_ value: Bool) -> Self {
        menu.showsStateColumn = value
        return self
    }

    
    /// Determines the layout direction for menu items in the menu.
    /// If no layout direction is explicitly set, the menu will default to the value of [NSApp userInterfaceLayoutDirection].
    public func userInterfaceLayoutDirection(_ value: NSUserInterfaceLayoutDirection) -> Self {
        menu.userInterfaceLayoutDirection = value
        return self
    }
}

public protocol MenuBuilderContent {
    var menuBuilderContent: MenuBuilderItem { get }
}

public enum MenuBuilderItem {
    case none
    case menuItems([MenuItem])
    case items([MenuBuilderItem])
}

struct _MenuContent: MenuBuilderContent {
    let menuBuilderContent: MenuBuilderItem
}

@resultBuilder public struct MenuBuilder {
    public typealias Block = () -> MenuBuilderContent
    
    public static func buildBlock() -> MenuBuilderContent {
        _MenuContent(menuBuilderContent: .none)
    }
    
    public static func buildBlock(_ attrs: MenuBuilderContent...) -> MenuBuilderContent {
        buildBlock(attrs)
    }
    
    public static func buildBlock(_ attrs: [MenuBuilderContent]) -> MenuBuilderContent {
        _MenuContent(menuBuilderContent: .items(attrs.map { $0.menuBuilderContent }))
    }
    
    public static func buildIf(_ content: MenuBuilderContent?) -> MenuBuilderContent {
        guard let content = content else { return _MenuContent(menuBuilderContent: .none) }
        return _MenuContent(menuBuilderContent: .items([content.menuBuilderContent]))
    }
    
    public static func buildEither(first: MenuBuilderContent) -> MenuBuilderContent {
        _MenuContent(menuBuilderContent: .items([first.menuBuilderContent]))
    }

    public static func buildEither(second: MenuBuilderContent) -> MenuBuilderContent {
        _MenuContent(menuBuilderContent: .items([second.menuBuilderContent]))
    }
}
#endif
