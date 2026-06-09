#if os(macOS)
import AppKit

public class Color {
    let light, dark: NSColor

    private let _themeBindingHolder = TempStatesHolder()

    var themeBindingHolder: TempStatesHolder {
        _themeBindingHolder
    }
    
    typealias ChangeHandler = (NSColor) -> Void
    var changeHandler: ChangeHandler?
    
    public func onChange(_ handler: @escaping (NSColor) -> Void) {
        changeHandler = handler
    }
    
    public init (_ color: NSColor) {
        light = color
        dark = light
        _setup()
    }
    
    public init (_ color: Color) {
        light = color.light
        dark = light
        _setup()
    }
    
    public init (light: NSColor, dark: NSColor) {
        self.light = light
        self.dark = dark
        _setup()
    }
    
    public static func white(_ white: CGFloat = 1, alpha: CGFloat = 1) -> Color {
        .init(NSColor(white: white, alpha: alpha))
    }
    
    public static func black(_ black: CGFloat = 1, alpha: CGFloat = 1) -> Color {
        .init(NSColor(white: 1 - black, alpha: alpha))
    }
    
    public init (light: Color, dark: Color) {
        self.light = light.light
        self.dark = dark.light
        _setup()
    }
    
    private func _setup() {
        guard !Bundle.main.bundlePath.hasSuffix(".appex") else { return }
        App.shared.$theme.listen { [weak self] old, new in
            guard old != new else { return }
            guard let self = self else { return }
            switch new {
            case .dark:
                self.changeHandler?(self.dark)
            case .light:
                self.changeHandler?(self.light)
            }
        }
        .hold(in: themeBindingHolder)
    }
    
    public var current: NSColor {
        guard !Bundle.main.bundlePath.hasSuffix(".appex") else { return light }
        switch App.shared.theme {
        case .dark:
            return dark
        case .light:
            return light
        }
    }
    
    public class var black: Color {
        .init(NSColor.black)
    }

    public class var darkGray: Color {
        .init(NSColor.darkGray)
    }

    public class var lightGray: Color {
        .init(NSColor.lightGray)
    }

    public class var white: Color {
        .init(NSColor.white)
    }

    public class var gray: Color {
        .init(NSColor.gray)
    }

    public class var red: Color {
        .init(NSColor.red)
    }

    public class var green: Color {
        .init(NSColor.green)
    }

    public class var blue: Color {
        .init(NSColor.blue)
    }

    public class var cyan: Color {
        .init(NSColor.cyan)
    }

    public class var yellow: Color {
        .init(NSColor.yellow)
    }

    public class var magenta: Color {
        .init(NSColor.magenta)
    }

    public class var orange: Color {
        .init(NSColor.orange)
    }

    public class var purple: Color {
        .init(NSColor.purple)
    }

    public class var brown: Color {
        .init(NSColor.brown)
    }

    public class var clear: Color {
        .init(NSColor.clear)
    }

    @available(OSX 10.10, *)
    public class var labelColor: Color {
        .init(NSColor.labelColor)
    }

    @available(OSX 10.10, *)
    public class var secondaryLabelColor: Color {
        .init(NSColor.secondaryLabelColor)
    }

    @available(OSX 10.10, *)
    public class var tertiaryLabelColor: Color {
        .init(NSColor.tertiaryLabelColor)
    }

    @available(OSX 10.10, *)
    public class var quaternaryLabelColor: Color {
        .init(NSColor.quaternaryLabelColor)
    }

    @available(OSX 10.10, *)
    public class var linkColor: Color {
        .init(NSColor.linkColor)
    }

    @available(OSX 10.10, *)
    public class var placeholderTextColor: Color {
        .init(NSColor.placeholderTextColor)
    }

    public class var windowFrameTextColor: Color {
        .init(NSColor.windowFrameTextColor)
    }

    public class var selectedMenuItemTextColor: Color {
        .init(NSColor.selectedMenuItemTextColor)
    }

    public class var alternateSelectedControlTextColor: Color {
        .init(NSColor.alternateSelectedControlTextColor)
    }

    public class var headerTextColor: Color {
        .init(NSColor.headerTextColor)
    }

    @available(OSX 10.14, *)
    public class var separatorColor: Color {
        .init(NSColor.separatorColor)
    }

    public class var gridColor: Color {
        .init(NSColor.gridColor)
    }

    public class var windowBackgroundColor: Color {
        .init(NSColor.windowBackgroundColor)
    }

    @available(OSX 10.8, *)
    public class var underPageBackgroundColor: Color {
        .init(NSColor.underPageBackgroundColor)
    }

    public class var controlBackgroundColor: Color {
        .init(NSColor.controlBackgroundColor)
    }

    @available(OSX 10.14, *)
    public class var selectedContentBackgroundColor: Color {
        .init(NSColor.selectedContentBackgroundColor)
    }

    @available(OSX 10.14, *)
    public class var unemphasizedSelectedContentBackgroundColor: Color {
        .init(NSColor.unemphasizedSelectedContentBackgroundColor)
    }

    @available(OSX 10.13, *)
    public class var findHighlightColor: Color {
        .init(NSColor.findHighlightColor)
    }

    public class var textColor: Color {
        .init(NSColor.textColor)
    }

    public class var textBackgroundColor: Color {
        .init(NSColor.textBackgroundColor)
    }

    public class var selectedTextColor: Color {
        .init(NSColor.selectedTextColor)
    }

    public class var selectedTextBackgroundColor: Color {
        .init(NSColor.selectedTextBackgroundColor)
    }

    @available(OSX 10.14, *)
    public class var unemphasizedSelectedTextBackgroundColor: Color {
        .init(NSColor.unemphasizedSelectedTextBackgroundColor)
    }

    @available(OSX 10.14, *)
    public class var unemphasizedSelectedTextColor: Color {
        .init(NSColor.unemphasizedSelectedTextColor)
    }

    public class var controlColor: Color {
        .init(NSColor.controlColor)
    }

    public class var controlTextColor: Color {
        .init(NSColor.controlTextColor)
    }

    public class var selectedControlColor: Color {
        .init(NSColor.selectedControlColor)
    }

    public class var selectedControlTextColor: Color {
        .init(NSColor.selectedControlTextColor)
    }

    public class var disabledControlTextColor: Color {
        .init(NSColor.disabledControlTextColor)
    }

    public class var keyboardFocusIndicatorColor: Color {
        .init(NSColor.keyboardFocusIndicatorColor)
    }

    @available(OSX 10.12.2, *)
    public class var scrubberTexturedBackground: Color {
        .init(NSColor.scrubberTexturedBackground)
    }

    @available(OSX 10.10, *)
    public class var systemRed: Color {
        .init(NSColor.systemRed)
    }

    @available(OSX 10.10, *)
    public class var systemGreen: Color {
        .init(NSColor.systemGreen)
    }

    @available(OSX 10.10, *)
    public class var systemBlue: Color {
        .init(NSColor.systemBlue)
    }

    @available(OSX 10.10, *)
    public class var systemOrange: Color {
        .init(NSColor.systemOrange)
    }

    @available(OSX 10.10, *)
    public class var systemYellow: Color {
        .init(NSColor.systemYellow)
    }

    @available(OSX 10.10, *)
    public class var systemBrown: Color {
        .init(NSColor.systemBrown)
    }

    @available(OSX 10.10, *)
    public class var systemPink: Color {
        .init(NSColor.systemPink)
    }

    @available(OSX 10.10, *)
    public class var systemPurple: Color {
        .init(NSColor.systemPurple)
    }

    @available(OSX 10.10, *)
    public class var systemGray: Color {
        .init(NSColor.systemGray)
    }

    @available(OSX 10.12, *)
    public class var systemTeal: Color {
        .init(NSColor.systemTeal)
    }

    @available(OSX 10.15, *)
    public class var systemIndigo: Color {
        .init(NSColor.systemIndigo)
    }

    @available(OSX 10.14, *)
    public class var controlAccentColor: Color {
        .init(NSColor.controlAccentColor)
    }

    public class var highlightColor: Color {
        .init(NSColor.highlightColor)
    }

    public class var shadowColor: Color {
        .init(NSColor.shadowColor)
    }
}

public func /(lhs: Int, rhs: Int) -> Color {
    Color(light: lhs.color, dark: rhs.color)
}

public func /(lhs: Int, rhs: Color) -> Color {
    Color(light: lhs.color, dark: rhs)
}

public func /(lhs: Color, rhs: Int) -> Color {
    Color(light: lhs, dark: rhs.color)
}

public func /(lhs: Color, rhs: Color) -> Color {
    Color(light: lhs, dark: rhs)
}
//public func /(lhs: NSColor, rhs: NSColor) -> NSColor {
//    // TODO: implement dynamic color
//    NSColor(name: "") { appearance in
//        print("NSColor appearance")
//       switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
//       case NSAppearance.Name.darkAqua:
//           return rhs
//       case NSAppearance.Name.aqua:
//           return lhs
//       default:
//            return lhs
//       }
//    }
//
//    var dynamicColor = NSAppearance.current.name == NSAppearance.Name.darkAqua ? rhs : lhs
//    (App.shared as! App).onChange { theme in
//        switch theme {
//        case .light:
//            dynamicColor = lhs
//            print("switched to light")
//        case .dark:
//            dynamicColor = rhs
//            print("switched to dark")
//        }
//    }
//    return dynamicColor
    
//        NSColor(name: NSColor.Name.init("red")) { appearance -> NSColor in
//        print("appearance.name.rawValue: \(appearance.name.rawValue)")
//        return appearance.name.rawValue == "NSAppearanceNameDarkAqua"/*NSAppearance.Name.darkAqua.rawValue*/ ? rhs : lhs
//    }
//    if #available(macOS 10.15, *) {
//        return NSColor { $0.userInterfaceStyle == .dark ? rhs : lhs }
//    } else {
//        return lhs
//    }
//}
//class DynamicColor: NSColor {
//    let light, dark: NSColor
//
//    init (light: NSColor, dark: NSColor) {
//        self.light = light
//        self.dark = dark
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    required init(red: Float, green: Float, blue: Float, alpha: Float) {
//        fatalError("init(_colorLiteralRed:green:blue:alpha:) has not been implemented")
//    }
//
//    required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
//        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
//    }
//}
#else
import UIKit

public func /(lhs: UIColor, rhs: UIColor) -> UIColor {
    if #available(iOS 13.0, *) {
        return UIColor { $0.userInterfaceStyle == .dark ? rhs : lhs }
    } else {
        return lhs
    }
}
#endif
