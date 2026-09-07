#if os(macOS) || os(iOS) || os(tvOS)
@MainActor
public protocol NavigationControllerable: AnyObject {
    var isSwipeBackEnabled: Bool { get set }
}
#endif
