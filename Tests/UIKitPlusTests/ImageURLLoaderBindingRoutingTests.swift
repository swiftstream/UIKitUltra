import Foundation
import XCTest
@testable import UIKitPlus

#if os(macOS)
import AppKit
#else
import UIKit
#endif

private final class WeakStateListenerBox {
    weak var value: StateListener?

    init(_ value: StateListener) {
        self.value = value
    }
}

@MainActor private func heldListeners(of image: UImage) -> [StateListener] {
    Array(
        image
            .stateBindingHolder
            .statesValues
            .heldListeners
            .values
    )
}

@MainActor private func heldListenerCount(of image: UImage) -> Int {
    image.stateBindingHolder.statesValues.heldListeners.count
}

private func objectIdentifier(
    of image: _UImage?
) -> ObjectIdentifier? {
    guard let image else { return nil }
    return ObjectIdentifier(image)
}

private final class CancellationRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var storedCount = 0

    var count: Int {
        lock.withLock { storedCount }
    }

    func recordCancellation() {
        lock.withLock {
            storedCount += 1
        }
    }
}

private final class RecordingImageLoader: ImageLoader {

    enum Input: Equatable {
        case string(String?)
        case url(URL?)
    }

    struct Record: Equatable {
        let input: Input
        let imageViewID: ObjectIdentifier
        let defaultImageID: ObjectIdentifier?
    }

    private(set) var records: [Record] = []
    private nonisolated let cancellationRecorder = CancellationRecorder()
    var cancelCallCount: Int {
        cancellationRecorder.count
    }

    override func load(
        _ url: String?,
        imageView: _UImageView,
        defaultImage: _UImage? = nil
    ) {
        records.append(
            Record(
                input: .string(url),
                imageViewID: ObjectIdentifier(imageView),
                defaultImageID: objectIdentifier(of: defaultImage)
            )
        )
    }

    override func load(
        _ url: URL?,
        imageView: _UImageView,
        defaultImage: _UImage? = nil
    ) {
        records.append(
            Record(
                input: .url(url),
                imageViewID: ObjectIdentifier(imageView),
                defaultImageID: objectIdentifier(of: defaultImage)
            )
        )
    }

    nonisolated override func cancel() {
        cancellationRecorder.recordCancellation()
    }
}

#if !os(macOS)

@MainActor
final class ImageURLLoaderBindingRoutingTests: XCTestCase {

    func testUIImageStringURLStateInitializerRoutesTokenAndRecordsInitialAndLiveLoads() {
        let initial = "https://example.invalid/initial.png"
        let updated = "https://example.invalid/updated.png"
        let source = State<String?>(wrappedValue: initial)
        let loader = RecordingImageLoader()
        let defaultImage = UIImage()
        let owner = UImage(
            url: source,
            defaultImage: defaultImage,
            loader: loader
        )
        let ownerID = ObjectIdentifier(owner)
        let defaultImageID = ObjectIdentifier(defaultImage)

        XCTAssertEqual(heldListenerCount(of: owner), 1)
        XCTAssertEqual(heldListeners(of: owner).count, 1)
        XCTAssertTrue(owner.image === defaultImage)
        XCTAssertEqual(
            loader.records,
            [
                .init(
                    input: .string(initial),
                    imageViewID: ownerID,
                    defaultImageID: defaultImageID
                ),
            ]
        )
        XCTAssertEqual(loader.cancelCallCount, 0)

        source.wrappedValue = updated

        XCTAssertEqual(
            loader.records,
            [
                .init(
                    input: .string(initial),
                    imageViewID: ownerID,
                    defaultImageID: defaultImageID
                ),
                .init(
                    input: .string(updated),
                    imageViewID: ownerID,
                    defaultImageID: defaultImageID
                ),
            ]
        )
        XCTAssertEqual(loader.cancelCallCount, 0)
    }

    func testUIImageStringURLStateInitializerTeardownCancelsOwnedTokenAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let source = State<String?>(
            wrappedValue: "https://example.invalid/initial.png"
        )
        let loader = RecordingImageLoader()

        weak var weakOwner: UImage?
        var weakBox: WeakStateListenerBox?
        var recordCountBeforeTeardown = 0

        autoreleasepool {
            var owner: UImage? = UImage(
                url: source,
                defaultImage: UIImage(),
                loader: loader
            )
            weakOwner = owner

            guard let liveOwner = owner else {
                XCTFail("Expected live owner")
                return
            }

            let listeners = heldListeners(of: liveOwner)

            XCTAssertEqual(heldListenerCount(of: liveOwner), 1)
            XCTAssertEqual(listeners.count, 1)

            weakBox = WeakStateListenerBox(listeners[0])
            recordCountBeforeTeardown = loader.records.count

            XCTAssertEqual(recordCountBeforeTeardown, 1)
            XCTAssertEqual(loader.cancelCallCount, 0)

            owner = nil
        }

        XCTAssertNil(weakOwner)
        XCTAssertNil(weakBox?.value)
        XCTAssertEqual(loader.cancelCallCount, 1)

        source.wrappedValue =
            "https://example.invalid/after-teardown.png"

        XCTAssertEqual(
            loader.records.count,
            recordCountBeforeTeardown
        )

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }

    func testUIImageURLStateConvenienceInitializerRoutesDirectTokenAndRecordsInitialAndLiveURLLoads() {
        let initial = URL(
            string: "https://example.invalid/initial-url.png"
        )!
        let updated = URL(
            string: "https://example.invalid/updated-url.png"
        )!
        let source = State<URL?>(wrappedValue: initial)
        let loader = RecordingImageLoader()
        let defaultImage = UIImage()
        let owner = UImage(
            url: source,
            defaultImage: defaultImage,
            loader: loader
        )
        let ownerID = ObjectIdentifier(owner)
        let defaultImageID = ObjectIdentifier(defaultImage)

        XCTAssertEqual(heldListenerCount(of: owner), 1)
        XCTAssertEqual(heldListeners(of: owner).count, 1)
        XCTAssertTrue(owner.image === defaultImage)
        XCTAssertEqual(
            loader.records,
            [
                .init(
                    input: .url(initial),
                    imageViewID: ownerID,
                    defaultImageID: defaultImageID
                ),
            ]
        )
        XCTAssertEqual(loader.cancelCallCount, 0)

        source.wrappedValue = updated

        XCTAssertEqual(
            loader.records,
            [
                .init(
                    input: .url(initial),
                    imageViewID: ownerID,
                    defaultImageID: defaultImageID
                ),
                .init(
                    input: .url(updated),
                    imageViewID: ownerID,
                    defaultImageID: defaultImageID
                ),
            ]
        )
        XCTAssertEqual(loader.cancelCallCount, 0)
    }

    func testUIImageURLStateConvenienceInitializerTeardownCancelsOwnedTokenAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let source = State<URL?>(
            wrappedValue: URL(
                string: "https://example.invalid/initial-url.png"
            )!
        )
        let loader = RecordingImageLoader()

        weak var weakOwner: UImage?
        var weakBox: WeakStateListenerBox?
        var recordCountBeforeTeardown = 0

        autoreleasepool {
            var owner: UImage? = UImage(
                url: source,
                defaultImage: UIImage(),
                loader: loader
            )
            weakOwner = owner

            guard let liveOwner = owner else {
                XCTFail("Expected live owner")
                return
            }

            let listeners = heldListeners(of: liveOwner)

            XCTAssertEqual(heldListenerCount(of: liveOwner), 1)
            XCTAssertEqual(listeners.count, 1)

            weakBox = WeakStateListenerBox(listeners[0])
            recordCountBeforeTeardown = loader.records.count

            XCTAssertEqual(recordCountBeforeTeardown, 1)
            XCTAssertEqual(loader.cancelCallCount, 0)

            owner = nil
        }

        XCTAssertNil(weakOwner)
        XCTAssertNil(weakBox?.value)
        XCTAssertEqual(loader.cancelCallCount, 1)

        source.wrappedValue = URL(
            string: "https://example.invalid/after-teardown-url.png"
        )!

        XCTAssertEqual(
            loader.records.count,
            recordCountBeforeTeardown
        )

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }
}

#endif

#if os(macOS)

private func makeImage() -> NSImage {
    NSImage(size: NSSize(width: 1, height: 1))
}

@MainActor
final class ImageURLLoaderBindingRoutingTests: XCTestCase {

    func testMacOSImageURLStateInitializerRoutesTokenAndRecordsInitialAndLiveLoads() {
        let initial = URL(
            string: "https://example.invalid/initial.png"
        )!
        let updated = URL(
            string: "https://example.invalid/updated.png"
        )!
        let source = State<URL>(wrappedValue: initial)
        let loader = RecordingImageLoader()
        let defaultImage = makeImage()
        let owner = UImage(
            source,
            defaultImage: defaultImage,
            loader: loader
        )
        let ownerID = ObjectIdentifier(owner)
        let defaultImageID = ObjectIdentifier(defaultImage)

        XCTAssertEqual(heldListenerCount(of: owner), 1)
        XCTAssertEqual(heldListeners(of: owner).count, 1)
        XCTAssertTrue(owner.image === defaultImage)
        XCTAssertEqual(
            loader.records,
            [
                .init(
                    input: .url(initial),
                    imageViewID: ownerID,
                    defaultImageID: defaultImageID
                ),
            ]
        )
        XCTAssertEqual(loader.cancelCallCount, 0)

        source.wrappedValue = updated

        XCTAssertEqual(
            loader.records,
            [
                .init(
                    input: .url(initial),
                    imageViewID: ownerID,
                    defaultImageID: defaultImageID
                ),
                .init(
                    input: .url(updated),
                    imageViewID: ownerID,
                    defaultImageID: defaultImageID
                ),
            ]
        )
        XCTAssertEqual(loader.cancelCallCount, 0)
    }

    func testMacOSImageStringURLStateInitializerRoutesTokenAndRecordsInitialAndLiveLoads() {
        let initial = "https://example.invalid/initial.png"
        let updated = "https://example.invalid/updated.png"
        let source = State<String>(wrappedValue: initial)
        let loader = RecordingImageLoader()
        let defaultImage = makeImage()
        let owner = UImage(
            source,
            defaultImage: defaultImage,
            loader: loader
        )
        let ownerID = ObjectIdentifier(owner)
        let defaultImageID = ObjectIdentifier(defaultImage)

        XCTAssertEqual(heldListenerCount(of: owner), 1)
        XCTAssertEqual(heldListeners(of: owner).count, 1)
        XCTAssertTrue(owner.image === defaultImage)
        XCTAssertEqual(
            loader.records,
            [
                .init(
                    input: .string(initial),
                    imageViewID: ownerID,
                    defaultImageID: defaultImageID
                ),
            ]
        )
        XCTAssertEqual(loader.cancelCallCount, 0)

        source.wrappedValue = updated

        XCTAssertEqual(
            loader.records,
            [
                .init(
                    input: .string(initial),
                    imageViewID: ownerID,
                    defaultImageID: defaultImageID
                ),
                .init(
                    input: .string(updated),
                    imageViewID: ownerID,
                    defaultImageID: defaultImageID
                ),
            ]
        )
        XCTAssertEqual(loader.cancelCallCount, 0)
    }

    func testMacOSURLStateInitializersTeardownCancelOwnedTokensAndPreserveUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let urlSource = State<URL>(
            wrappedValue: URL(
                string: "https://example.invalid/initial-url.png"
            )!
        )
        let stringSource = State<String>(
            wrappedValue: "https://example.invalid/initial-string.png"
        )
        let urlLoader = RecordingImageLoader()
        let stringLoader = RecordingImageLoader()

        weak var weakURLOwner: UImage?
        weak var weakStringOwner: UImage?
        var weakBoxes: [WeakStateListenerBox] = []
        var urlRecordCountBeforeTeardown = 0
        var stringRecordCountBeforeTeardown = 0

        autoreleasepool {
            var urlOwner: UImage? = UImage(
                urlSource,
                defaultImage: makeImage(),
                loader: urlLoader
            )
            var stringOwner: UImage? = UImage(
                stringSource,
                defaultImage: makeImage(),
                loader: stringLoader
            )

            weakURLOwner = urlOwner
            weakStringOwner = stringOwner

            guard
                let liveURLOwner = urlOwner,
                let liveStringOwner = stringOwner
            else {
                XCTFail("Expected live owners")
                return
            }

            let urlListeners = heldListeners(of: liveURLOwner)
            let stringListeners = heldListeners(of: liveStringOwner)

            XCTAssertEqual(
                heldListenerCount(of: liveURLOwner),
                1
            )
            XCTAssertEqual(
                heldListenerCount(of: liveStringOwner),
                1
            )
            XCTAssertEqual(urlListeners.count, 1)
            XCTAssertEqual(stringListeners.count, 1)

            weakBoxes = [
                WeakStateListenerBox(urlListeners[0]),
                WeakStateListenerBox(stringListeners[0]),
            ]

            urlRecordCountBeforeTeardown = urlLoader.records.count
            stringRecordCountBeforeTeardown =
                stringLoader.records.count

            XCTAssertEqual(urlRecordCountBeforeTeardown, 1)
            XCTAssertEqual(stringRecordCountBeforeTeardown, 1)
            XCTAssertEqual(urlLoader.cancelCallCount, 0)
            XCTAssertEqual(stringLoader.cancelCallCount, 0)

            urlOwner = nil
            stringOwner = nil
        }

        XCTAssertNil(weakURLOwner)
        XCTAssertNil(weakStringOwner)

        for (index, box) in weakBoxes.enumerated() {
            XCTAssertNil(
                box.value,
                "Token \(index) should have been deallocated"
            )
        }

        XCTAssertEqual(urlLoader.cancelCallCount, 1)
        XCTAssertEqual(stringLoader.cancelCallCount, 1)

        urlSource.wrappedValue = URL(
            string: "https://example.invalid/after-teardown-url.png"
        )!
        stringSource.wrappedValue =
            "https://example.invalid/after-teardown-string.png"

        XCTAssertEqual(
            urlLoader.records.count,
            urlRecordCountBeforeTeardown
        )
        XCTAssertEqual(
            stringLoader.records.count,
            stringRecordCountBeforeTeardown
        )

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }
}

#endif
