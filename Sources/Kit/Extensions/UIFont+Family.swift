#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
public typealias UFont = NSFont
#else
public typealias UFont = UIFont
#endif

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension UFont {
    public convenience init? (_ identifier: FontIdentifier, size: CGFloat) {
        self.init(name: identifier.fontName, size: size)
    }
}

public protocol FontIdentifierable {
    var fontName: String { get }
}

public struct FontIdentifier: FontIdentifierable {
    public let fontName: String
    
    public init (_ fontName: String) {
        self.fontName = fontName
    }
}

/** Usage example
 extension FontIdentifier {
 public static var sfProBold = FontIdentifier("SFProDisplay-Bold")
 public static var sfProRegular = FontIdentifier("SFProDisplay-Regular")
 public static var sfProMedium = FontIdentifier("SFProDisplay-Medium")
 }
 
 And then somewhere
 
 Label("hello world").font(.sfProRegular, 16)
 TextField().font(.sfProRegular, 16)
 */
#endif
