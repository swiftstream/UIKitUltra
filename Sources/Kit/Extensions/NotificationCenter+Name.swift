#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

public protocol CustomNotification {
    var notificationType: NotificationCenter.NotificationType { get }
}

extension String: CustomNotification {
    public var notificationType: NotificationCenter.NotificationType { .init(self) }
}

struct AddedViewWithTag: CustomNotification {
    var notificationType: NotificationCenter.NotificationType { .init("\(tag)") }
    
    var tag: Int
    
    init (_ tag: Int) {
        self.tag = tag
    }
}

extension Notification.Name: RawRepresentable {}
extension NotificationCenter {
    public struct NotificationType {
        /// EXAMPLE:
        /// Declare your custom notifications like this
        /// ```swift
        /// extension NotificationCenter.NotificationType {
        ///     static var authorized = "authorized".notificationType
        ///     static var profileUpdated = "profileUpdated".notificationType
        /// }
        let name: NSNotification.Name
        
        public init (_ name: String) {
            self.name = .init(name)
        }
        
        func with(postfix: String) -> Notification.Name {
            .init(name.rawValue + " " + postfix)
        }
    }
    
    public func addObserver(_ observer: Any, selector aSelector: Selector, type: NotificationType, object: Any? = nil) {
        addObserver(observer, selector: aSelector, name: type.name, object: object)
    }
    
    public func addObserver(_ observer: Any, selector aSelector: Selector, type: CustomNotification, object: Any? = nil) {
        addObserver(observer, selector: aSelector, name: type.notificationType.name, object: object)
    }
    
    public func addObserver(_ observer: Any, selector aSelector: Selector, type: NotificationType, typePostfix key: String, object: Any? = nil) {
        addObserver(observer, selector: aSelector, name: type.with(postfix: key), object: object)
    }
    
    public func addObserver(_ observer: Any, selector aSelector: Selector, type: CustomNotification, typePostfix key: String, object: Any? = nil) {
        addObserver(observer, selector: aSelector, name: type.notificationType.with(postfix: key), object: object)
    }
    
    public func addObserver(for type: NotificationType, using callback: @escaping ()->Void) {
        addObserver(forName:  type.name, object: nil, queue: nil) { _ in
            callback()
        }
    }
    
    public func addObserver(for type: CustomNotification, using callback: @escaping ()->Void) {
        addObserver(forName:  type.notificationType.name, object: nil, queue: nil) { _ in
            callback()
        }
    }
    
    public func addObserver(for type: NotificationType, using: @escaping (Notification)->Void) {
        addObserver(forName:  type.name, object: nil, queue: nil, using: using)
    }
    
    public func addObserver(for type: CustomNotification, using: @escaping (Notification)->Void) {
        addObserver(forName:  type.notificationType.name, object: nil, queue: nil, using: using)
    }
    
    public func addObserver(for type: NotificationType, typePostfix key: String, using: @escaping (Notification)->Void) {
        addObserver(forName:  type.with(postfix: key), object: nil, queue: nil, using: using)
    }
    
    public func addObserver(for type: CustomNotification, typePostfix key: String, using: @escaping (Notification)->Void) {
        addObserver(forName:  type.notificationType.with(postfix: key), object: nil, queue: nil, using: using)
    }
    
    public func post(type: NotificationType, object anObject: Any? = nil) {
        post(name: type.name, object: anObject)
    }
    
    public func post(raw type: CustomNotification, object anObject: Any? = nil) {
        post(name: type.notificationType.name, object: anObject)
    }
    
    public func post(type: NotificationType, typePostfix key: String, object anObject: Any? = nil) {
        post(name: type.with(postfix: key), object: anObject)
    }
    
    public func post(raw type: CustomNotification, typePostfix key: String, object anObject: Any? = nil) {
        post(name: type.notificationType.with(postfix: key), object: anObject)
    }
}
#endif
