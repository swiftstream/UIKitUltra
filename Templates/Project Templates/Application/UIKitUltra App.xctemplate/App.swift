#if os(macOS) || os(iOS) || os(tvOS)
//___FILEHEADER___

import Ultra

@main
final class App: BaseApp {
    @AppBuilder override var body: AppBuilderContent {
        MainScene(.main).mainScreen {
            MainViewController()
        }
    }
}
#endif
