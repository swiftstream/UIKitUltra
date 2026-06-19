#if os(macOS)
import AppKit
#else
import UIKit
#endif

public class PropertiesInternal {
    let stateBindingHolder = TempStatesHolder()

    var circleCorners: Bool = false
    #if !os(macOS)
    var customCorners: CustomCorners?
    #endif
    lazy var borders = Borders()
    
    /// See `Textable`
    
    #if !os(macOS)
    var textChangeTransition: UIView.AnimationOptions?
    #endif
    var statedText: AnyStringBuilder.Handler?
    var textChangeListeners: [(NSAttributedString) -> Void] = []
    
    /// See `Placeholderable`
    
    #if !os(macOS)
    var placeholderChangeTransition: UIView.AnimationOptions?
    #endif
    var statedPlaceholder: AnyStringBuilder.Handler?
    var placeholderBinding: State<AnyString>?
    @State var placeholderAttrText: NSAttributedString?
    
    /// See `Typeable`
    
    @State var isTyping = false
    var isTypingState: State<Bool> { _isTyping }
    
    var typingInterval: TimeInterval = 0.5
    var typingTimer: Timer?
    
    // MARK: - Rendered ForEach Bindings

    var renderedForEachBindings: [RenderedForEachBinding] = []

    // MARK: - Internal Constraints
    
    var notAppliedPreConstraintsSuper: [PreConstraint] = []
    var appliedPreConstraintsSuper: [PreConstraint] = []
    
    var notAppliedPreConstraintsSolo: [PreConstraint] = []
    var appliedPreConstraintsSolo: [PreConstraint] = []
    
    var notAppliedPreConstraintsRelative: [PreConstraint] = []
    var appliedPreConstraintsRelative: [PreConstraint] = []
    
    @MainActor
    func moveAppliedToNotApplied() {
        appliedPreConstraintsSuper.forEach {
            $0.value.removeListeners()
            notAppliedPreConstraintsSuper.append($0)
        }
        appliedPreConstraintsSuper.removeAll()
    }
}
