#if os(macOS)
import AppKit
#else
import UIKit
#endif

public class Properties<V> {
    var tag: Int = -1
    
    @State var alpha: CGFloat = 1
    var alphaState: State<CGFloat> { _alpha }
    
    @State var opacity: Float = 1
    var opacityState: State<Float> { _opacity }
    
    @State var hidden: Bool = false
    var hiddenState: State<Bool> { _hidden }
    
    @State var userInteraction: Bool = false
    var userInteractionState: State<Bool> { _userInteraction }
    
    @State var tint: UColor = .clear
    var tintState: State<UColor> { _tint }
    
    @State var background: UColor = .clear
    var backgroundState: State<UColor> { _background }
    
    @State var borderColor: UColor = .clear
    var borderColorState: State<UColor> { _borderColor }
    
    @State var shadowColor: UColor = .clear
    var shadowColorState: State<UColor> { _shadowColor }
    
    @State var color: UColor = .clear
    var colorState: State<UColor> { _color }
    
    @State var textColor: UColor = .clear
    var textColorState: State<UColor> { _textColor }
    
    #if !os(macOS)
    enum TraitCollectionHandlerType {
        case borderColor, shadowColor
    }
    var traitCollectionDidChangeHandlers: [TraitCollectionHandlerType: (UITraitCollection) -> Void] = [:]
    #endif
    
    var hovered: Bool = false
    #if os(macOS)
    var isFlipped: Bool = false
    #endif
    
    public typealias FormatCharactersClosure = (_ textField: V, _ range: NSRange, _ replacement: String) -> Void
    public typealias ChangeCharactersClosure = (_ textField: V, _ range: NSRange, _ replacement: String) -> Bool
    public typealias EmptyBoolClosure = () -> Bool
    public typealias BoolClosure = (V) -> Bool
    public typealias EmptyVoidClosure = () -> Void
    public typealias VoidClosure = (V) -> Void
    
    var _shouldBeginEditing: BoolClosure = { _ in return true }
    var _didBeginEditing: [VoidClosure] = []
    var _shouldEndEditing: BoolClosure = { _ in return true }
    var _didEndEditing: [VoidClosure] = []
    var _shouldFormatCharacters: FormatCharactersClosure?
    var _shouldChangeCharacters: ChangeCharactersClosure?
    var _shouldClear: BoolClosure = { _ in return true }
    var _shouldReturnVoid: () -> Void = {}
    var _shouldReturn: BoolClosure = { _ in return true }
    var _editingDidBegin: [VoidClosure] = []
    var _editingChanged: [VoidClosure] = []
    var _editingDidEnd: [VoidClosure] = []
    #if os(macOS)
    var _textFieldAction: [VoidClosure] = []
    var _textFieldEmptyAction: [EmptyVoidClosure] = []
    #endif
}
