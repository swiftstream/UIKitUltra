#if os(macOS)
import AppKit
#else
import UIKit
#endif

protocol StackWrapperView: AnyObject {
    var _stack: _StackView { get }
}

extension BaseView {
    @discardableResult
    @MainActor
    public func body(@BodyBuilder block: BodyBuilder.SingleView) -> Self {
        if let wrapper = self as? StackWrapperView {
            wrapper._stack.add(item: block())
        } else {
            addItem(block())
        }
        return self
    }
    
    func addItem(_ item: BodyBuilderItemable, at index: Int? = nil) {
        addItem(item.bodyBuilderItem, at: index)
    }
    
    func addItem(_ item: BodyBuilderItem, at index: Int? = nil) {
        switch item {
        case .single(let view):
            add(views: [view], at: index)
        case .multiple(let views):
            add(views: views, at: index)
        case .forEach(let fr):
            let subview = UView().edgesToSuperview()
            let binding = RenderedForEachBinding(fr)
            subview.retainRenderedForEachBinding(binding)

            fr.allItems().forEach {
                subview.addItem($0)
            }

            add(views: [subview], at: index)

            fr.subscribeToChanges({}, { [weak subview, weak binding] deletions, insertions, _ in
                guard let subview = subview, let fr = binding?.forEach else { return }

                subview.subviews.removeFromSuperview(at: deletions)

                insertions.forEach {
                    subview.addItem(fr.items(at: $0), at: $0)
                }
            }) {}

            break
        case .nested(let items):
            items.forEach { addItem($0, at: index) }
            break
        case .none:
            break
        }
    }
    
    func add(views: [BaseView], at index: Int?) {
        guard let index = index else {
            addSubview(views)
            return
        }
        let nextViews = subviews.dropFirst(index)
        nextViews.forEach { $0.removeFromSuperview() }
        addSubview(views)
        nextViews.forEach { self.addSubview($0) }
    }
}
