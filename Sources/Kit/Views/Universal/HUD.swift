#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@available(*, deprecated, renamed: "UHUD")
public typealias HUD = UHUD

@MainActor
open class UHUD: UView {
    override public var declarativeView: HUD { return self }
    
    var imageHeight: CGFloat = 50
    #if os(macOS)
    lazy var imageView = UImage(nil)
        .mode(.resizeAspect)
    #else
    lazy var imageView = UImage(nil)
        .mode(.scaleAspectFit)
    #endif
    
    lazy var symbolLabel = UText()
        .font(v: .boldSystemFont(ofSize: 48))
        .color(.white)
        .alignment(.center)
    #if os(macOS)
    lazy var activityIndicator = UActivityIndicator()
    #else
    lazy var activityIndicator = UActivityIndicator(style: .whiteLarge)
    #endif
    lazy var titleLabel = UText()
        .font(v: .boldSystemFont(ofSize: 24))
        .color(.white)
        .alignment(.center)
    lazy var subTitleLabel = UText()
        .multiline()
        .font(v: .systemFont(ofSize: 16))
        .color(.white)
        .alignment(.center)
    #if os(macOS)
    lazy var contentView = UView()
        .size(>=70)
        .corners(10)
        .background(.white(0, alpha: 0.7))
        .centerInSuperview()
        .topToSuperview(>=20)
        .leadingToSuperview(>=20 ! 998)
        .trailingToSuperview(<=-20 ! 998)
        .bottomToSuperview(<=-20)
    
    lazy var backgroundOverlay = UView().background(.white(0, alpha: 0.2)).edgesToSuperview().masksToBounds()
    #else
    lazy var contentView = UView()
        .size(>=100)
        .corners(10)
        .background(.init(red: 0, green: 0, blue: 0, alpha: 0.7))
        .centerInSuperview()
        .topToSuperview(>=20)
        .leadingToSuperview(>=20 ! 998)
        .trailingToSuperview(<=-20 ! 998)
        .bottomToSuperview(<=-20)
    
    lazy var backgroundOverlay = UView().background(.init(red: 0, green: 0, blue: 0, alpha: 0.2)).edgesToSuperview().masksToBounds()
    #endif
    
    open override func buildView() {
        super.buildView()
        hidden()
        edgesToSuperview()
        body {
            backgroundOverlay
            contentView
        }
    }
    
    // MARK: - Setup
    
    #if os(macOS)
    @discardableResult
    public func image(_ image: NSImage?) -> Self {
        imageView.image = image
        return self
    }
    #else
    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        imageView.image = image
        return self
    }
    #endif
    
    @discardableResult
    public func symbol(_ value: String) -> Self {
        symbolLabel.text(value)
        return self
    }
    
    @discardableResult
    public func title(_ value: String) -> Self {
        titleLabel.text(value)
        return self
    }
    
    @discardableResult
    public func subTitle(_ value: String) -> Self {
        subTitleLabel.text(value)
        return self
    }
    
    // MARK: - Show/Hide
    
    @discardableResult
    public func show(_ animated: Bool = false) -> Self {
        superview?.bringSubviewToFront(self)
        #if os(macOS)
        activityIndicator.startAnimation(nil)
        #else
        activityIndicator.startAnimating()
        #endif
        if !animated {
            hidden(false).alpha(1)
        } else {
            self.hidden(false).alpha(0)
            #if os(macOS)
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                self.animator().alphaValue = 1
            }
            #else
            UIView.animate(withDuration: 0.3) {
                self.alpha(1)
            }
            #endif
        }
        return self
    }
    
    @discardableResult
    public func hide(_ animated: Bool = false, _ completionHandler: (@MainActor () -> Void)? = nil) -> Self {
        if !animated {
            hidden()
            completionHandler?()
        } else {
            #if os(macOS)
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                self.animator().alphaValue = 0
            }) {
                DispatchQueue.main.async {
                    self.hidden().alpha(1)
                    completionHandler?()
                }
            }
            #else
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha(0)
            }) { _ in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.hidden().alpha(1)
                    completionHandler?()
                }
            }
            #endif
        }
        return self
    }
    
    @discardableResult
    public func hideAfter(_ timeInterval: TimeInterval, _ animated: Bool = false, _ completionHandler: (@MainActor () -> Void)? = nil) -> Self {
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) { [weak self] in
            self?.hide(animated, completionHandler)
        }
        return self
    }
    
    // MARK: - Mode
    
    public enum Element {
        case image
        case symbol
        case activityIndicator
        case title
        case subTitle
        static var allElements: [Element] { return [.image, .symbol, .activityIndicator, .title, .subTitle] }
    }
    
    @discardableResult
    public func mode(_ elements: Element...) -> Self {
        // Elements to remove
        for element in Array(Set(Element.allElements).symmetricDifference(elements)) {
            switch element {
            case .image:
                guard let _ = imageView.superview else { continue }
                imageView.removeAllConstraints()
                imageView.removeFromSuperview()
            case .symbol:
                guard let _ = symbolLabel.superview else { continue }
                symbolLabel.removeAllConstraints()
                symbolLabel.removeFromSuperview()
            case .activityIndicator:
                guard let _ = activityIndicator.superview else { continue }
                activityIndicator.removeAllConstraints()
                activityIndicator.removeFromSuperview()
            case .title:
                guard let _ = titleLabel.superview else { continue }
                titleLabel.removeAllConstraints()
                titleLabel.removeFromSuperview()
            case .subTitle:
                guard let _ = subTitleLabel.superview else { continue }
                subTitleLabel.removeAllConstraints()
                subTitleLabel.removeFromSuperview()
            }
        }
        // Add elements into content view
        var elements = elements
        var topView: BaseView?
        while elements.count > 0 {
            let element = elements.removeFirst()
            switch element {
            case .image:
                imageView.removeAllConstraints()
                imageView.removeFromSuperview()
                if let topView = topView {
                    imageView.top(to: .bottom, of: topView, 4)
                } else {
                    imageView.topToSuperview(20)
                }
                if elements.count == 0 {
                    imageView.bottomToSuperview(-20)
                }
                imageView.height(imageHeight).edgesToSuperview(leading: 20, trailing: -20)
                contentView.body { imageView }
                topView = imageView
            case .symbol:
                symbolLabel.removeAllConstraints()
                symbolLabel.removeFromSuperview()
                if let topView = topView {
                    symbolLabel.top(to: .bottom, of: topView, 4)
                } else {
                    symbolLabel.topToSuperview(20)
                }
                if elements.count == 0 {
                    symbolLabel.bottomToSuperview(-20)
                }
                symbolLabel.edgesToSuperview(leading: 20, trailing: -20)
                contentView.body { symbolLabel }
                topView = symbolLabel
            case .activityIndicator:
                activityIndicator.removeAllConstraints()
                activityIndicator.removeFromSuperview()
                if let topView = topView {
                    activityIndicator.top(to: .bottom, of: topView, 4)
                } else {
                    activityIndicator.topToSuperview(20)
                }
                if elements.count == 0 {
                    activityIndicator.bottomToSuperview(-20)
                }
                activityIndicator.centerXInSuperview()
                contentView.body { activityIndicator }
                topView = activityIndicator
            case .title:
                titleLabel.removeAllConstraints()
                titleLabel.removeFromSuperview()
                if let topView = topView {
                    titleLabel.top(to: .bottom, of: topView, 4)
                } else {
                    titleLabel.topToSuperview(20)
                }
                if elements.count == 0 {
                    titleLabel.bottomToSuperview(-20)
                }
                titleLabel.edgesToSuperview(leading: 20, trailing: -20)
                contentView.body { titleLabel }
                topView = titleLabel
            case .subTitle:
                subTitleLabel.removeAllConstraints()
                subTitleLabel.removeFromSuperview()
                if let topView = topView {
                    subTitleLabel.top(to: .bottom, of: topView, 4)
                } else {
                    subTitleLabel.topToSuperview(20)
                }
                if elements.count == 0 {
                    subTitleLabel.bottomToSuperview(-20)
                }
                subTitleLabel.edgesToSuperview(leading: 20, trailing: -20)
                contentView.body { subTitleLabel }
                topView = subTitleLabel
            }
        }
        return self
    }
    
    // MARK: - Colors
    
    #if !os(macOS)
    @discardableResult
    public func indicatorColor(_ color: UColor) -> Self {
        activityIndicator.color = color
        return self
    }
    
    @discardableResult
    public func indicatorColor(_ number: Int) -> Self {
        indicatorColor(number.color)
    }
    #endif
    
    @discardableResult
    public func contentViewColor(_ color: UColor) -> Self {
        contentView.background(color)
        return self
    }
    
    @discardableResult
    public func contentViewColor(_ number: Int) -> Self {
        contentView.background(number)
        return self
    }
    
    @discardableResult
    public func dimColor(_ color: UColor) -> Self {
        backgroundOverlay.background(color)
        return self
    }
    
    @discardableResult
    public func dimColor(_ number: Int) -> Self {
        backgroundOverlay.background(number)
        return self
    }
}
#endif
