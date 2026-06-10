#if !os(macOS)
import Foundation
import UIKit

open class NavigationController<T: UIViewController>: UINavigationController, UIGestureRecognizerDelegate, NavigationControllerable {
    #if !os(tvOS)
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if let last = viewControllers.last {
            if let last = last as? ViewController {
                return last.statusBarStyle.rawValue
            }
            return last.preferredStatusBarStyle
        }
        return statusBarStyle.rawValue
    }
    #endif
    
    /// UIKitPlus reimplementation of `preferredStatusBarStyle`
    open var statusBarStyle: StatusBarStyle { _statusBarStyle ?? .default }
    private var _statusBarStyle: StatusBarStyle?
    
    private lazy var font: UIFont = .systemFont(ofSize: 17)
    private lazy var style: NavigationControllerStyle = .default
    private lazy var tintColor: UIColor = .white
    
    private var viewController: T? { return viewControllers.first as? T }
    
    public var isSwipeBackEnabled = true

    private let _stateBindingHolder = TempStatesHolder()

    var stateBindingHolder: TempStatesHolder {
        _stateBindingHolder
    }
    
    public init() {
        let viewController = T(nibName: nil, bundle: nil)
        super.init(rootViewController: viewController)
        setup()
    }
    
    public init(_ rootViewController: T) {
        super.init(rootViewController: rootViewController)
        setup()
    }
    
    public init(_ type: T.Type) {
        let viewController = type.init(nibName: nil, bundle: nil)
        super.init(rootViewController: viewController)
        setup()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        #if !os(tvOS)
        interactivePopGestureRecognizer?.delegate = self
        #endif
    }
    
    private func setupAppearance() {
        view.backgroundColor = .white
        //        automaticallyAdjustsScrollViewInsets = true // TODO: either delete or fix
        //        extendedLayoutIncludesOpaqueBars = true
        navigationBar.titleTextAttributes = [.foregroundColor: tintColor, .font: font]
        navigationBar.tintColor = tintColor
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.setBackgroundImage(UIImage(), for: .compact)
        navigationBar.shadowImage = UIImage()
        switch style {
        case .default:
//            navigationBar.barTintColor = customTintColor
            navigationBar.isTranslucent = false
        case .transparent:
            navigationBar.backgroundColor = UIColor.clear
            navigationBar.isTranslucent = true
        case .color(let color):
            navigationBar.barTintColor = color
            navigationBar.backgroundColor = color
            navigationBar.isTranslucent = true
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1 && isSwipeBackEnabled
    }
    #if !os(tvOS)
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    #endif
    
    // MARK: Style
    
    @discardableResult
    public func style(_ style: NavigationControllerStyle = .default) -> NavigationController {
//        guard let vc = viewController as? NavControllerStyleable else {
            self.style = style
            setupAppearance()
            return self
//        }
//        self.style = vc.navStyle
////        if let color = vc.navTintColor {
////            tintColor = color
////        }
//        statusBarStyle = vc.navStatusBarStyle
//        setupAppearance()
//        return self
    }
    
    // MARK: Tint Color
    
    @discardableResult
    public func tint(_ color: UIColor) -> Self {
        tintColor = color
        setupAppearance()
        return self
    }
    
    @discardableResult
    public func statusBarStyle(_ style: StatusBarStyle) -> NavigationController {
        _statusBarStyle = style
        #if !os(tvOS)
        setNeedsStatusBarAppearanceUpdate()
        #endif
        return self
    }
    
    @discardableResult
    public func hideNavigationBar(_ value: Bool = true) -> Self {
        isNavigationBarHidden = value
        return self
    }
    
    @discardableResult
    public func enableSwipeBack(_ value: Bool = true) -> Self {
        isSwipeBackEnabled = value
        return self
    }
    
    //    public func setupModal() {
    //        modalTransitionStyle = .coverVertical
    //        modalPresentationStyle = .fullScreen
    //    }
}

extension NavigationController: _StateBindingOwner {}

extension NavigationController: _Fontable {
    func _setFont(_ v: UIFont?) {
        guard let v = v else { return }
        font = v
        setupAppearance()
    }
}
#endif
