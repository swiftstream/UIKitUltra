#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

open class TabViewController: UITabBarController {
    @discardableResult
    public func title(_ title: String) -> TabViewController {
        navigationItem.title = title
        tabBarItem.title = title
        return self
    }
    
    @discardableResult
    public func title(_ header: String, _ item: String) -> TabViewController {
        navigationItem.title = header
        tabBarItem.title = item
        return self
    }
    
    @discardableResult
    public func icon(_ image: _UImage?) -> TabViewController {
        tabBarItem.image = image
        return self
    }
    
    @discardableResult
    public func icon(_ named: String) -> TabViewController {
        tabBarItem.image = UIImage(named: named)
        return self
    }
    
    @discardableResult
    public func tint(_ color: UColor) -> TabViewController {
        tabBarController?.tabBar.tintColor = color
        return self
    }
    
    @discardableResult
    public func tint(_ numberColor: Int) -> TabViewController {
        tabBarController?.tabBar.tintColor = numberColor.color
        return self
    }
}
#endif
#endif
