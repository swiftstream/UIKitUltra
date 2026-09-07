#if os(macOS) || os(iOS) || os(tvOS)
extension String: SegmentControlable {
    public var item: SegmentControlableItem { .title(self) }
}
#endif
