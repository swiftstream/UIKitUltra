#if os(macOS) || os(iOS) || os(tvOS)
////
////  SwiftUIable.swift
////  UIKit-Plus
////
////  Created by Mihael Isaev on 13.09.2020.
////
//
//#if os(macOS)
//import AppKit
//#else
//import UIKit
//#endif
//
//#if canImport(SwiftUI)
//import SwiftUI
//#endif
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//public protocol SwiftUIable: BodyBuilderItemable, UIViewable, DeclarativeProtocol {
//    var view: UView { get }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//protocol _SwiftUIable: SwiftUIable, DeclarativeProtocolInternal {}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension _SwiftUIable {
//    var _properties: PropertiesInternal {
//        get { view._properties }
//        set { view._properties = newValue }
//    }
//    
//    var __height: State<CGFloat> { view.__height }
//    var __width: State<CGFloat> { view.__width }
//    var __top: State<CGFloat> { view.__top }
//    var __leading: State<CGFloat> { view.__leading }
//    var __left: State<CGFloat> { view.__left }
//    var __trailing: State<CGFloat> { view.__trailing }
//    var __right: State<CGFloat> { view.__right }
//    var __bottom: State<CGFloat> { view.__bottom }
//    var __centerX: State<CGFloat> { view.__centerX }
//    var __centerY: State<CGFloat> { view.__centerY }
//}
//
//#if os(macOS)
//@available(macOS 10.15, *)
//class UHostingController<Content: View>: NSHostingController<Content> {
//    lazy var declarativeView: UView = UView(inline: view)
//}
//#else
//@available(iOS 13.0, tvOS 13.0, *)
//class UHostingController<Content: View>: UIHostingController<Content> {
//    lazy var declarativeView: UView = UView(inline: view)
//}
//#endif
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension _SwiftUIable {
//    // MARK: BodyBuilderItemable
//    
//    public var bodyBuilderItem: BodyBuilderItem {
//        .single(view)
//    }
//    
//    // MARK: UIViewable
//    
//    public var _view: BaseView { view }
//    
//    // MARK: DeclarativeProtocol
//    
//    public var declarativeView: UView { view }
//    
//    public var properties: Properties<UView> {
//        get { view.properties }
//        set { view.properties = newValue }
//    }
//    
//    // MARK: Public Constraints
//    
//    public var height: CGFloat {
//        get { view.height }
//        set { view.height = newValue }
//    }
//    
//    public var width: CGFloat {
//        get { view.width }
//        set { view.width = newValue }
//    }
//    
//    public var top: CGFloat {
//        get { view.top }
//        set { view.top = newValue }
//    }
//    
//    public var leading: CGFloat {
//        get { view.leading }
//        set { view.leading = newValue }
//    }
//    
//    public var left: CGFloat {
//        get { view.left }
//        set { view.left = newValue }
//    }
//    
//    public var trailing: CGFloat {
//        get { view.trailing }
//        set { view.trailing = newValue }
//    }
//    
//    public var right: CGFloat {
//        get { view.right }
//        set { view.right = newValue }
//    }
//    
//    public var bottom: CGFloat {
//        get { view.bottom }
//        set { view.bottom = newValue }
//    }
//    
//    public var centerX: CGFloat {
//        get { view.centerX }
//        set { view.centerX = newValue }
//    }
//    
//    public var centerY: CGFloat {
//        get { view.centerY }
//        set { view.centerY = newValue }
//    }
//    
//    public var tag: Int {
//        get { view.tag }
//        set { view.tag = newValue }
//    }
//}
//
//#if canImport(SwiftUI)
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension Rectangle: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension RoundedRectangle: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension Circle: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension Ellipse: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension Path: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension Capsule: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension Text: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension VStack: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension HStack: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension Button: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension List: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension NavigationView: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension TabView: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension TextField: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension ScrollView: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension Image: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension Picker: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension DatePicker: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension Slider: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension Stepper: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
//@available(watchOS, unavailable)
//extension Toggle: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//// MARK: - iOS14+
//
//#if swift(>=5.3)
////@available(iOS 14.0, macOS 10.16, tvOS 14.0, *)
////@available(watchOS, unavailable)
////extension LazyVGrid: _SwiftUIable {
////    public var view: UView {
////        UHostingController(rootView: self).declarativeView
////    }
////}
////
////@available(iOS 14.0, macOS 10.16, tvOS 14.0, *)
////@available(watchOS, unavailable)
////extension LazyHGrid: _SwiftUIable {
////    public var view: UView {
////        UHostingController(rootView: self).declarativeView
////    }
////}
//
//@available(iOS 14.0, macOS 10.16, tvOS 14.0, *)
//@available(watchOS, unavailable)
//extension Label: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 14.0, macOS 10.16, tvOS 14.0, *)
//@available(watchOS, unavailable)
//extension TextEditor: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
////@available(iOS 14.0, macOS 10.16, tvOS 14.0, *)
////@available(watchOS, unavailable)
////extension ToolbarItem: _SwiftUIable {
////    public var view: UView {
////        UHostingController(rootView: self).declarativeView
////    }
////}
//
////@available(iOS 14.0, macOS 10.16, tvOS 14.0, *)
////@available(watchOS, unavailable)
////extension LazyVGrid: _SwiftUIable {
////    public var view: UView {
////        UHostingController(rootView: self).declarativeView
////    }
////}
//
////@available(iOS 14.0, macOS 10.16, tvOS 14.0, *)
////@available(watchOS, unavailable)
////extension LazyHGrid: _SwiftUIable {
////    public var view: UView {
////        UHostingController(rootView: self).declarativeView
////    }
////}
//
//@available(iOS 14.0, macOS 10.16, tvOS 14.0, *)
//@available(watchOS, unavailable)
//extension LazyHStack: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
//@available(iOS 14.0, macOS 10.16, tvOS 14.0, *)
//@available(watchOS, unavailable)
//extension LazyVStack: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
////@available(iOS 14.0, macOS 10.16, tvOS 14.0, *)
////@available(watchOS, unavailable)
////extension ProgressView: _SwiftUIable {
////    public var view: UView {
////        UHostingController(rootView: self).declarativeView
////    }
////}
//
//@available(iOS 14.0, macOS 10.16, tvOS 14.0, *)
//@available(watchOS, unavailable)
//extension Link: _SwiftUIable {
//    public var view: UView {
//        UHostingController(rootView: self).declarativeView
//    }
//}
//
////@available(iOS 14.0, macOS 10.16, tvOS 14.0, *)
////@available(watchOS, unavailable)
////extension ProgressView: _SwiftUIable {
////    public var view: UView {
////        UHostingController(rootView: self).declarativeView
////    }
////}
//
////@available(iOS 14.0, macOS 10.16, tvOS 14.0, *)
////@available(watchOS, unavailable)
////extension Map: _SwiftUIable {
////    public var view: UView {
////        UHostingController(rootView: self).declarativeView
////    }
////}
//#endif
//#endif
#endif
