#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

fileprivate let loaderQueue = DispatchQueue(label: "com.uikitultra.imageloader")

private let cache = ImagesCache()

/// `NSCache` is documented as thread-safe. This private final wrapper exposes
/// no mutable state beyond synchronized `NSCache` operations.
private final class ImagesCache: @unchecked Sendable {
    private let cache = NSCache<NSString, NSData>()
    
    func save(_ key: String, _ image: Data) {
        cache.setObject(NSData(data: image), forKey: NSString(string: key))
    }
    
    func get(_ key: String) -> Data? {
        cache.object(forKey: NSString(string: key)) as Data?
    }
}

@MainActor
open class ImageLoader {
    /// Cancellation may originate from a nonisolated image-view deinitializer;
    /// the storage serializes every task read, replacement, and cancellation.
    private nonisolated let taskStorage = ImageLoaderTaskStorage()

    public var reloadingStyle: ImageReloadingStyle
    
    public init (_ reloadingStyle: ImageReloadingStyle = .release) {
        self.reloadingStyle = reloadingStyle
    }
    
    open func load(_ url: String?, imageView: _UImageView, defaultImage: _UImage? = nil) {
        load(URL(string: url ?? ""), imageView: imageView, defaultImage: defaultImage)
    }
    
    open func load(_ url: URL?, imageView: _UImageView, defaultImage: _UImage? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            /// Checks if URL is valid, otherwise trying to set default image
            guard let url, !url.absoluteString.isEmpty else {
                imageView.image = defaultImage
                return
            }

            /// Builds path to image in cache
            let localImagePath = self.localImagePath(url).path

            loaderQueue.async { [weak self] in
                /// Tries to get image data from memory and disk caches
                let cachedImageData = cache.get(url.absoluteString)
                let localImageData = cachedImageData == nil
                    ? FileManager.default.contents(atPath: localImagePath)
                    : nil

                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }

                    /// Release `imageView.image` before downloading the new one
                    self.releaseBeforeDownloading(imageView, defaultImage)

                    /// Apply a cached image before checking the remote source
                    if let cachedImageData,
                       let image = _UImage(data: cachedImageData)?.forceLoad() {
                        self.applyLocalImage(imageView, image)
                    } else if let localImageData,
                              let image = _UImage(data: localImageData)?.forceLoad() {
                        cache.save(url.absoluteString, localImageData)
                        self.applyLocalImage(imageView, image)
                    }

                    /// Downloads image data from URL
                    self.downloadImage(url) { [weak self] imageData in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }

                            let previousImageData = cachedImageData ?? localImageData
                            let imageDataToDisplay = previousImageData?.hashValue == imageData.hashValue
                                ? previousImageData
                                : imageData

                            if let imageDataToDisplay,
                               let image = _UImage(data: imageDataToDisplay)?.forceLoad() {
                                self.setImage(imageView, image)
                            }

                            guard previousImageData?.hashValue != imageData.hashValue else {
                                return
                            }
                            loaderQueue.async {
                                cache.save(url.absoluteString, imageData)
                                FileManager.default.createFile(
                                    atPath: localImagePath,
                                    contents: imageData,
                                    attributes: nil
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Builds path to image in cache
    open func localImagePath(_ imageURL: URL) -> URL {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as NSString
        return URL(fileURLWithPath: documentDirectoryPath.appendingPathComponent("\(imageURL.lastPathComponent)"))
    }
    
    /// Release `imageView.image` before downloading the new one
    open func releaseBeforeDownloading(_ imageView: _UImageView, _ defaultImage: _UImage? = nil) {
        if reloadingStyle == .release {
            imageView.image = defaultImage
        }
    }
    
    /// Apply chached image to `imageView.image`
    open func applyLocalImage(_ imageView: _UImageView, _ image: _UImage) {
        setImage(imageView, image)
    }
    
    /// Set image with or without animation
    open func setImage(_ imageView: _UImageView, _ image: _UImage) {
        if self.reloadingStyle == .fade {
            #if os(macOS)
            imageView.image = image // TODO: implement fade image setting
            #else
            UIView.transition(with: imageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                imageView.image = image
            }, completion: nil)
            #endif
        } else {
            imageView.image = image
        }
    }
    
    public var downloadTask: URLSessionDataTask? {
        get { taskStorage.get() }
        set { taskStorage.set(newValue) }
    }
    
    /// Downloads image data from URL
    /// Calls on background thread
    open func downloadImage(_ url: URL, callback: @escaping @Sendable (Data) -> Void) {
        downloadTask?.cancel()
        downloadTask = nil
        if url.isFileURL {
            loaderQueue.async {
                guard let data = try? Data(contentsOf: url) else { return }
                callback(data)
            }
        } else {
            downloadTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else { return }
                callback(data)
            }
            downloadTask?.resume()
        }
    }
    
    /// Cancels download task
    nonisolated open func cancel() {
        taskStorage.cancel()
    }
}

/// The URL session task may be cancelled by an image view deinitializer, which
/// is not actor-isolated. All access is serialized by `lock`.
private final class ImageLoaderTaskStorage: @unchecked Sendable {
    private let lock = NSLock()
    private var task: URLSessionDataTask?

    func get() -> URLSessionDataTask? {
        lock.withLock { task }
    }

    func set(_ newValue: URLSessionDataTask?) {
        lock.withLock {
            task = newValue
        }
    }

    func cancel() {
        let currentTask: URLSessionDataTask? = lock.withLock { self.task }
        currentTask?.cancel()
    }
}

extension ImageLoader {
    public static var defaultRelease: ImageLoader { .init(.release) }
    public static var defaultImmediate: ImageLoader { .init(.immediate) }
    public static var defaultFade: ImageLoader { .init(.fade) }
}

extension _UImage {
    /// A trick to force draw image on background thread
    func forceLoad() -> _UImage {
        #if os(macOS)
        return self // TODO: figure out
        #else
        guard let imageRef = self.cgImage else {
            return self //failed
        }
        let width = imageRef.width
        let height = imageRef.height
        let colourSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        guard let imageContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colourSpace, bitmapInfo: bitmapInfo) else {
            return self //failed
        }
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        imageContext.draw(imageRef, in: rect)
        if let outputImage = imageContext.makeImage() {
            let cachedImage = _UImage(cgImage: outputImage, scale: scale, orientation: imageOrientation)
            return cachedImage
        }
        return self //failed
        #endif
    }
}
#endif
