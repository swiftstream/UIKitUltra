#if os(macOS) || os(iOS) || os(tvOS)
//
//  MacOSApplication.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 13.08.2020.
//

#if os(macOS)
import Cocoa
import UltraCore

open class App: NSApplication, NSApplicationDelegate {
    public static override var shared: App { super.shared as! App }
    
    static var currentTheme: Theme {
        UserDefaults.standard.string(forKey: "AppleInterfaceStyle")?.lowercased() == "dark" ? .dark : .light
    }
    
    @State public var theme: Theme = App.currentTheme
    
    public override init() {
        super.init()
        let menu = Menu()
        menu.parseMenuBuilder(topMenu.menuBuilderContent)
        mainMenu = menu.menu
        delegate = self
    }
    
    open override func run() {
        NSApp.setActivationPolicy(.regular) // switches app appearance mode
        NSApp.activate(ignoringOtherApps: true)
        super.run()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func applicationWillFinishLaunching(_ notification: Notification) {}
    
    open func applicationDidFinishLaunching(_ aNotification: Notification) {
        parseAppBuilderItem(body.appBuilderContent)
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(interfaceModeChanged),
            name: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )
    }
    
    @objc private func interfaceModeChanged() {
        self.theme = UserDefaults.standard.string(forKey: "AppleInterfaceStyle")?.lowercased() == "dark" ? .dark : .light
    }
    
    public enum Theme: CustomStringConvertible {
        case light, dark
        
        public var description: String {
            self == .light ? "light" : "dark"
        }
    }

    private var _windows: [Window] = []
    private var _windowTabGroups: [AnyWindowTabGroup] = []
    private var _statusItems: [StatusItem] = []

    @AppBuilder open var body: AppBuilderContent { Window() }

    private func parseAppBuilderItem(_ item: AppBuilderItem) {
        switch item {
        case .statusItems(let values): _statusItems.append(contentsOf: values)
        case .windows(let values): _windows.append(contentsOf: values)
        case .windowTabGroups(let values):
            _windowTabGroups.append(contentsOf: values)
            values.forEach { $0.activate() }
        case .items(let items): items.forEach { parseAppBuilderItem($0) }
        case .none: break
        }
    }
    
    open override func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown {
            if event.modifierFlags.contains(.command)  && NSEvent.ModifierFlags.deviceIndependentFlagsMask.contains(.command) {
                if event.modifierFlags.contains(.shift) && NSEvent.ModifierFlags.deviceIndependentFlagsMask.contains(.shift) {
                    if event.charactersIgnoringModifiers == "Z" {
                        if NSApp.sendAction(Selector("redo:"), to:nil, from:self) { return }
                    }
                }
                guard let key = event.charactersIgnoringModifiers else { return super.sendEvent(event) }
                switch key {
                case "x":
                    if NSApp.sendAction(Selector("cut:"), to:nil, from:self) { return }
                case "c":
                    if NSApp.sendAction(Selector("copy:"), to:nil, from:self) { return }
                case "v":
                    if NSApp.sendAction(Selector("paste:"), to:nil, from:self) { return }
                case "z":
                    if NSApp.sendAction(Selector("undo:"), to:nil, from:self) { return }
                case "a":
                    if NSApp.sendAction(Selector("selectAll:"), to:nil, from:self) { return }
                default:
                    break
              }
            }
        }
        super.sendEvent(event)
    }
    
    // MARK: Main Menu
    
    @MenuBuilder open var topMenu: MenuBuilderContent { _MenuContent(menuBuilderContent: .none) }
    
    // MARK: Dock Menu
    
    var _dockMenu: Menu?
    
    public var currentDockMenu: Menu {
        get {
            if let menu = _dockMenu {
                return menu
            }
            let menu = Menu()
            menu.parseMenuBuilder(dockMenu.menuBuilderContent)
            return menu
        }
        set { _dockMenu = newValue }
    }
    
    @MenuBuilder open var dockMenu: MenuBuilderContent { _MenuContent(menuBuilderContent: .none) }
    
    public func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        currentDockMenu.menu
    }
}


//public protocol WindowsBuilderContent {
//    var windowsBuilderContent: WindowsBuilderItem { get }
//}
//
//public enum WindowsBuilderItem {
//    case none
//    case windows([Window])
//    case items([WindowsBuilderItem])
//}
//
//struct _Content: WindowsBuilderContent {
//    let windowsBuilderContent: WindowsBuilderItem
//}
//
//@resultBuilder public struct WindowsBuilder {
//    public typealias Block = () -> WindowsBuilderContent
//    
//    public static func buildBlock() -> WindowsBuilderContent {
//        _Content(windowsBuilderContent: .none)
//    }
//    
//    public static func buildBlock(_ attrs: WindowsBuilderContent...) -> WindowsBuilderContent {
//        buildBlock(attrs)
//    }
//    
//    public static func buildBlock(_ attrs: [WindowsBuilderContent]) -> WindowsBuilderContent {
//        _Content(windowsBuilderContent: .items(attrs.map { $0.windowsBuilderContent }))
//    }
//    
//    public static func buildIf(_ content: WindowsBuilderContent?) -> WindowsBuilderContent {
//        guard let content = content else { return _Content(windowsBuilderContent: .none) }
//        return _Content(windowsBuilderContent: .items([content.windowsBuilderContent]))
//    }
//    
//    public static func buildEither(first: WindowsBuilderContent) -> WindowsBuilderContent {
//        _Content(windowsBuilderContent: .items([first.windowsBuilderContent]))
//    }
//
//    public static func buildEither(second: WindowsBuilderContent) -> WindowsBuilderContent {
//        _Content(windowsBuilderContent: .items([second.windowsBuilderContent]))
//    }
//}

@MainActor
public protocol AppBuilderContent {
    var appBuilderContent: AppBuilderItem { get }
}

public enum AppBuilderItem {
    /// An empty app-builder branch.
    case none
    /// Status-item roots retained by the macOS application.
    case statusItems([StatusItem])
    /// Standalone windows retained by the macOS application.
    case windows([Window])
    /// Native window-tab groups activated after application launch.
    case windowTabGroups([AnyWindowTabGroup])
    /// Nested app-builder branches.
    case items([AppBuilderItem])
}

struct _AppContent: AppBuilderContent {
    let appBuilderContent: AppBuilderItem
}

@resultBuilder public struct AppBuilder {
    public typealias Block = () -> AppBuilderContent
    
    @MainActor
    public static func buildBlock() -> AppBuilderContent {
        _AppContent(appBuilderContent: .none)
    }
    
    @MainActor
    public static func buildBlock(_ attrs: AppBuilderContent...) -> AppBuilderContent {
        buildBlock(attrs)
    }
    
    @MainActor
    public static func buildBlock(_ attrs: [AppBuilderContent]) -> AppBuilderContent {
        _AppContent(appBuilderContent: .items(attrs.map { $0.appBuilderContent }))
    }
    
    @MainActor
    public static func buildIf(_ content: AppBuilderContent?) -> AppBuilderContent {
        guard let content = content else { return _AppContent(appBuilderContent: .none) }
        return _AppContent(appBuilderContent: .items([content.appBuilderContent]))
    }
    
    @MainActor
    public static func buildEither(first: AppBuilderContent) -> AppBuilderContent {
        _AppContent(appBuilderContent: .items([first.appBuilderContent]))
    }

    @MainActor
    public static func buildEither(second: AppBuilderContent) -> AppBuilderContent {
        _AppContent(appBuilderContent: .items([second.appBuilderContent]))
    }
}

#else

#endif
#endif
