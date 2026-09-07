#if os(macOS) || os(iOS) || os(tvOS)
//import UIKit
//
//public class DeclarativeViewConstraints {
//    var _declarativeView: DeclarativeProtocolInternal
//    var declarativeView: UIView
//    
//    init (_ _declarativeView: DeclarativeProtocolInternal, _ declarativeView: UIView) {
//        self._declarativeView = _declarativeView
//        self.declarativeView = declarativeView
//    }
//    
//    public var width: NSLayoutConstraint? {
//        get { _declarativeView._properties.constraintsMain[.width] }
//        set { _declarativeView._properties.constraintsMain.setValue(newValue, for: .width) }
//    }
//    
//    public var height: NSLayoutConstraint? {
//        get { _declarativeView._properties.constraintsMain[.height] }
//        set { _declarativeView._properties.constraintsMain.setValue(newValue, for: .height) }
//    }
//    
//    public var top: NSLayoutConstraint? {
//        get { _declarativeView._properties.constraintsMain[.top] }
//        set { _declarativeView._properties.constraintsMain.setValue(newValue, for: .top) }
//    }
//    
//    public var leading: NSLayoutConstraint? {
//        get { _declarativeView._properties.constraintsMain[.leading] }
//        set { _declarativeView._properties.constraintsMain.setValue(newValue, for: .leading) }
//    }
//    
//    public var trailing: NSLayoutConstraint? {
//        get { _declarativeView._properties.constraintsMain[.trailing] }
//        set { _declarativeView._properties.constraintsMain.setValue(newValue, for: .trailing) }
//    }
//    
//    public var bottom: NSLayoutConstraint? {
//        get { _declarativeView._properties.constraintsMain[.bottom] }
//        set { _declarativeView._properties.constraintsMain.setValue(newValue, for: .bottom) }
//    }
//    
//    public var centerX: NSLayoutConstraint? {
//        get { _declarativeView._properties.constraintsMain[.centerX] }
//        set { _declarativeView._properties.constraintsMain.setValue(newValue, for: .centerX) }
//    }
//    
//    public var centerY: NSLayoutConstraint? {
//        get { _declarativeView._properties.constraintsMain[.centerY] }
//        set { _declarativeView._properties.constraintsMain.setValue(newValue, for: .centerY) }
//    }
//    
//    public var outer: OuterConstraints { .init(declarativeView, _declarativeView._properties.constraintsOuter) }
//}
#endif
