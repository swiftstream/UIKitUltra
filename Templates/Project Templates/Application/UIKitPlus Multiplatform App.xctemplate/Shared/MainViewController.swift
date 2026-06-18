//___FILEHEADER___

import UIKitPlus

final class MainViewController: ViewController {
    override func buildUI() {
        super.buildUI()

        #if !os(macOS)
        view.backgroundColor = .white
        #endif

        body {
            #if os(macOS)
            UText("UIKitPlus for macOS")
                .centerInSuperview()
            #else
            UText("UIKitPlus for iOS")
                .color(.black)
                .centerInSuperview()
            #endif
        }
    }
}
