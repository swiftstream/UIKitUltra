#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

extension NSSound {
    public static let basso = NSSound(named: .basso)
    public static let blow = NSSound(named: .blow)
    public static let bottle = NSSound(named: .bottle)
    public static let frog = NSSound(named: .frog)
    public static let funk = NSSound(named: .funk)
    public static let glass = NSSound(named: .glass)
    public static let hero = NSSound(named: .hero)
    public static let morse = NSSound(named: .morse)
    public static let ping = NSSound(named: .ping)
    public static let pop = NSSound(named: .pop)
    public static let purr = NSSound(named: .purr)
    public static let sosumi = NSSound(named: .sosumi)
    public static let submarine = NSSound(named: .submarine)
    public static let tink = NSSound(named: .tink)
}

extension NSSound.Name {
    public static let basso = NSSound.Name("Basso")
    public static let blow = NSSound.Name("Blow")
    public static let bottle = NSSound.Name("Bottle")
    public static let frog = NSSound.Name("Frog")
    public static let funk = NSSound.Name("Funk")
    public static let glass = NSSound.Name("Glass")
    public static let hero = NSSound.Name("Hero")
    public static let morse = NSSound.Name("Morse")
    public static let ping = NSSound.Name("Ping")
    public static let pop = NSSound.Name("Pop")
    public static let purr = NSSound.Name("Purr")
    public static let sosumi = NSSound.Name("Sosumi")
    public static let submarine = NSSound.Name("Submarine")
    public static let tink = NSSound.Name("Tink")
}
#endif
#endif
