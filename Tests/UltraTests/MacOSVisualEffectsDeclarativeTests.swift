#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
import XCTest
@testable import Ultra

@MainActor
private func assertColor(
    _ actual: NSColor?,
    equals expected: NSColor,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    guard let actual,
          let actualRGB = actual.usingColorSpace(.deviceRGB),
          let expectedRGB = expected.usingColorSpace(.deviceRGB) else {
        XCTFail("Expected device RGB colors", file: file, line: line)
        return
    }

    XCTAssertEqual(actualRGB.redComponent, expectedRGB.redComponent, accuracy: 0.0001, file: file, line: line)
    XCTAssertEqual(actualRGB.greenComponent, expectedRGB.greenComponent, accuracy: 0.0001, file: file, line: line)
    XCTAssertEqual(actualRGB.blueComponent, expectedRGB.blueComponent, accuracy: 0.0001, file: file, line: line)
    XCTAssertEqual(actualRGB.alphaComponent, expectedRGB.alphaComponent, accuracy: 0.0001, file: file, line: line)
}

@MainActor
private func ensureUltraApplication() {
    _ = App.shared
}

@MainActor
final class MacOSVisualEffectsDeclarativeTests: XCTestCase {
    func testVisualEffectAppearanceModifierReturnsSameInstanceAndAppliesAppearance() {
        ensureUltraApplication()
        let view = UVisualEffectView()

        XCTAssertTrue(view.appearance(.darkAqua) === view)
        XCTAssertEqual(view.appearance?.name, .darkAqua)
        XCTAssertTrue(view._properties.stateBindingHolder.statesValues.heldListeners.isEmpty)
        XCTAssertTrue(view.constraints.isEmpty)
    }

    func testGlassEffectViewInitializersPreserveDeclarativeIdentity() throws {
        ensureUltraApplication()
        guard #available(macOS 26.0, *) else {
            throw XCTSkip("NSGlassEffectView requires macOS 26.0")
        }

        let nativeDefaults = NSGlassEffectView(frame: .zero)
        let frameView = UGlassEffectView(frame: NSRect(x: 1, y: 2, width: 3, height: 4))
        let convenienceView = UGlassEffectView()

        for view in [frameView, convenienceView] {
            XCTAssertTrue(view.declarativeView === view)
            XCTAssertFalse(view.translatesAutoresizingMaskIntoConstraints)
            XCTAssertTrue(view.constraints.isEmpty)
            XCTAssertTrue(view._properties.notAppliedPreConstraintsSolo.isEmpty)
            XCTAssertTrue(view._properties.notAppliedPreConstraintsSuper.isEmpty)
            XCTAssertTrue(view._properties.notAppliedPreConstraintsRelative.isEmpty)
            XCTAssertTrue(view._properties.stateBindingHolder.statesValues.heldListeners.isEmpty)
            XCTAssertEqual(view.style, nativeDefaults.style)
            XCTAssertEqual(view.tintColor, nativeDefaults.tintColor)
            XCTAssertEqual(view.cornerRadius, nativeDefaults.cornerRadius)
            XCTAssertEqual(view.contentView == nil, nativeDefaults.contentView == nil)
        }

        XCTAssertEqual(frameView.frame, NSRect(x: 1, y: 2, width: 3, height: 4))
    }

    func testGlassEffectStyleModifierIsFluent() throws {
        ensureUltraApplication()
        guard #available(macOS 26.0, *) else {
            throw XCTSkip("NSGlassEffectView requires macOS 26.0")
        }

        let view = UGlassEffectView()
        XCTAssertTrue(view.style(.regular) === view)
        XCTAssertEqual(view.style, .regular)
        XCTAssertTrue(view.style(.clear) === view)
        XCTAssertEqual(view.style, .clear)
    }

    func testGlassEffectTintColorModifierIsFluent() throws {
        ensureUltraApplication()
        guard #available(macOS 26.0, *) else {
            throw XCTSkip("NSGlassEffectView requires macOS 26.0")
        }

        let view = UGlassEffectView()
        XCTAssertTrue(view.tintColor(.systemBlue) === view)
        assertColor(view.tintColor, equals: .systemBlue)
        XCTAssertTrue(view.tintColor(.systemRed) === view)
        assertColor(view.tintColor, equals: .systemRed)
        XCTAssertTrue(view.tintColor(nil) === view)
        XCTAssertNil(view.tintColor)
    }

    func testGlassEffectCornerRadiusModifierIsFluent() throws {
        ensureUltraApplication()
        guard #available(macOS 26.0, *) else {
            throw XCTSkip("NSGlassEffectView requires macOS 26.0")
        }

        let view = UGlassEffectView()
        XCTAssertTrue(view.cornerRadius(12) === view)
        XCTAssertEqual(view.cornerRadius, 12)
        XCTAssertTrue(view.cornerRadius(24) === view)
        XCTAssertEqual(view.cornerRadius, 24)
    }

    func testGlassEffectContentViewModifierIsFluent() throws {
        ensureUltraApplication()
        guard #available(macOS 26.0, *) else {
            throw XCTSkip("NSGlassEffectView requires macOS 26.0")
        }

        let view = UGlassEffectView()
        let first = NSView()
        let second = NSView()

        XCTAssertTrue(view.contentView(first) === view)
        XCTAssertTrue(view.contentView === first)
        XCTAssertTrue(view.contentView(second) === view)
        XCTAssertTrue(view.contentView === second)
        XCTAssertTrue(view.contentView(nil) === view)
        XCTAssertNil(view.contentView)
    }

    func testGlassAvailabilityBranchComposesNativeGlassOrLegacyFallback() {
        ensureUltraApplication()
        let container = UView {
            if #available(macOS 26.0, *) {
                UGlassEffectView()
                    .edgesToSuperview()
                    .style(.regular)
            } else {
                UVisualEffectView()
                    .edgesToSuperview()
                    .material(.fullScreenUI)
                    .blendingMode(.behindWindow)
                    .state(.active)
                    .appearance(.darkAqua)
            }
        }

        XCTAssertEqual(container.subviews.count, 1)
        if #available(macOS 26.0, *) {
            XCTAssertTrue(container.subviews.first is UGlassEffectView)
        } else {
            XCTAssertTrue(container.subviews.first is UVisualEffectView)
        }
        XCTAssertFalse(container.subviews.first is UView)
    }
}
#endif
#endif
