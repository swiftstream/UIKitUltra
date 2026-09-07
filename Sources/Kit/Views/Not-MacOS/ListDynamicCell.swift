#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

class UListDynamicCell: TableViewCell {
    func setRootView(_ rootView: UStackView) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        rootView.translatesAutoresizingMaskIntoConstraints = false
        contentView.body { rootView }
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: rootView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
        ])
    }
}
#endif
#endif
