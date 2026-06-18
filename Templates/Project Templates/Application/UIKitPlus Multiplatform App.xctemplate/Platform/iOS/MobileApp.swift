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
