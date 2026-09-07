#if os(macOS) || os(iOS) || os(tvOS)
//#if !os(macOS)
//import UIKit
//
//class UStaticListCell: TableViewCell {
//    init (_ rootView: UIView) {
//        super.init(style: .default, reuseIdentifier: nil)
//        contentView.body { rootView }
//        NSLayoutConstraint.activate([
//            contentView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
//            contentView.topAnchor.constraint(equalTo: rootView.topAnchor),
//            contentView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
//        ])
//    }
//    
//    public required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//#endif
#endif
