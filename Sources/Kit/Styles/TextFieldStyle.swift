#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public class TextFieldStyle {
    var font: UFont?
    var textColor: UColor?
    
    public init () {}
}

//extension TextFieldStyle: _Fontable {
//    func _setFont(_ v: UIFont?) {
//        font = v
//    }
//}
//
//extension TextFieldStyle: _Colorable {
//    var _colorState: State<UIColor> {
//        <#code#>
//    }
//    
//    func _setColor(_ v: UIColor?) {
//        textColor = v
//    }
//}
//
//extension TextFieldStyle: _TextAligmentable {
//    func _setTextAlignment(v: NSTextAlignment) {
//        textAlignment = v
//    }
//}
//
//extension TextFieldStyle: _Secureable {
//    func _setSecure(_ v: Bool) {
//        isSecureTextEntry = v
//    }
//}
//
//extension TextFieldStyle: _Placeholderable {
//    func _setPlaceholder(_ v: String) {
//        placeholder = v
//    }
//    
//    func _setPlaceholder(_ v: AttrStr?) {
//        attributedPlaceholder = v?.attributedString
//    }
//}
//
//extension TextField: _Keyboardable {
//    func _setKeyboardType(_ v: UIKeyboardType) {
//        keyboardType = v
//    }
//    
//    func _setReturnKeyType(_ v: UIReturnKeyType) {
//        returnKeyType = v
//    }
//    
//    func _setKeyboardAppearance(_ v: UIKeyboardAppearance) {
//        keyboardAppearance = v
//    }
//    
//    func _setInputView(_ v: UIView?) {
//        inputView = v
//    }
//    
//    func _setInputAccessoryView(_ v: UIView?) {
//        inputAccessoryView = v
//    }
//}
//
//extension TextFieldStyle: _TextAutocapitalizationable {
//    func _setTextAutocapitalizationType(_ v: UITextAutocapitalizationType) {
//        autocapitalizationType = v
//    }
//}
//
//extension TextFieldStyle: _TextAutocorrectionable {
//    func _setTextAutocorrectionType(_ v: UITextAutocorrectionType) {
//        autocorrectionType = v
//    }
//}
//
//extension TextFieldStyle: _TextFieldContentTypeable {
//    func _setTextFieldContentType(v: TextFieldContentType) {
//        if #available(iOS 10.0, *) {
//            if let type = v.type {
//                textContentType = type
//            }
//        }
//    }
//}
//
//extension TextFieldStyle: _TextFieldLeftViewable {
//    func _setLeftView(v: UIView) {
//        leftView = v
//    }
//    
//    func _setLeftViewMode(v: UITextField.ViewMode) {
//        leftViewMode = v
//    }
//}
//
//extension TextFieldStyle: _TextFieldRightViewable {
//    func _setRightView(v: UIView) {
//        rightView = v
//    }
//    
//    func _setRightViewMode(v: UITextField.ViewMode) {
//        rightViewMode = v
//    }
//}
#endif
