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
}
#endif
