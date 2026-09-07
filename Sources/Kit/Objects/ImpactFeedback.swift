#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

public class ImpactFeedback {
    public enum FeedbackStyle: Int {
        case light, medium, heavy
    }
    #if !os(tvOS)
    public static func bzz(_ style: FeedbackStyle = .light) {
        if #available(iOS 10.0, *) {
            guard let style = UIImpactFeedbackGenerator.FeedbackStyle(rawValue: style.rawValue) else { return }
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }
    
    public static func selected() {
        if #available(iOS 10.0, *) {
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    public static func success() {
        if #available(iOS 10.0, *) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    public static func warning() {
        if #available(iOS 10.0, *) {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }
    
    public static func error() {
        if #available(iOS 10.0, *) {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    #endif
}
#endif
#endif
