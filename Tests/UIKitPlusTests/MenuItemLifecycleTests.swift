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

    func testMenuItemTitleInitializerRetainsThroughItemRootCycle() {
        weak var weakItem: MenuItem?

        autoreleasepool {
            var item: MenuItem? = MenuItem("Test")
            weakItem = item
            item = nil
        }

        XCTAssertNotNil(
            weakItem,
            "Current-source baseline: MenuItem(\"Test\") initializes lazy item and is retained by MenuItem -> _MenuItem.root -> MenuItem."
        )
    }

    func testMenuItemExplicitItemAccessRetainsThroughItemRootCycle() {
        weak var weakItem: MenuItem?

        autoreleasepool {
            var item: MenuItem? = MenuItem(nil)
            _ = item?.item
            weakItem = item
            item = nil
        }

        XCTAssertNotNil(
            weakItem,
            "Current-source baseline: explicit .item access initializes _MenuItem(self) and creates the item/root cycle."
        )
    }

    func testMenuItemVoidOnActionRetainsThroughItemAndHelperCycles() {
        weak var weakItem: MenuItem?

        autoreleasepool {
            var item: MenuItem? = MenuItem(nil)
            _ = item?.onAction { }
            weakItem = item
            item = nil
        }

        XCTAssertNotNil(
            weakItem,
            "Current-source baseline: onAction { } initializes item and helper through item.target = helper, so paths 1+2 retain MenuItem without user-closure self capture."
        )
    }

    func testMenuItemArgumentOnActionAddsClosureSelfCaptureOnTopOfItemAndHelperCycles() {
        weak var weakItem: MenuItem?

        autoreleasepool {
            var item: MenuItem? = MenuItem(nil)
            _ = item?.onAction { menuItem in
                _ = menuItem.title
            }
            weakItem = item
            item = nil
        }

        XCTAssertNotNil(
            weakItem,
            "Current-source baseline: MenuItem-argument onAction adds closure self-capture on top of item/helper cycles; this does not isolate path 3 independently."
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

    func testMenuItemAfterNSMenuInsertionAndRemovalRemainsRetainedBySourceCycles() {
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

        XCTAssertNotNil(
            weakItem,
            "Current-source baseline: NSMenu removal does not break MenuItem's source-level item/root cycle."
        )
    }
}
#endif
