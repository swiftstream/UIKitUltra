#if os(macOS) || os(iOS) || os(tvOS)
//___FILEHEADER___

import Ultra

final class MainViewController: ViewController {
    override func buildUI() {
        super.buildUI()

        body {
            UText("UIKitUltra for macOS")
                .centerInSuperview()
        }
    }
}
#endif
