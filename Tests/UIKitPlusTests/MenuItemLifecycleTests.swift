#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import UIKitPlus

#if os(macOS)
import AppKit

final class MenuItemLifecycleTests: XCTestCase {
    final class Target: NSObject {
        @objc func action(_ sender: Any?) {}
    }

    func testMenuItemWithoutLazyAccessDeallocates() {
        weak var weakItem: MenuItem?

        autoreleasepool {
            var item: MenuItem? = MenuItem(nil)
            weakItem = item
            item = nil
        }

        XCTAssertNil(
            weakItem,
            "MenuItem(nil) without lazy item/helper access should deallocate because no cycle has been created."
        )
    }

    func testMenuItemTitleInitializerDeallocatesAfterRemovingItemRootCycle() {
        weak var weakItem: MenuItem?

        autoreleasepool {
            var item: MenuItem? = MenuItem("Test")
            weakItem = item
            item = nil
        }

        XCTAssertNil(
            weakItem,
            "MenuItem(\"Test\") should deallocate after removing _MenuItem.root because title init no longer creates a source-level retain cycle."
        )
    }

    func testMenuItemExplicitItemAccessDeallocatesAfterRemovingItemRootCycle() {
        weak var weakItem: MenuItem?

        autoreleasepool {
            var item: MenuItem? = MenuItem(nil)
            _ = item?.item
            weakItem = item
            item = nil
        }

        XCTAssertNil(
            weakItem,
            "Explicit .item access should no longer create a retain cycle after removing _MenuItem.root."
        )
    }

    func testMenuItemVoidOnActionDeallocatesAfterRemovingItemAndHelperRootCycles() {
        weak var weakItem: MenuItem?

        autoreleasepool {
            var item: MenuItem? = MenuItem(nil)
            _ = item?.onAction { }
            weakItem = item
            item = nil
        }

        XCTAssertNil(
            weakItem,
            "onAction { } initializes item/helper but no longer creates source-level cycles after root removal."
        )
    }

    func testMenuItemArgumentOnActionDeallocatesAfterWeakCaptureAndRootRemoval() {
        weak var weakItem: MenuItem?

        autoreleasepool {
            var item: MenuItem? = MenuItem(nil)
            _ = item?.onAction { menuItem in
                _ = menuItem.title
            }
            weakItem = item
            item = nil
        }

        XCTAssertNil(
            weakItem,
            "Weak self capture plus root removal prevents the closure cycle in MenuItem-argument onAction."
        )
    }

    func testRawNSMenuItemTargetDoesNotRetainTargetInCurrentAppKit() {
        weak var weakTarget: Target?
        var menuItem: NSMenuItem? = NSMenuItem(title: "Test", action: nil, keyEquivalent: "")

        autoreleasepool {
            var target: Target? = Target()
            weakTarget = target

            menuItem?.target = target
            menuItem?.action = #selector(Target.action(_:))

            target = nil
        }

        XCTAssertNil(
            weakTarget,
            "Empirical AppKit baseline: raw NSMenuItem.target is expected not to retain the target. If this fails, RISK-32 must be updated before any MenuItem lifecycle fix."
        )

        menuItem?.target = nil
        menuItem = nil
    }

    func testMenuItemAfterNSMenuInsertionAndRemovalDeallocatesAfterRootRemoval() {
        weak var weakItem: MenuItem?

        autoreleasepool {
            let menu = NSMenu()
            var item: MenuItem? = MenuItem("Test")
            weakItem = item

            if let nsItem = item?.item {
                menu.addItem(nsItem)
                menu.removeItem(nsItem)
            }

            item = nil
        }

        XCTAssertNil(
            weakItem,
            "NSMenu removal should not prevent MenuItem deallocation after root removal."
        )
    }

    func testMenuBuilderRetainsMenuItemThroughMenuItemsWhileMenuExists() {
        weak var weakItem: MenuItem?
        var menu: Menu?

        autoreleasepool {
            let item = MenuItem("Open").onAction { }
            weakItem = item

            menu = Menu {
                item
            }
        }

        XCTAssertNotNil(
            weakItem,
            "Normal DSL Menu usage should keep MenuItem alive through Menu.items while Menu exists."
        )

        XCTAssertEqual(menu?.items.count, 1)

        menu = nil

        XCTAssertNil(
            weakItem,
            "MenuItem should deallocate after Menu is released because Menu.items was the authoritative owner."
        )
    }

    @MainActor
    func testNativeMenuRetainsBuilderActionAfterMenuWrapperDeallocation() {
        var actionCount = 0
        weak var weakItem: MenuItem?
        var nativeMenu: NSMenu?

        autoreleasepool {
            var item: MenuItem? = MenuItem("Quit")
                .key("q")
                .keyMask(.command)
                .onAction {
                    actionCount += 1
                }

            weakItem = item

            var menu: Menu? = Menu {
                item!
            }

            nativeMenu = menu?.menu

            XCTAssertEqual(menu?.items.count, 1)
            XCTAssertEqual(nativeMenu?.numberOfItems, 1)

            item = nil
            menu = nil
        }

        XCTAssertNotNil(
            weakItem,
            "The native NSMenu must retain the declarative MenuItem after the temporary Menu wrapper is released."
        )

        XCTAssertEqual(nativeMenu?.item(at: 0)?.keyEquivalent, "q")
        XCTAssertEqual(
            nativeMenu?.item(at: 0)?.keyEquivalentModifierMask,
            .command
        )
        XCTAssertNotNil(nativeMenu?.item(at: 0)?.target)
        XCTAssertNotNil(nativeMenu?.item(at: 0)?.action)

        _ = NSApplication.shared
        nativeMenu?.performActionForItem(at: 0)

        XCTAssertEqual(
            actionCount,
            1,
            "A closure-based native menu action must still execute after the temporary Menu wrapper is released."
        )

        nativeMenu = nil

        XCTAssertNil(
            weakItem,
            "Releasing the native menu must release its declarative MenuItem ownership."
        )
    }

    @MainActor
    func testSubmenuRetainsBuilderActionAfterTemporaryMenuWrapperDeallocation() {
        var actionCount = 0
        weak var weakChildItem: MenuItem?
        var rootNativeMenu: NSMenu?
        var nativeSubmenu: NSMenu?

        autoreleasepool {
            var childItem: MenuItem? = MenuItem("Quit")
                .key("q")
                .keyMask(.command)
                .onAction {
                    actionCount += 1
                }

            weakChildItem = childItem

            var rootMenu: Menu? = Menu {
                MenuItem("Application").submenu {
                    childItem!
                }
            }

            rootNativeMenu = rootMenu?.menu

            XCTAssertEqual(rootMenu?.items.count, 1)
            XCTAssertEqual(rootNativeMenu?.numberOfItems, 1)

            childItem = nil
            rootMenu = nil
        }

        XCTAssertNotNil(
            weakChildItem,
            "A native submenu must retain its declarative child action owner after temporary wrappers are released."
        )

        nativeSubmenu = rootNativeMenu?.item(at: 0)?.submenu

        XCTAssertEqual(nativeSubmenu?.numberOfItems, 1)
        XCTAssertEqual(nativeSubmenu?.item(at: 0)?.keyEquivalent, "q")
        XCTAssertEqual(
            nativeSubmenu?.item(at: 0)?.keyEquivalentModifierMask,
            .command
        )
        XCTAssertNotNil(nativeSubmenu?.item(at: 0)?.target)
        XCTAssertNotNil(nativeSubmenu?.item(at: 0)?.action)

        _ = NSApplication.shared
        nativeSubmenu?.performActionForItem(at: 0)

        XCTAssertEqual(actionCount, 1)

        nativeSubmenu = nil
        rootNativeMenu = nil

        XCTAssertNil(
            weakChildItem,
            "Releasing the root native menu graph must release the declarative submenu item."
        )
    }

    func testWrappingExternalNSMenuPreservesNativeIdentity() {
        let nativeMenu = NSMenu(title: "External")
        let menu = Menu(nativeMenu)

        XCTAssertTrue(
            menu.menu === nativeMenu,
            "Menu.init(_:) must continue wrapping the exact supplied NSMenu instance."
        )
        XCTAssertEqual(menu.items.count, 0)
    }
}
#endif
#endif
