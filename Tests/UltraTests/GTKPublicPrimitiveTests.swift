#if ULTRA_GTK_TESTS

import Foundation
import UltraCGTK
import UltraGTK
import XCTest
@testable import Ultra

private func runPublicGTKApp(
    _ body: @escaping @MainActor (GTKApplication) -> Void
) -> Int32 {
    MainActor.assumeIsolated {
        gtk_init()
        let application = GTKApplication(
            applicationID: "com.uikitultra.waveb.public",
            nonUnique: true
        )
        _ = application.onActivate(body)
        return application.run()
    }
}

@MainActor
private func emitClicked(_ button: GTKButton) {
    button.withNativeButton { nativeButton in
        let signalID = "clicked".withCString { name in
            g_signal_lookup(name, gtk_button_get_type())
        }
        precondition(signalID != 0)
        var instance = GValue()
        g_value_init_from_instance(&instance, UnsafeMutableRawPointer(nativeButton))
        g_signal_emitv(&instance, signalID, 0, nil)
        g_value_unset(&instance)
    }
}

@MainActor
private func nativeIdentity(_ view: GTKView) -> OpaquePointer {
    view.withNativeWidget { $0 }
}

final class GTKPublicPrimitiveTests: XCTestCase {
    func testDirectNativeHierarchyAndRawExternalChild() {
        final class RawView: GTKView {}
        MainActor.assumeIsolated {
            gtk_init()
            let raw = RawView()
            let text = UText("hello")
            let button = UButton("press")
            let vertical = UVStack {
                raw
                text
                button
            }
            let horizontal = UHStack { UText("horizontal") }

            XCTAssertEqual(vertical.children.count, 3)
            XCTAssertTrue(vertical.children[0] === raw)
            XCTAssertTrue(vertical.children[1] === text)
            XCTAssertTrue(vertical.children[2] === button)
            XCTAssertNotEqual(nativeIdentity(vertical), nativeIdentity(horizontal))
        }
    }

    func testTextStateInitialFutureBackgroundAndDetach() {
        let state = State(wrappedValue: "initial")
        let status = runPublicGTKApp { application in
            let label = UText(state)
            let window = Window { label }
            let nativeWindow = application.makeWindow()
            window._installGTKHierarchy(into: nativeWindow, runtime: application.runtime)
            XCTAssertEqual(label.text, "initial")
            state.wrappedValue = "future"
            XCTAssertEqual(label.text, "future")
            window._teardownGTKHierarchy()
            state.wrappedValue = "detached"
            XCTAssertEqual(label.text, "future")
            application.quit()
        }
        XCTAssertEqual(status, 0)
    }

    func testStackConcreteStateAdditiveConfigurationAndIdentity() {
        let spacing = State(wrappedValue: CGFloat(8))
        let margin = State(wrappedValue: CGFloat(4))
        let status = runPublicGTKApp { application in
            let stack = UVStack { UText("child") }
                .spacing(spacing)
                .spacing(12)
                .layoutMargin(margin)
                .centerInSuperview()
            let nativeWindow = application.makeWindow()
            let before = nativeIdentity(stack)
            let window = Window { stack }
            window._installGTKHierarchy(into: nativeWindow, runtime: application.runtime)
            let after = nativeIdentity(stack)
            XCTAssertEqual(stack.spacing, 12)
            XCTAssertEqual(stack.children.count, 1)
            spacing.wrappedValue = 20
            margin.wrappedValue = 9
            XCTAssertEqual(stack.spacing, 20)
            XCTAssertEqual(before, after)
            window._teardownGTKHierarchy()
            application.quit()
        }
        XCTAssertEqual(status, 0)
    }

    func testButtonActionSignalLifecycleAndExactIdentity() {
        var noArgumentCount = 0
        var received: UButton?
        let status = runPublicGTKApp { application in
            let button = UButton("click")
            _ = button.onAction { noArgumentCount += 1 }
            let window = Window { button }
            let nativeWindow = application.makeWindow()
            let before = nativeIdentity(button)
            window._installGTKHierarchy(into: nativeWindow, runtime: application.runtime)
            let after = nativeIdentity(button)
            emitClicked(button)
            XCTAssertEqual(noArgumentCount, 1)
            _ = button.onAction { received = $0 }
            emitClicked(button)
            XCTAssertTrue(received === button)
            XCTAssertEqual(before, after)
            window._teardownGTKHierarchy()
            application.quit()
        }
        XCTAssertEqual(status, 0)
    }

    func testConversionValidationIsFiniteAndPositive() {
        MainActor.assumeIsolated {
            XCTAssertEqual(gtkPositiveInt32OrNil(12.4), 12)
            XCTAssertNil(gtkPositiveInt32OrNil(0))
            XCTAssertNil(gtkPositiveInt32OrNil(.infinity))
            XCTAssertEqual(gtkNonNegativeInt32OrNil(0), 0)
            XCTAssertNil(gtkNonNegativeInt32OrNil(-1))
        }
    }
}

#endif
