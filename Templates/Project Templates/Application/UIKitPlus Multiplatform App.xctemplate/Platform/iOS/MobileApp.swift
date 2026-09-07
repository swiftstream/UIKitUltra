#if os(macOS) || os(iOS) || os(tvOS)
//___FILEHEADER___

#if !os(macOS)

import UIKitPlus

@main
final class App: BaseApp {
    @AppBuilder override var body: AppBuilderContent {
        MainScene(.main).mainScreen {
            MainViewController()
        }
    }
}

#endif
#endif
