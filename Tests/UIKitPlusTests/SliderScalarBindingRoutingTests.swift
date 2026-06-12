import Foundation
import XCTest
@testable import UIKitPlus

#if !os(macOS)
#if !os(tvOS)
import UIKit

private final class SliderWeakStateListenerBox {
    weak var value: StateListener?

    init(_ value: StateListener) {
        self.value = value
    }
}

private func sliderHeldListenerIDs(of slider: USlider) -> Set<UUID> {
    Set(
        slider
            .stateBindingHolder
            .statesValues
            .heldListeners
            .values
            .map(\.id)
    )
}

private func sliderHeldListenerCount(of slider: USlider) -> Int {
    slider.stateBindingHolder.statesValues.heldListeners.count
}

private func newlyHeldSliderListeners(
    of slider: USlider,
    excluding baselineIDs: Set<UUID>
) -> [StateListener] {
    slider
        .stateBindingHolder
        .statesValues
        .heldListeners
        .values
        .filter {
            !baselineIDs.contains($0.id)
        }
}

private final class SliderBindingSources {
    let value = State<Float>(wrappedValue: 0.25)
    let minimumValue = State<Float>(wrappedValue: 0)
    let maximumValue = State<Float>(wrappedValue: 1)
    let minimumValueImage = State<UIImage?>(wrappedValue: UIImage())
    let maximumValueImage = State<UIImage?>(wrappedValue: UIImage())
    let isContinuous = State<Bool>(wrappedValue: true)
    let minimumTrackTintColorUIColor = State<UIColor>(wrappedValue: .red)
    let minimumTrackTintColorInt = State<Int>(wrappedValue: 0x00FF00)
    let maximumTrackTintColorUIColor = State<UIColor>(wrappedValue: .blue)
    let maximumTrackTintColorInt = State<Int>(wrappedValue: 0xFF0000)
    let thumbTintColorUIColor = State<UIColor>(wrappedValue: .purple)
    let thumbTintColorInt = State<Int>(wrappedValue: 0x0000FF)
    let tintColorUIColor = State<UIColor>(wrappedValue: .orange)
    let tintColorInt = State<Int>(wrappedValue: 0x00FFFF)
    let thumbImage = State<UIImage?>(wrappedValue: UIImage())

    @discardableResult
    func bind(to slider: USlider) -> USlider {
        slider
            .value(value)
            .minimumValue(minimumValue)
            .maximumValue(maximumValue)
            .minimumValueImage(minimumValueImage)
            .maximumValueImage(maximumValueImage)
            .isContinuous(isContinuous)
            .minimumTrackTintColor(minimumTrackTintColorUIColor)
            .minimumTrackTintColor(minimumTrackTintColorInt)
            .maximumTrackTintColor(maximumTrackTintColorUIColor)
            .maximumTrackTintColor(maximumTrackTintColorInt)
            .thumbTintColor(thumbTintColorUIColor)
            .thumbTintColor(thumbTintColorInt)
            .tintColor(tintColorUIColor)
            .tintColor(tintColorInt)
            .thumbImage(thumbImage)
    }
}

final class SliderScalarBindingRoutingTests: XCTestCase {

    func testSliderAllFifteenBindingsRouteIntoOwnerHolder() {
        let slider = USlider(frame: .zero)
        let sources = SliderBindingSources()
        let baselineCount = sliderHeldListenerCount(of: slider)

        _ = sources.bind(to: slider)

        XCTAssertEqual(
            sliderHeldListenerCount(of: slider),
            baselineCount + 15
        )
    }

    func testSliderNumericBooleanAndColorBindingsRemainLive() {
        let slider = USlider(frame: .zero)
        let sources = SliderBindingSources()

        _ = sources.bind(to: slider)

        sources.value.wrappedValue = 0.75
        XCTAssertEqual(slider.value, 0.75, accuracy: 0.0001)

        sources.minimumValue.wrappedValue = 0.1
        XCTAssertEqual(slider.minimumValue, 0.1, accuracy: 0.0001)

        sources.maximumValue.wrappedValue = 0.9
        XCTAssertEqual(slider.maximumValue, 0.9, accuracy: 0.0001)

        sources.isContinuous.wrappedValue = false
        XCTAssertFalse(slider.isContinuous)

        sources.minimumTrackTintColorUIColor.wrappedValue = .yellow
        XCTAssertTrue(
            slider.minimumTrackTintColor?.isEqual(UIColor.yellow) == true
        )

        sources.minimumTrackTintColorInt.wrappedValue = 0x123456
        XCTAssertTrue(
            slider.minimumTrackTintColor?.isEqual(0x123456.color) == true
        )

        sources.maximumTrackTintColorUIColor.wrappedValue = .brown
        XCTAssertTrue(
            slider.maximumTrackTintColor?.isEqual(UIColor.brown) == true
        )

        sources.maximumTrackTintColorInt.wrappedValue = 0x654321
        XCTAssertTrue(
            slider.maximumTrackTintColor?.isEqual(0x654321.color) == true
        )

        sources.thumbTintColorUIColor.wrappedValue = .magenta
        XCTAssertTrue(
            slider.thumbTintColor?.isEqual(UIColor.magenta) == true
        )

        sources.thumbTintColorInt.wrappedValue = 0xABCDEF
        XCTAssertTrue(
            slider.thumbTintColor?.isEqual(0xABCDEF.color) == true
        )

        sources.tintColorUIColor.wrappedValue = .cyan
        XCTAssertTrue(
            slider.tintColor?.isEqual(UIColor.cyan) == true
        )

        sources.tintColorInt.wrappedValue = 0xFEDCBA
        XCTAssertTrue(
            slider.tintColor?.isEqual(0xFEDCBA.color) == true
        )
    }

    func testSliderImageBindingsRemainLive() {
        let slider = USlider(frame: .zero)
        let sources = SliderBindingSources()

        _ = sources.bind(to: slider)

        let newMinimumImage = UIImage()
        sources.minimumValueImage.wrappedValue = newMinimumImage
        XCTAssertTrue(slider.minimumValueImage === newMinimumImage)

        let newMaximumImage = UIImage()
        sources.maximumValueImage.wrappedValue = newMaximumImage
        XCTAssertTrue(slider.maximumValueImage === newMaximumImage)

        let newThumbImage = UIImage()
        sources.thumbImage.wrappedValue = newThumbImage
        XCTAssertTrue(slider.thumbImage(for: .normal) === newThumbImage)
    }

    func testSliderValueBindingPreservesWitnessAndRepeatedBindingsRemainAdditive() {
        let slider = USlider(frame: .zero)
        let valueState = State<Float>(wrappedValue: 0.25)
        let baselineCount = sliderHeldListenerCount(of: slider)
        let baselineIDs = sliderHeldListenerIDs(of: slider)

        _ = slider.value(valueState)
        _ = slider.value(valueState)

        let newTokens = newlyHeldSliderListeners(
            of: slider,
            excluding: baselineIDs
        )

        XCTAssertTrue(slider.bindValue === valueState)
        XCTAssertEqual(
            sliderHeldListenerCount(of: slider),
            baselineCount + 2
        )
        XCTAssertEqual(newTokens.count, 2)
        XCTAssertNotEqual(newTokens[0].id, newTokens[1].id)

        valueState.wrappedValue = 0.8

        XCTAssertEqual(slider.value, 0.8, accuracy: 0.0001)
    }

    func testSliderTeardownCancelsAllFifteenOwnedTokensAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let sources = SliderBindingSources()

        weak var weakSlider: USlider?
        var weakBoxes: [SliderWeakStateListenerBox] = []

        autoreleasepool {
            var slider: USlider? = USlider(frame: .zero)
            weakSlider = slider

            guard let liveSlider = slider else {
                XCTFail("Expected live slider")
                return
            }

            let baselineIDs = sliderHeldListenerIDs(of: liveSlider)

            _ = sources.bind(to: liveSlider)

            let newTokens = newlyHeldSliderListeners(
                of: liveSlider,
                excluding: baselineIDs
            )

            XCTAssertEqual(newTokens.count, 15)

            weakBoxes = newTokens.map {
                SliderWeakStateListenerBox($0)
            }

            slider = nil
        }

        XCTAssertNil(weakSlider)

        for (index, box) in weakBoxes.enumerated() {
            XCTAssertNil(
                box.value,
                "Token \(index) should have been deallocated"
            )
        }

        sources.value.wrappedValue = 0.5
        sources.minimumValue.wrappedValue = 0.1
        sources.maximumValue.wrappedValue = 0.9
        sources.minimumValueImage.wrappedValue = UIImage()
        sources.maximumValueImage.wrappedValue = UIImage()
        sources.isContinuous.wrappedValue = false
        sources.minimumTrackTintColorUIColor.wrappedValue = .yellow
        sources.minimumTrackTintColorInt.wrappedValue = 0x123456
        sources.maximumTrackTintColorUIColor.wrappedValue = .brown
        sources.maximumTrackTintColorInt.wrappedValue = 0x654321
        sources.thumbTintColorUIColor.wrappedValue = .magenta
        sources.thumbTintColorInt.wrappedValue = 0xABCDEF
        sources.tintColorUIColor.wrappedValue = .cyan
        sources.tintColorInt.wrappedValue = 0xFEDCBA
        sources.thumbImage.wrappedValue = UIImage()

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }
}

#endif
#endif
