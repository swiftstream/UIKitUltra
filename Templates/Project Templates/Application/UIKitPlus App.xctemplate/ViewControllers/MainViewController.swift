#if os(macOS) || os(iOS) || os(tvOS)
//___FILEHEADER___

import UIKitPlus

final class MainViewController: ViewController {
    override func buildUI() {
        super.buildUI()
        view.backgroundColor = .white

        body {
            UText("UIKitPlus")
                .color(.black)
                .centerInSuperview()
        }
    }
}
#endif
