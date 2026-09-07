#if os(macOS) || os(iOS) || os(tvOS)
public protocol SegmentControlable {
    var item: SegmentControlableItem { get }
}
#endif
