#if os(Linux) && ULTRA_GTK_BACKEND

import Glibc
import UltraGTK

@MainActor
open class App {
    public required init() {}

    @AppBuilder
    open var body: AppBuilderContent { Window() }

    nonisolated public class func main() {
        MainActor.preconditionIsolated()
        MainActor.assumeIsolated {
            let app = Self.init()
            let status = app.run()
            if status != 0 {
                exit(status)
            }
        }
    }

    private var activeApplication: GTKApplication?
    private var retainedWindow: Window?

    package func run() -> Int32 {
        let application = GTKApplication()
        activeApplication = application
        _ = application.onActivate { [weak self] application in
            guard let self else { return }
            let windows = self.body.appBuilderContent._windows()
            precondition(
                windows.count <= 1,
                "Ultra GTK supports exactly one effective Window"
            )
            guard let window = windows.first else { return }

            self.retainedWindow = window
            let nativeWindow = application.makeWindow()
            window._installGTKHierarchy(
                into: nativeWindow,
                runtime: application.runtime
            )
            nativeWindow.present()
        }

        let status = application.run()
        retainedWindow?._teardownGTKHierarchy()
        retainedWindow = nil
        activeApplication = nil
        return status
    }

    package func _quit() {
        activeApplication?.quit()
    }
}

#endif
