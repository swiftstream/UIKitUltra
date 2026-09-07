#if os(macOS) || os(iOS) || os(tvOS)
//___FILEHEADER___

import AppKit
import UIKitPlus

@main
final class App: UIKitPlus.App {
    private lazy var shellWindow = Window {
        MainViewController()
    }

    @AppBuilder override var body: AppBuilderContent {
        shellWindow
            .title("___PACKAGENAME___")
            .size(900, 600)
            .minSize(.init(width: 640, height: 420))
            .center()
            .makeKeyAndOrderFront()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            _ = shellWindow.makeKeyAndOrderFront()
        }
        return true
    }

    @MenuBuilder override var topMenu: MenuBuilderContent {
        MenuItem("___PACKAGENAME___").submenu {
            MenuItem("About ___PACKAGENAME___").onAction {
                NSApp.orderFrontStandardAboutPanel(nil)
            }
            MenuItem.separator()
            MenuItem("Settings…").key(",").keyMask(.command).onAction {}
            MenuItem.separator()
            MenuItem("Hide ___PACKAGENAME___").key("h").keyMask(.command).onAction {
                NSApp.hide(nil)
            }
            MenuItem("Hide Others").key("h").keyMask([.command, .option]).onAction {
                NSApp.hideOtherApplications(nil)
            }
            MenuItem("Show All").onAction {
                NSApp.unhideAllApplications(nil)
            }
            MenuItem.separator()
            MenuItem("Quit ___PACKAGENAME___").key("q").keyMask(.command).onAction {
                NSApp.terminate(nil)
            }
        }

        MenuItem("File").submenu {
            MenuItem("New Window").key("n").keyMask(.command).onAction {
                _ = self.shellWindow.center().makeKeyAndOrderFront()
            }
            MenuItem.separator()
            MenuItem("Close Window").key("w").keyMask(.command).onAction {
                NSApp.keyWindow?.performClose(nil)
            }
        }

        MenuItem("Edit").submenu {
            MenuItem("Undo").key("z").keyMask(.command).onAction {
                NSApp.keyWindow?.undoManager?.undo()
            }
            MenuItem("Redo").key("Z").keyMask([.command, .shift]).onAction {
                NSApp.keyWindow?.undoManager?.redo()
            }
            MenuItem.separator()
            MenuItem("Cut").key("x").keyMask(.command).onAction {
                NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: nil)
            }
            MenuItem("Copy").key("c").keyMask(.command).onAction {
                NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil)
            }
            MenuItem("Paste").key("v").keyMask(.command).onAction {
                NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
            }
            MenuItem.separator()
            MenuItem("Select All").key("a").keyMask(.command).onAction {
                NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
            }
        }

        MenuItem("View").submenu {
            MenuItem("Center Window").onAction {
                _ = self.shellWindow.center().makeKeyAndOrderFront()
            }
            MenuItem("Enter Full Screen").key("f").keyMask([.command, .control]).onAction {
                NSApp.keyWindow?.toggleFullScreen(nil)
            }
        }

        MenuItem("Window").submenu {
            MenuItem("Minimize").key("m").keyMask(.command).onAction {
                NSApp.keyWindow?.miniaturize(nil)
            }
            MenuItem("Zoom").onAction {
                NSApp.keyWindow?.zoom(nil)
            }
            MenuItem.separator()
            MenuItem("Bring All to Front").onAction {
                NSApp.arrangeInFront(nil)
            }
        }

        MenuItem("Help").submenu {
            MenuItem("___PACKAGENAME___ Help").key("?").keyMask(.command).onAction {
                if let url = URL(string: "https://github.com/MihaelIsaev/UIKitPlus") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
}
#endif
