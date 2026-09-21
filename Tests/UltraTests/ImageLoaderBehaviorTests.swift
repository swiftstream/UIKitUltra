#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import XCTest
@testable import Ultra

#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - Tiny PNG Data Helper

private let tinyPNGData = Data(base64Encoded:
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
)!

// MARK: - Test Subclasses

private final class HookedImageLoader: ImageLoader {
    var downloadImageCalled = false
    var downloadImageURL: URL?
    
    override func downloadImage(_ url: URL, callback: @escaping @Sendable (Data) -> Void) {
        downloadImageCalled = true
        downloadImageURL = url
    }
}

private final class HookedImageLoaderWithRelease: ImageLoader {
    var releaseBeforeDownloadingCalled = false
    
    override func releaseBeforeDownloading(_ imageView: _UImageView, _ defaultImage: _UImage? = nil) {
        releaseBeforeDownloadingCalled = true
        super.releaseBeforeDownloading(imageView, defaultImage)
    }
}

private final class HookedImageLoaderWithSetImage: ImageLoader {
    var setImageCallCount = 0
    var onSetImage: (() -> Void)?
    
    override func downloadImage(_ url: URL, callback: @escaping @Sendable (Data) -> Void) {
        callback(tinyPNGData)
    }
    
    @MainActor
    override func setImage(_ imageView: _UImageView, _ image: _UImage) {
        setImageCallCount += 1
        onSetImage?()
        super.setImage(imageView, image)
    }
}

private final class HookedImageLoaderWithApplyLocal: ImageLoader {
    var applyLocalImageCallCount = 0
    var onApplyLocalImage: (() -> Void)?
    
    @MainActor
    override func applyLocalImage(_ imageView: _UImageView, _ image: _UImage) {
        applyLocalImageCallCount += 1
        onApplyLocalImage?()
        super.applyLocalImage(imageView, image)
    }
}

// MARK: - Tests

@MainActor
final class ImageLoaderBehaviorTests: XCTestCase {
    
    private func makeImageView() -> _UImageView {
        #if os(macOS)
        return NSImageView()
        #else
        return UIImageView()
        #endif
    }
    
    // MARK: - Test 1: downloadImage dynamic dispatch
    
    func testLoadUsesDownloadImageDynamicDispatch() {
        let loader = HookedImageLoader()
        let imageView = makeImageView()
        
        let url = URL(fileURLWithPath: "/tmp/test_image.png")
        loader.load(url, imageView: imageView)
        
        let expectation = expectation(description: "downloadImage called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(loader.downloadImageCalled, "load() must call downloadImage() via dynamic dispatch")
        XCTAssertEqual(loader.downloadImageURL, url, "load() must pass the URL to downloadImage()")
    }
    
    // MARK: - Test 2: releaseBeforeDownloading hook
    
    func testLoadUsesReleaseBeforeDownloadingHook() {
        let loader = HookedImageLoaderWithRelease()
        let imageView = makeImageView()
        
        let url = URL(fileURLWithPath: "/tmp/test_image.png")
        loader.load(url, imageView: imageView)
        
        let expectation = expectation(description: "releaseBeforeDownloading called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(loader.releaseBeforeDownloadingCalled, "load() must call releaseBeforeDownloading() via dynamic dispatch")
    }
    
    // MARK: - Test 3: setImage hook
    
    func testLoadUsesSetImageHook() {
        let loader = HookedImageLoaderWithSetImage()
        let imageView = makeImageView()
        
        let expectation = expectation(description: "setImage called")
        loader.onSetImage = { expectation.fulfill() }
        
        let url = URL(string: "https://example.com/test-set-image.png")!
        loader.load(url, imageView: imageView)
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertGreaterThan(loader.setImageCallCount, 0, "load() must call setImage() via dynamic dispatch")
    }
    
    // MARK: - Test 4: applyLocalImage hook
    
    func testLoadUsesApplyLocalImageHook() {
        let loader = HookedImageLoaderWithApplyLocal()
        let imageView = makeImageView()
        
        let url = URL(fileURLWithPath: "/tmp/test_apply_local_\(UUID().uuidString).png")
        let cachePath = loader.localImagePath(url)
        
        try? FileManager.default.createDirectory(
            at: cachePath.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? tinyPNGData.write(to: cachePath)
        defer { try? FileManager.default.removeItem(at: cachePath) }
        
        let expectation = expectation(description: "applyLocalImage called")
        loader.onApplyLocalImage = { expectation.fulfill() }
        
        loader.load(url, imageView: imageView)
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertGreaterThan(loader.applyLocalImageCallCount, 0, "load() must call applyLocalImage() via dynamic dispatch")
    }
    
    // MARK: - Test 5: cancel smoke test
    
    func testCancelDoesNotCrash() {
        let loader = ImageLoader()
        let imageView = makeImageView()
        
        loader.cancel()
        
        let url = URL(fileURLWithPath: "/tmp/test_image.png")
        loader.load(url, imageView: imageView)
        
        let expectation = expectation(description: "load completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        loader.cancel()
    }
    
    // MARK: - Test 6: load with nil URL
    
    func testLoadWithNilURLDoesNotCallDownloadImage() {
        let loader = HookedImageLoader()
        let imageView = makeImageView()
        
        loader.load(nil as URL?, imageView: imageView)
        
        let expectation = expectation(description: "load completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(loader.downloadImageCalled, "load(nil) should not call downloadImage()")
    }
    
    // MARK: - Test 7: load with empty string URL
    
    func testLoadWithEmptyStringURLDoesNotCallDownloadImage() {
        let loader = HookedImageLoader()
        let imageView = makeImageView()
        
        loader.load("", imageView: imageView)
        
        let expectation = expectation(description: "load completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(loader.downloadImageCalled, "load(\"\") should not call downloadImage()")
    }
    
    // MARK: - Test 8: valid URL triggers downloadImage
    
    func testLoadWithValidURLCallsDownloadImage() {
        let loader = HookedImageLoader()
        let imageView = makeImageView()
        
        let url = URL(string: "https://example.com/image.png")!
        loader.load(url, imageView: imageView)
        
        let expectation = expectation(description: "downloadImage called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(loader.downloadImageCalled, "load(validURL) must call downloadImage()")
    }
}
#endif
