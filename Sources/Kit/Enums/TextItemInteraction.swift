#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

public enum TextItemInteraction : Int {
    case invokeDefaultAction, presentActions, preview
    
    @available(iOS 10.0, *)
    static func from(_ item: UITextItemInteraction) -> TextItemInteraction {
        switch item {
        case .invokeDefaultAction: return .invokeDefaultAction
        case .presentActions: return .presentActions
        case .preview: return .preview
        @unknown default:
            assertionFailure("TextItemInteraction case not supported")
            return .invokeDefaultAction
        }
    }
}
#endif
#endif
