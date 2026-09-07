#if os(Linux)
#if UIKITPLUS_GTK_BACKEND && UIKITPLUS_QT_BACKEND
#error("UIKitPlus Linux backend traits UIKitPlusGTK and UIKitPlusQt are mutually conflicting; select exactly one.")
#elseif UIKITPLUS_GTK_BACKEND
public import UIKitPlusGTK
#elseif UIKITPLUS_QT_BACKEND
public import UIKitPlusQt
#else
#error("UIKitPlus Linux requires explicit SwiftPM trait selection: UIKitPlusGTK or UIKitPlusQt.")
#endif
#elseif os(Windows)
public import UIKitPlusWinUI
#endif
