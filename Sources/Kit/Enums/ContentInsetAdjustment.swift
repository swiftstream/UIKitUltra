#if os(macOS) || os(iOS) || os(tvOS)
public enum ContentInsetAdjustment: Int {
    case automatic
    case scrollableAxes
    case never
    case always
}
#endif
