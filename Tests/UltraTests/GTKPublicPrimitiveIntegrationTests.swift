#if ULTRA_GTK_TESTS

import Foundation
import UltraCGTK
import UltraGTK
import XCTest
@testable import Ultra

private final class RawIntegrationView: GTKView {}

@MainActor
private final class IntegrationApp: Ultra.App {
    let configuredWindow: Window

    init(window: Window) {
        configuredWindow = window
        super.init()
    }

    required init() {
        configuredWindow = Window()
        super.init()
    }

    override var body: AppBuilderContent { configuredWindow }
}

final class GTKPublicPrimitiveIntegrationTests: XCTestCase {
    func testOneAppWindowRuntimeRootIdentityAndTeardown() throws {
        guard ProcessInfo.processInfo.environment["XDG_SESSION_TYPE"] == "wayland" else {
            throw XCTSkip("B07 requires the real Wayland Ubuntu session")
        }

        MainActor.assumeIsolated {
            let state = State(wrappedValue: "initial")
            let raw = RawIntegrationView()
            let label = UText(state)
            let button = UButton("activate")
            let root = UVStack {
                raw
                label
                button
            }
            let window = Window { root }
                .title("Wave B")
                .size(360, 180)
            let app = IntegrationApp(window: window)
            let appWindowCount = app.body.appBuilderContent._windows().count

            let rootIdentityBefore = root.withNativeWidget { $0 }
            Task { @MainActor in
                await Task.yield()
                app._quit()
            }
            let status = app.run()
            XCTAssertEqual(status, 0)
            let rootIdentityAfter = root.withNativeWidget { $0 }
            XCTAssertEqual(appWindowCount, 1)
            XCTAssertEqual(root.children.count, 3)
            XCTAssertEqual(label.text, "initial")
            XCTAssertEqual(rootIdentityBefore, rootIdentityAfter)
        }
    }

    func testExternalNativeSubclassRemainsFirstClassBodyBuilderChild() {
        MainActor.assumeIsolated {
            gtk_init()
            let raw = RawIntegrationView()
            let root = UHStack { raw }
            XCTAssertEqual(root.children.count, 1)
            XCTAssertTrue(root.children[0] === raw)
        }
    }
}

#endif
