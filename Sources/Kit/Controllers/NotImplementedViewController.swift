#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

class NotImplementedViewController: ViewController {
    #if !os(macOS)
    override var statusBarStyle: StatusBarStyle { .light }
    #endif
    
    let name: String
    
    init (_ name: String) {
        self.name = name
        #if os(macOS)
        super.init(nibName: nil, bundle: nil)
        #else
        super.init()
        #endif
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func buildUI() {
        super.buildUI()
        #if os(macOS)
        
        #else
        view.backgroundColor = .darkGray
        body {
            UText("`\(name)`".foreground(.red), " hasn't been implemented yet")
                .color(.white)
                .alignment(.center)
                .centerYInSuperview()
                .edgesToSuperview(leading: 0, trailing: 0)
        }
        #endif
    }
}
#endif
