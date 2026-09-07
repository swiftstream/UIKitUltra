#if os(macOS) || os(iOS) || os(tvOS)
#if canImport(SwiftUI) && DEBUG
import SwiftUI

#if os(macOS)
@available(macOS 10.15, *)
public struct LiveView: NSViewRepresentable {
    let view: NSView
    
    public init (_ vc: NSViewController) {
        self.view = vc.view
    }
    
    public init (_ view: NSView) {
        self.view = view
    }
    
    public func makeNSView(context: Context) -> NSView { view }
    
    public func updateNSView(_ view: NSView, context: Context) {}
}
#else
@available(iOS 13.0, *)
public struct LiveView: UIViewRepresentable {
    let view: UIView
    let aaa = SwiftUI.Text("")
    let bbb = SwiftUI.Button("", action: {})
    let ccc = SwiftUI.Rectangle()
    let ddd = SwiftUI.Circle()
    
    public init (_ vc: UIViewController) {
        self.view = vc.view
    }
    
    public init (_ view: UIView) {
        self.view = view
    }
    
    public func makeUIView(context: Context) -> UIView { view }
    
    public func updateUIView(_ view: UIView, context: Context) {}
}
#endif

public enum PreviewColorScheme {
    case light, dark
    @available(iOS 13.0, macOS 10.15, *)
    fileprivate var val: SwiftUI.ColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
}

public struct UIKitPreviewDevice {
    let name: String
    
    public init (_ name: String) {
        self.name = name
    }
    
    ///     "None"
    public static var none: Self { .init("none") }
    ///     "Mac"
    public static var mac: Self { .init("Mac") }
    #if !os(macOS)
    ///     "iPhone 7"
    public static var iPhone7: Self { .init("iPhone 7") }
    ///     "iPhone 7 Plus"
    public static var iPhone7Plus: Self { .init("iPhone 7 Plus") }
    ///     "iPhone 8"
    public static var iPhone8: Self { .init("iPhone 8") }
    ///     "iPhone 8 Plus"
    public static var iPhone8Plus: Self { .init("iPhone 8 Plus") }
    ///     "iPhone SE"
    public static var iPhoneSE: Self { .init("iPhone SE") }
    ///     "iPhone X"
    public static var iPhoneX: Self { .init("iPhone X") }
    ///     "iPhone Xs"
    public static var iPhoneXs: Self { .init("iPhone Xs") }
    ///     "iPhone Xs Max"
    public static var iPhoneXsMax: Self { .init("iPhone Xs Max") }
    ///     "iPhone Xʀ"
    public static var iPhoneXr: Self { .init("iPhone Xʀ") }
    ///     "iPad mini 4"
    public static var iPadMini4: Self { .init("iPad mini 4") }
    ///     "iPad Air 2"
    public static var iPadAir2: Self { .init("iPad Air 2") }
    ///     "iPad Pro (9.7-inch)"
    public static var iPadPro9_7: Self { .init("iPad Pro (9.7-inch)") }
    ///     "iPad Pro (12.9-inch)"
    public static var iPadPro12_9: Self { .init("iPad Pro (12.9-inch)") }
    ///     "iPad (5th generation)"
    public static var iPad_5gen: Self { .init("iPad (5th generation)") }
    ///     "iPad Pro (12.9-inch) (2nd generation)"
    public static var iPadPro12_9_2gen: Self { .init("iPad Pro (12.9-inch) (2nd generation)") }
    ///     "iPad Pro (10.5-inch)"
    public static var iPadPro10_5: Self { .init("iPad Pro (10.5-inch)") }
    ///     "iPad (6th generation)"
    public static var iPad_6gen: Self { .init("iPad (6th generation)") }
    ///     "iPad Pro (11-inch)"
    public static var iPadPro11: Self { .init("iPad Pro (11-inch)") }
    ///     "iPad Pro (12.9-inch) (3rd generation)"
    public static var iPadPro12_9_3gen: Self { .init("iPad Pro (12.9-inch) (3rd generation)") }
    ///     "iPad mini (5th generation)"
    public static var iPadMini_5gen: Self { .init("iPad mini (5th generation)") }
    ///     "iPad Air (3rd generation)"
    public static var iPadAir_3gen: Self { .init("iPad Air (3rd generation)") }
    ///     "Apple TV"
    public static var appleTV: Self { .init("Apple TV") }
    ///     "Apple TV 4K"
    public static var appleTV4K: Self { .init("Apple TV 4K") }
    ///     "Apple TV 4K (at 1080p)"
    public static var appleTV4Kat1080p: Self { .init("Apple TV 4K (at 1080p)") }
    ///     "Apple Watch Series 2 - 38mm"
    public static var AppleWatchSeries2_38mm: Self { .init("Apple Watch Series 2 - 38mm") }
    ///     "Apple Watch Series 2 - 42mm"
    public static var AppleWatchSeries2_42mm: Self { .init("Apple Watch Series 2 - 42mm") }
    ///     "Apple Watch Series 3 - 38mm"
    public static var AppleWatchSeries3_38mm: Self { .init("Apple Watch Series 3 - 38mm") }
    ///     "Apple Watch Series 3 - 42mm"
    public static var AppleWatchSeries3_42mm: Self { .init("Apple Watch Series 3 - 42mm") }
    ///     "Apple Watch Series 4 - 40mm"
    public static var AppleWatchSeries4_40mm: Self { .init("Apple Watch Series 4 - 40mm") }
    ///     "Apple Watch Series 4 - 44mm"
    public static var AppleWatchSeries4_44mm: Self { .init("Apple Watch Series 4 - 44mm") }
    #endif
}

@available(iOS 13.0, macOS 10.15, *)
public class Preview {
    let view: BaseView
    var colorScheme: PreviewColorScheme = .light
    #if os(macOS)
    var device: UIKitPreviewDevice = .mac
    #else
    var device: UIKitPreviewDevice = .iPhoneX
    #endif
    var layout: PreviewLayout = .device
    var title: String = "Preview"
    var language: Language = Localization().detectCurrentLanguage()
    #if !os(macOS)
    var semanticContentAttribute: UISemanticContentAttribute = .unspecified
    #endif
    
    @MainActor
    public init(@BodyBuilder block: BodyBuilder.SingleView) {
        view = UView(block: block).edgesToSuperview()
    }
    
    @discardableResult
    public func colorScheme(_ v: PreviewColorScheme) -> Self {
        colorScheme = v
        return self
    }
    
    @discardableResult
    public func device(_ v: UIKitPreviewDevice) -> Self {
        device = v
        return self
    }
    
    @discardableResult
    public func layout(_ v: PreviewLayout) -> Self {
        layout = v
        return self
    }
    
    @discardableResult
    public func title(_ v: String) -> Self {
        title = v
        return self
    }
    
    @discardableResult
    public func language(_ v: Language) -> Self {
        language = v
        return self
    }
    
    @discardableResult
    public func rtl(_ v: Bool) -> Self {
        #if !os(macOS) // TODO: figure out
        semanticContentAttribute = v ? .forceRightToLeft : .forceLeftToRight
        #endif
        return self
    }
    
    #if os(macOS)
    @MainActor
    fileprivate var liveView: some SwiftUI.View {
        LiveView(view)
            .previewLayout(layout)
            .previewDisplayName(title)
            .edgesIgnoringSafeArea(.all)
            .previewDevice(device.name == "none" ? nil : PreviewDevice(rawValue: device.name))
    }
    
    #else
    @MainActor
    fileprivate var liveView: some SwiftUI.View {
        LiveView(view)
            .preferredColorScheme(colorScheme.val)
            .previewLayout(layout)
            .previewDisplayName(title)
            .edgesIgnoringSafeArea(.all)
            .previewDevice(device.name == "none" ? nil : PreviewDevice(rawValue: device.name))
    }
    #endif
}

@available(iOS 13.0, macOS 10.15, *)
public protocol DeclarativePreview: SwiftUI.PreviewProvider {
    static var preview: Preview { get }
}

@available(iOS 13.0, macOS 10.15, *)
extension DeclarativePreview {
    @MainActor
    public static var previews: some SwiftUI.View {
        Localization.current = preview.language
        #if !os(macOS)
        UIView.appearance().semanticContentAttribute = preview.semanticContentAttribute
        #endif
        return preview.liveView
    }
}

@available(iOS 13.0, macOS 10.15, *)
public protocol DeclarativePreviewGroup: SwiftUI.PreviewProvider {
    static var previewGroup: PreviewGroup { get }
}

@available(iOS 13.0, macOS 10.15, *)
extension DeclarativePreviewGroup {
    @MainActor
    public static var previews: some SwiftUI.View {
        Localization.current = previewGroup.language
        #if !os(macOS)
        UIView.appearance().semanticContentAttribute = previewGroup.semanticContentAttribute
        #endif
        return SwiftUI.Group {
            if previewGroup.previews.count > 0 {
                previewGroup.previews[0].liveView
            }
            if previewGroup.previews.count > 1 {
                previewGroup.previews[1].liveView
            }
            if previewGroup.previews.count > 2 {
                previewGroup.previews[2].liveView
            }
            if previewGroup.previews.count > 3 {
                previewGroup.previews[3].liveView
            }
            if previewGroup.previews.count > 4 {
                previewGroup.previews[4].liveView
            }
            if previewGroup.previews.count > 5 {
                previewGroup.previews[5].liveView
            }
            if previewGroup.previews.count > 6 {
                previewGroup.previews[6].liveView
            }
            if previewGroup.previews.count > 7 {
                previewGroup.previews[7].liveView
            }
            if previewGroup.previews.count > 8 {
                previewGroup.previews[8].liveView
            }
            if previewGroup.previews.count > 9 {
                previewGroup.previews[9].liveView
            }
        }
    }
}
#endif
#endif
