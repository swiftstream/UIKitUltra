#if os(macOS) || os(iOS) || os(tvOS)
//___FILEHEADER___

import Ultra

final class MainViewController: ViewController {
    override func buildUI() {
        super.buildUI()

        #if !os(macOS)
        view.backgroundColor = .white
        #endif

        body {
            #if os(macOS)
            UText("UIKitUltra for macOS")
                .centerInSuperview()
            #else
            UText("UIKitUltra for iOS")
                .color(.black)
                .centerInSuperview()
            #endif
        }
    }
}
#endif
