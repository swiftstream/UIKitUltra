#if os(macOS) || os(iOS) || os(tvOS)
@objc
public protocol TextFieldDelegate: NSObjectProtocol {
    @objc @available(iOS 2.0, *)
    optional func textFieldShouldBeginEditing(_ textField: UTextField) -> Bool
    
    @objc @available(iOS 2.0, *)
    optional func textFieldDidBeginEditing(_ textField: UTextField)
    
    @objc @available(iOS 2.0, *)
    optional func textFieldShouldEndEditing(_ textField: UTextField) -> Bool
    
    @objc @available(iOS 2.0, *)
    optional func textFieldDidEndEditing(_ textField: UTextField)
    
    #if !os(macOS)
    @objc @available(iOS 10.0, *)
    optional func textFieldDidEndEditing(_ textField: UTextField, reason: UTextField.DidEndEditingReason)
    #endif
    
    @objc @available(iOS 2.0, *)
    optional func textField(_ textField: UTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    
    @objc @available(iOS 2.0, *)
    optional func textFieldShouldClear(_ textField: UTextField) -> Bool
    
    @objc @available(iOS 2.0, *)
    optional func textFieldShouldReturn(_ textField: UTextField) -> Bool
}
#endif
