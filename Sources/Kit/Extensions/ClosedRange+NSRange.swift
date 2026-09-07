#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

extension ClosedRange where Bound == Int {
    var nsRange: NSRange { return .init(location: first ?? 0, length: last ?? 0) }
}
#endif
