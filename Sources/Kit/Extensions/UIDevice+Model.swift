#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)

#else
import UIKit

extension UIDevice {
    public enum ScreenNativeHeight: Float {
        case iPhone4 = 960
        case iPhone5 = 1136
        case iPhone6 = 1334
        case iPhone6PlusReal = 1920
        case iPhone6PlusVirtual = 2208
        case iPhoneX = 2436
        case iPhonePro = 2532
        case iPhoneXr = 1792
        case iPhoneXMax = 2688
        case iPad1stGen = 768
        case iPad6thGen = 1536
        case iPad10 = 1668
        case iPad12 = 2048
        
        public var name: String {
            switch self {
            case .iPhone4: return "iPhone4"
            case .iPhone5: return "iPhone5"
            case .iPhone6: return "iPhone6"
            case .iPhone6PlusReal: return "iPhone6PlusReal"
            case .iPhone6PlusVirtual: return "iPhone6PlusVirtual"
            case .iPhoneX: return "iPhoneX"
            case .iPhonePro: return "iPhonePro"
            case .iPhoneXr: return "iPhoneXr"
            case .iPhoneXMax: return "iPhoneXMax"
            case .iPad1stGen: return "iPad1stGen"
            case .iPad6thGen: return "iPad6thGen"
            case .iPad10: return "iPad10"
            case .iPad12: return "iPad12"
            }
        }
    }
    
    public enum DeviceType: String {
        case iPhone
        case iPhone4
        case iPhone5
        case iPhone6
        case iPhone6Plus
        case iPhoneXr
        case iPhoneX
        case iPhonePro
        case iPhoneXMax
        case iPhoneUnknown
        case iPad
        case iPad10
        case iPad12
        case iPadUnknown
        case unknown
        
        static func byScreenNativeHeight(_ screenNativeHeight: ScreenNativeHeight) -> DeviceType {
            switch screenNativeHeight {
            case .iPhone4: return .iPhone4
            case .iPhone5: return .iPhone5
            case .iPhone6: return .iPhone6
            case .iPhone6PlusVirtual, .iPhone6PlusReal: return .iPhone6Plus
            case .iPhoneXr: return .iPhoneXr
            case .iPhoneX: return .iPhoneX
            case .iPhonePro: return .iPhonePro
            case .iPhoneXMax: return .iPhoneXMax
            case .iPad1stGen, .iPad6thGen: return .iPad
            case .iPad10: return .iPad10
            case .iPad12: return .iPad12
            }
        }
    }
    
    class var minHeight: Float {
        let w = Float(UIScreen.main.nativeBounds.width)
        let h = Float(UIScreen.main.nativeBounds.height)
        return fmin(w, h)
    }
    
    class var maxHeight: Float {
        let w = Float(UIScreen.main.nativeBounds.width)
        let h = Float(UIScreen.main.nativeBounds.height)
        return fmax(w, h)
    }
    
    public class var isPhoneIdiom: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    public class var isPadIdiom: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    public class var isPhone4: Bool {
        isPhoneIdiom && maxHeight == ScreenNativeHeight.iPhone4.rawValue
    }
    
    public class var isPhone5: Bool {
        isPhoneIdiom && maxHeight == ScreenNativeHeight.iPhone5.rawValue
    }
    
    public class var isPhone6: Bool {
        isPhoneIdiom && maxHeight == ScreenNativeHeight.iPhone6.rawValue
    }
    
    public class var isPhone6Plus: Bool {
        isPhoneIdiom && [ScreenNativeHeight.iPhone6PlusReal.rawValue, ScreenNativeHeight.iPhone6PlusVirtual.rawValue].contains(maxHeight)
    }
    
    public class var isPhoneX: Bool {
        isPhoneIdiom && maxHeight == ScreenNativeHeight.iPhoneX.rawValue
    }
    
    public class var isPhonePro: Bool {
        isPhoneIdiom && maxHeight == ScreenNativeHeight.iPhonePro.rawValue
    }
    
    public class var isPhoneXr: Bool {
        isPhoneIdiom && maxHeight == ScreenNativeHeight.iPhoneXr.rawValue
    }
    
    public class var isPhoneXMax: Bool {
        isPhoneIdiom && [ScreenNativeHeight.iPhoneXr.rawValue, ScreenNativeHeight.iPhoneXMax.rawValue].contains(maxHeight)
    }
    
    public class var isPad: Bool {
        isPadIdiom && [ScreenNativeHeight.iPad1stGen.rawValue, ScreenNativeHeight.iPad6thGen.rawValue].contains(minHeight)
    }
    
    public class var isPad10: Bool {
        isPadIdiom && minHeight == ScreenNativeHeight.iPad10.rawValue
    }
    
    public class var isPad12: Bool {
        isPadIdiom && minHeight == ScreenNativeHeight.iPad12.rawValue
    }
}
#endif
#endif
