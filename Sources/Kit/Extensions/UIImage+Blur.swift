#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit

public typealias _UImageView = NSImageView
public typealias _UImage = NSImage
#else
import UIKit

public typealias _UImageView = UIImageView
public typealias _UImage = UIImage
#endif

#if !os(macOS)
extension _UImage {
    public func blurred(_ radius: CGFloat = 10) -> _UImage? {
        let inputImage = CIImage(cgImage: (cgImage)!)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: "inputImage")
        filter?.setValue(radius, forKey: "inputRadius")
        let blurred = filter?.outputImage
        
        var newImageSize: CGRect = (blurred?.extent)!
        newImageSize.origin.x += (newImageSize.size.width - size.width) / 2
        newImageSize.origin.y += (newImageSize.size.height - size.height) / 2
        newImageSize.size = size
        
        let resultImage = filter?.value(forKey: "outputImage") as! CIImage
        let context = CIContext(options: nil)
        let cgimg = context.createCGImage(resultImage, from: newImageSize)!
        let blurredImage = _UImage(cgImage: cgimg)
        return blurredImage
    }
}
#endif
#endif
