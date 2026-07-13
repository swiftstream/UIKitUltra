#if os(iOS) || os(tvOS)
import UIKit
import XCTest
@testable import UIKitPlus

@MainActor
private func assertColor(
    _ actual: UIColor?,
    equals expected: UIColor,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    var actualRed: CGFloat = 0
    var actualGreen: CGFloat = 0
    var actualBlue: CGFloat = 0
    var actualAlpha: CGFloat = 0
    var expectedRed: CGFloat = 0
    var expectedGreen: CGFloat = 0
    var expectedBlue: CGFloat = 0
    var expectedAlpha: CGFloat = 0

    guard let actual,
          actual.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha),
          expected.getRed(&expectedRed, green: &expectedGreen, blue: &expectedBlue, alpha: &expectedAlpha) else {
        XCTFail("Expected RGB colors", file: file, line: line)
        return
    }

    XCTAssertEqual(actualRed, expectedRed, accuracy: 0.0001, file: file, line: line)
    XCTAssertEqual(actualGreen, expectedGreen, accuracy: 0.0001, file: file, line: line)
    XCTAssertEqual(actualBlue, expectedBlue, accuracy: 0.0001, file: file, line: line)
    XCTAssertEqual(actualAlpha, expectedAlpha, accuracy: 0.0001, file: file, line: line)
}

@available(iOS 26.0, tvOS 26.0, *)
@MainActor
final class UIKitGlassEffectsDeclarativeTests: XCTestCase {
    func testGlassEffectUsesNativeStyleInitializer() {
        let regularInput = UIGlassEffect(style: .regular)
        let clearInput = UIGlassEffect(style: .clear)
        let regularView = UVisualEffectView(regularInput)
        let clearView = UVisualEffectView(clearInput)

        XCTAssertTrue(regularView.declarativeView === regularView)
        XCTAssertTrue(clearView.declarativeView === clearView)
        XCTAssertNotNil(regularView.effect as? UIGlassEffect)
        XCTAssertNotNil(clearView.effect as? UIGlassEffect)
    }

    func testGlassEffectTintColorModifierIsFluent() {
        let effect = UIGlassEffect(style: .regular)
        XCTAssertTrue(effect.tintColor(.systemBlue) === effect)
        assertColor(effect.tintColor, equals: .systemBlue)
        XCTAssertTrue(effect.tintColor(.systemRed) === effect)
        assertColor(effect.tintColor, equals: .systemRed)
        XCTAssertTrue(effect.tintColor(nil) === effect)
        XCTAssertNil(effect.tintColor)
    }

    func testGlassEffectInteractiveModifierIsFluent() {
        let effect = UIGlassEffect(style: .regular)
        XCTAssertTrue(effect.interactive() === effect)
        XCTAssertTrue(effect.isInteractive)
        XCTAssertTrue(effect.interactive(false) === effect)
        XCTAssertFalse(effect.isInteractive)
    }

    func testGlassContainerSpacingModifierIsFluent() {
        let effect = UIGlassContainerEffect()
        XCTAssertTrue(effect.spacing(12) === effect)
        XCTAssertEqual(effect.spacing, 12)
        XCTAssertTrue(effect.spacing(24) === effect)
        XCTAssertEqual(effect.spacing, 24)
    }

    func testDeclarativeCornerConfigurationModifierIsFluent() {
        let view = UView()
        let first = UICornerConfiguration.uniformCorners(radius: .fixed(16))
        let second = UICornerConfiguration.uniformCorners(radius: .fixed(24))
        let initialConstraintCount = view.constraints.count
        let initialSoloConstraintCount = view._properties.notAppliedPreConstraintsSolo.count
        let initialSuperConstraintCount = view._properties.notAppliedPreConstraintsSuper.count
        let initialRelativeConstraintCount = view._properties.notAppliedPreConstraintsRelative.count

        XCTAssertTrue(view.cornerConfiguration(first) === view)
        XCTAssertEqual(view.declarativeView.cornerConfiguration, first)
        XCTAssertTrue(view.cornerConfiguration(second) === view)
        XCTAssertEqual(view.declarativeView.cornerConfiguration, second)
        XCTAssertTrue(view._properties.stateBindingHolder.statesValues.heldListeners.isEmpty)
        XCTAssertEqual(view.constraints.count, initialConstraintCount)
        XCTAssertEqual(view._properties.notAppliedPreConstraintsSolo.count, initialSoloConstraintCount)
        XCTAssertEqual(view._properties.notAppliedPreConstraintsSuper.count, initialSuperConstraintCount)
        XCTAssertEqual(view._properties.notAppliedPreConstraintsRelative.count, initialRelativeConstraintCount)

        let effectView = UVisualEffectView(UIGlassEffect(style: .regular))
        XCTAssertTrue(effectView.cornerConfiguration(first) === effectView)
        XCTAssertEqual(effectView.cornerConfiguration, first)
    }

    func testGlassEffectInstallsThroughExistingUVisualEffectView() {
        let input = UIGlassEffect(style: .regular)
            .tintColor(.systemBlue)
            .interactive()
        let view = UVisualEffectView(input)

        XCTAssertTrue(view.declarativeView === view)
        guard let installed = view.effect as? UIGlassEffect else {
            XCTFail("Expected UIGlassEffect")
            return
        }
        assertColor(installed.tintColor, equals: .systemBlue)
        XCTAssertTrue(installed.isInteractive)
        XCTAssertTrue(view._properties.stateBindingHolder.statesValues.heldListeners.isEmpty)
        XCTAssertTrue(view.constraints.isEmpty)
        XCTAssertTrue(view._properties.notAppliedPreConstraintsSolo.isEmpty)
        XCTAssertTrue(view._properties.notAppliedPreConstraintsSuper.isEmpty)
        XCTAssertTrue(view._properties.notAppliedPreConstraintsRelative.isEmpty)
    }

    func testGlassContainerEffectInstallsThroughExistingUVisualEffectView() {
        let input = UIGlassContainerEffect()
            .spacing(24)
        let view = UVisualEffectView(input)

        XCTAssertTrue(view.declarativeView === view)
        guard let installed = view.effect as? UIGlassContainerEffect else {
            XCTFail("Expected UIGlassContainerEffect")
            return
        }
        XCTAssertEqual(installed.spacing, 24)
        XCTAssertTrue(view._properties.stateBindingHolder.statesValues.heldListeners.isEmpty)
        XCTAssertTrue(view.constraints.isEmpty)
        XCTAssertTrue(view._properties.notAppliedPreConstraintsSolo.isEmpty)
        XCTAssertTrue(view._properties.notAppliedPreConstraintsSuper.isEmpty)
        XCTAssertTrue(view._properties.notAppliedPreConstraintsRelative.isEmpty)
    }
}
#endif
