#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
protocol EditableStackView: AnyObject {
    var arrangedSubviews: [BaseView] { get }
    func addArrangedSubview(_ view: BaseView)
    func add(arrangedView: BaseView, at index: Int)
}

@MainActor
extension EditableStackView {
    func add(arrangedView: BaseView, at index: Int) {
        let nextViews = arrangedSubviews.dropFirst(index)
        nextViews.forEach { $0.removeFromSuperview() }
        addArrangedSubview(arrangedView)
        nextViews.forEach { self.addArrangedSubview($0) }
    }
}

extension Array where Element == BaseView {
    func removeFromSuperview(at indexes: [Int]) {
        guard indexes.count > 0 else { return }
        var filtered: [BaseView] = []
        enumerated().forEach { i, v in
            guard indexes.contains(i) else { return }
            filtered.append(v)
        }
        filtered.forEach { $0.removeFromSuperview() }
    }
}
