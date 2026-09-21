#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
import XCTest
@testable import Ultra

@MainActor
private func ensureUltraApplicationForViewControllerTests() {
    _ = App.shared
}

@MainActor
final class MacOSViewControllerWindowNotificationTests: XCTestCase {
    func testNotificationConfiguredBeforeAttachmentOnlyFiresForAttachedWindow() {
        ensureUltraApplicationForViewControllerTests()

        let controller = ViewController()
        var callbackCount = 0

        XCTAssertTrue(
            controller.onWindowDidBecomeKey { callbackCount += 1 } === controller
        )

        let attachedWindow = NSWindow(contentViewController: controller)
        let otherWindow = NSWindow()
        XCTAssertTrue(controller.window === attachedWindow)

        NotificationCenter.default.post(
            name: NSWindow.didBecomeKeyNotification,
            object: otherWindow
        )
        XCTAssertEqual(callbackCount, 0)

        NotificationCenter.default.post(
            name: NSWindow.didBecomeKeyNotification,
            object: attachedWindow
        )
        XCTAssertEqual(callbackCount, 1)
    }

    func testNotificationOverloadReceivesNativePayloadAndRepeatedRegistrationIsAdditive() {
        ensureUltraApplicationForViewControllerTests()

        let controller = ViewController()
        let attachedWindow = NSWindow(contentViewController: controller)
        var callbackCount = 0
        var receivedNotification: Notification?

        _ = controller.onWindowDidBecomeKey { _ in
            callbackCount += 1
        }
        _ = controller.onWindowDidBecomeKey { notification in
            receivedNotification = notification
        }

        let notification = Notification(
            name: NSWindow.didBecomeKeyNotification,
            object: attachedWindow,
            userInfo: ["test": "payload"]
        )
        NotificationCenter.default.post(notification)

        XCTAssertEqual(callbackCount, 1)
        XCTAssertEqual(receivedNotification?.object as? NSWindow, attachedWindow)
        XCTAssertEqual(receivedNotification?.userInfo?["test"] as? String, "payload")
    }
}
#endif
#endif
