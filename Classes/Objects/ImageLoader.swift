import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

fileprivate let loaderQueue = DispatchQueue(label: "com.uikitplus.imageloader")

fileprivate let cache = ImagesCache()

open class ImagesCache {
    var cache = NSCache<NSString, NSData>()
    
    func save(_ key: String, _ image: Data) {
        cache.setObject(NSData(data: image), forKey: NSString(string: key))
    }
    
    func get(_ key: String) -> Data? {
        cache.object(forKey: NSString(string: key)) as Data?
    }
}

open class ImageLoader {
    lazy var fm = FileManager()
    
    public var reloadingStyle: ImageReloadingStyle
    
    public init (_ reloadingStyle: ImageReloadingStyle = .release) {
        self.reloadingStyle = reloadingStyle
    }
    
    open func load(_ url: String?, imageView: _UImageView, defaultImage: _UImage? = nil) {
        load(URL(string: url ?? ""), imageView: imageView, defaultImage: defaultImage)
    }
    
    open func load(_ url: URL?, imageView: _UImageView, defaultImage: _UImage? = nil) {
        DispatchQueue.main.async { [weak self] in
            loaderQueue.async { [weak self] in
                /// Checks if URL is valid, otherwise trying to set default image
                guard let url = url, url.absoluteString.count > 0 else {
                    if let defaultImage = defaultImage {
                        DispatchQueue.main.async {
                            imageView.image = defaultImage
                        }
                    }
                    return
                }
                /// Builds path to image in cache
                guard let localImagePath = self?.localImagePath(url).path else { return }
                
                /// Tries to get image data from cache
                let cachedImageData = cache.get(url.absoluteString)
                var localImageData: Data?
                if cachedImageData == nil {
                    localImageData = self?.fm.contents(atPath: localImagePath)
                }
                
                /// Release `imageView.image` before downloading the new one
                DispatchQueue.main.async { [weak self] in
                    self?.releaseBeforeDownloading(imageView, defaultImage)
                }

                /// Checking if image exists in cache
                if let cachedImageData = cachedImageData, let image = _UImage(data: cachedImageData)?.forceLoad() {
                    /// Apply chached image to `imageView.image`
                    DispatchQueue.main.async { [weak self] in
                        self?.applyLocalImage(imageView, image)
                    }
                } else if let localImageData = localImageData, let image = _UImage(data: localImageData)?.forceLoad() {
                    cache.save(url.absoluteString, localImageData)
                    /// Apply chached image to `imageView.image`
                    DispatchQueue.main.async { [weak self] in
                        self?.applyLocalImage(imageView, image)
                    }
                }

                /// Downloads image data from URL
                self?.downloadImage(url) { [weak self] imageData in
                    if let cachedImageData = cachedImageData {
                        if imageData.hashValue != cachedImageData.hashValue {
                            if let image = _UImage(data: imageData)?.forceLoad() {
                                DispatchQueue.main.async { [weak self] in
                                    self?.setImage(imageView, image)
                                }
                            }
                            cache.save(url.absoluteString, imageData)
                            self?.fm.createFile(atPath: localImagePath, contents: imageData, attributes: nil)
                        } else {
                            if let image = _UImage(data: cachedImageData)?.forceLoad() {
                                DispatchQueue.main.async { [weak self] in
                                    self?.setImage(imageView, image)
                                }
                            }
                        }
                    } else if let localImageData = localImageData {
                        if imageData.hashValue != localImageData.hashValue {
                            if let image = _UImage(data: imageData)?.forceLoad() {
                                DispatchQueue.main.async { [weak self] in
                                    self?.setImage(imageView, image)
                                }
                            }
                            cache.save(url.absoluteString, imageData)
                            self?.fm.createFile(atPath: localImagePath, contents: imageData, attributes: nil)
                        } else {
                            if let image = _UImage(data: localImageData)?.forceLoad() {
                                DispatchQueue.main.async { [weak self] in
                                    self?.setImage(imageView, image)
                                }
                            }
                        }
                    } else if let image = _UImage(data: imageData)?.forceLoad() {
                        DispatchQueue.main.async { [weak self] in
                            self?.setImage(imageView, image)
                        }
                        cache.save(url.absoluteString, imageData)
                        self?.fm.createFile(atPath: localImagePath, contents: imageData, attributes: nil)
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
    @MainActor
    open func releaseBeforeDownloading(_ imageView: _UImageView, _ defaultImage: _UImage? = nil) {
        if reloadingStyle == .release {
            imageView.image = defaultImage
        }
    }
    
    /// Apply chached image to `imageView.image`
    @MainActor
    open func applyLocalImage(_ imageView: _UImageView, _ image: _UImage) {
        setImage(imageView, image)
    }
    
    /// Set image with or without animation
    @MainActor
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
    
    public var downloadTask: URLSessionDataTask?
    
    /// Downloads image data from URL
    /// Calls on background thread
    open func downloadImage(_ url: URL, callback: @escaping (Data) -> Void) {
        downloadTask?.cancel()
        downloadTask = nil
        if url.isFileURL {
            guard let data = try? Data(contentsOf: url) else { return }
            callback(data)
        } else {
            downloadTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else { return }
                callback(data)
            }
            downloadTask?.resume()
        }
    }
    
    /// Cancels download task
    open func cancel() {
        downloadTask?.cancel()
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
