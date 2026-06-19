//___FILEHEADER___

#if os(macOS)

import UIKitPlus

@main
final class App: UIKitPlus.App {
    private lazy var shellWindow = Window {
        MainViewController()
    }

    @AppBuilder override var body: AppBuilderContent {
        shellWindow
            .title("___PACKAGENAME___")
            .size(900, 600)
            .minSize(.init(width: 640, height: 420))
            .center()
            .makeKeyAndOrderFront()
    }
}

#endif
