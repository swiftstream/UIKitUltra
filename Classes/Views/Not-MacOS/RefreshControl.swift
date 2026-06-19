#if !os(macOS)
import UIKit
#if !os(tvOS)

extension UIRefreshControl {
    public static var `default`: URefreshControl { .init() }
}

@available(*, deprecated, renamed: "URefreshControl")
public typealias RefreshControl = URefreshControl

open class URefreshControl: UIRefreshControl {
    private let _stateBindingHolder = TempStatesHolder()

    var stateBindingHolder: TempStatesHolder {
        _stateBindingHolder
    }

    override init() {
        super.init()
        setup()
    }
    
    public init (_ attributedStrings: AttributedString...) {
        super.init()
        attributedTitle()
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addTarget(self, action: #selector(_refreshAction(_:)), for: .valueChanged)
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        frame = .init(x: 0, y: 0, width: 20, height: 20)
        setNeedsLayout()
    }
    
    @objc private func _refreshAction(_ sender: Any) {
        refreshHandler()
    }
    
    private var refreshHandler = {}
    
    public func onRefresh(_ handler: @escaping () -> Void) -> Self {
        refreshHandler = handler
        return self
    }
    
    // MARK: Attributed Title
    
    @discardableResult
    public func attributedTitle(_ attributedStrings: AttributedString...) -> Self {
        attributedTitle(attributedStrings)
    }
    
    @discardableResult
    public func attributedTitle(_ attributedStrings: [AttributedString]) -> Self {
        let attrStr = NSMutableAttributedString(string: "")
        for str in attributedStrings {
            attrStr.append(str._attributedString)
        }
        attributedTitle = attrStr
        return self
    }
    
    // MARK: Tint Color
    
    @UIKitPlus.State var tint: UIColor = .clear
    
    @discardableResult
    public func tint(_ color: UIColor) -> Self {
        tintColor = color
        return self
    }
    
    @discardableResult
    public func tint(_ number: Int) -> Self {
        tintColor = number.color
        return self
    }
    
    @discardableResult
    public func tint(_ state: UIKitPlus.State<UIColor>) -> Self {
        tintColor = state.wrappedValue
        tint = state.wrappedValue
        state.listen { [weak self] new in
            self?.tintColor = new
            self?.tint = new
        }
        .hold(in: stateBindingHolder)
        return self
    }
    
    // MARK: Self pointer
    
    public func itself(_ itself: inout RefreshControl?) -> Self {
        itself = self
        return self
    }
}

extension URefreshControl: _StateBindingOwner {}

#endif
#endif
