#if os(macOS) || os(iOS) || os(tvOS)
//___FILEHEADER___

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
