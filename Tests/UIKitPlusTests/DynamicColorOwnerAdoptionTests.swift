#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import XCTest
@testable import UIKitPlus

#if os(macOS)
import AppKit

private func oppositeTheme(to theme: App.Theme) -> App.Theme {
    switch theme {
    case .light:
        return .dark
    case .dark:
        return .light
    }
}

private func expectedColor(
    for theme: App.Theme,
    light: NSColor,
    dark: NSColor
) -> NSColor {
    switch theme {
    case .light:
        return light
    case .dark:
        return dark
    }
}

private func assertColor(
    _ actual: NSColor?,
    equals expected: NSColor,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertTrue(
        actual?.isEqual(expected) == true,
        "Colors do not match",
        file: file,
        line: line
    )
}

final class DynamicColorOwnerAdoptionTests: XCTestCase {

    func testMacOSDynamicColorThemeListenerIsOwnedAndCancelsOnTeardown() throws {
        guard !Bundle.main.bundlePath.hasSuffix(".appex") else {
            throw XCTSkip("Dynamic Color theme listener is intentionally disabled in extension bundles")
        }

        let themeState = App.shared.$theme
        let originalTheme = themeState.wrappedValue

        defer {
            themeState.wrappedValue = originalTheme
        }

        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        themeState.listen { _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        weak var weakColor: Color?
        weak var weakToken: StateListener?

        autoreleasepool {
            var color: Color? = .init(
                light: NSColor.red,
                dark: NSColor.blue
            )

            weakColor = color

            guard let liveColor = color else {
                XCTFail("Expected live dynamic color")
                return
            }

            let tokens = Array(
                liveColor
                    .themeBindingHolder
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 1, let token = tokens.first else {
                XCTFail("Expected exactly one Color-owned theme token")
                return
            }

            weakToken = token
            color = nil
        }

        XCTAssertNil(weakColor)
        XCTAssertNil(weakToken)

        let countBeforeMutation = unrelatedCallCount

        themeState.wrappedValue = oppositeTheme(to: originalTheme)

        XCTAssertEqual(
            unrelatedCallCount,
            countBeforeMutation + 1
        )

        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }

    func testMacOSDynamicColorForwardsThemeChangesAndPreservesOnChangeReplacementSemantics() throws {
        guard !Bundle.main.bundlePath.hasSuffix(".appex") else {
            throw XCTSkip("Dynamic Color theme listener is intentionally disabled in extension bundles")
        }

        let themeState = App.shared.$theme
        let originalTheme = themeState.wrappedValue

        defer {
            themeState.wrappedValue = originalTheme
        }

        let light = NSColor.red
        let dark = NSColor.blue

        let color = Color(
            light: light,
            dark: dark
        )

        XCTAssertEqual(
            color
                .themeBindingHolder
                .statesValues
                .heldListeners
                .count,
            1
        )

        var firstHandlerCallCount = 0
        var secondHandlerCallCount = 0
        var lastEmittedColor: NSColor?

        color.onChange { _ in
            firstHandlerCallCount += 1
        }

        color.onChange { newColor in
            secondHandlerCallCount += 1
            lastEmittedColor = newColor
        }

        let nextTheme = oppositeTheme(to: originalTheme)

        themeState.wrappedValue = nextTheme

        XCTAssertEqual(firstHandlerCallCount, 0)
        XCTAssertEqual(secondHandlerCallCount, 1)

        assertColor(
            lastEmittedColor,
            equals: expectedColor(
                for: nextTheme,
                light: light,
                dark: dark
            )
        )

        assertColor(
            color.current,
            equals: expectedColor(
                for: nextTheme,
                light: light,
                dark: dark
            )
        )
    }

    func testMacOSDynamicColorInitializersInstallExactlyOneThemeListenerEach() throws {
        guard !Bundle.main.bundlePath.hasSuffix(".appex") else {
            throw XCTSkip("Dynamic Color theme listener is intentionally disabled in extension bundles")
        }

        let direct = Color(NSColor.red)

        let pair = Color(
            light: NSColor.red,
            dark: NSColor.blue
        )

        let copy = Color(pair)

        let nested = Color(
            light: direct,
            dark: pair
        )

        let colors = [
            direct,
            pair,
            copy,
            nested,
        ]

        XCTAssertEqual(colors.count, 4)

        for color in colors {
            XCTAssertEqual(
                color
                    .themeBindingHolder
                    .statesValues
                    .heldListeners
                    .count,
                1
            )
        }

        // This test intentionally verifies only listener ownership.
        // It does not characterize or repair copy-initializer color semantics.
    }
}
#endif
#endif
