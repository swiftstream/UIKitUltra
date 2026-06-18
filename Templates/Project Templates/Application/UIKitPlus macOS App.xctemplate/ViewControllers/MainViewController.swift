//___FILEHEADER___

import UIKitPlus

final class MainViewController: ViewController {
    override func buildUI() {
        super.buildUI()

        body {
            UText("UIKitPlus for macOS")
                .centerInSuperview()
        }
    }
}
