#if os(macOS) || os(iOS) || os(tvOS)
//___FILEHEADER___

import Ultra

final class MainViewController: ViewController {
    override func buildUI() {
        super.buildUI()
        view.backgroundColor = .white

        body {
            UText("UIKitUltra")
                .color(.black)
                .centerInSuperview()
        }
    }
}
#endif
