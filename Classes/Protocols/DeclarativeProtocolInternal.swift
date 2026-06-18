#if os(macOS)
import AppKit
#else
import UIKit
#endif

internal protocol DeclarativeProtocolInternal: _StateBindingOwner {
    var _properties: PropertiesInternal { get set }
    
    var __height: State<CGFloat> { get }
    var __width: State<CGFloat> { get }
    var __top: State<CGFloat> { get }
    var __leading: State<CGFloat> { get }
    var __left: State<CGFloat> { get }
    var __trailing: State<CGFloat> { get }
    var __right: State<CGFloat> { get }
    var __bottom: State<CGFloat> { get }
    var __centerX: State<CGFloat> { get }
    var __centerY: State<CGFloat> { get }
}

@MainActor
extension DeclarativeProtocolInternal {
    var stateBindingHolder: TempStatesHolder {
        _properties.stateBindingHolder
    }
}
