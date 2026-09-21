#if os(Linux)
#if ULTRA_GTK_BACKEND && ULTRA_QT_BACKEND
#error("UIKitUltra Linux backend traits UltraGTK and UltraQt are mutually conflicting; select exactly one.")
#elseif ULTRA_GTK_BACKEND
import UltraGTK
#elseif ULTRA_QT_BACKEND
import UltraQtRuntime
#else
#error("UIKitUltra Linux requires explicit SwiftPM trait selection: UltraGTK or UltraQt.")
#endif
#elseif os(Windows)
import UltraWinRuntime
#endif
