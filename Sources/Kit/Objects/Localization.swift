#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

private let localization = Localization()

/// Mutable language selection is protected by `lock`; the class is final and
/// all stored state outside the lock is immutable after initialization.
public final class Localization: @unchecked Sendable {
    private let lock = NSLock()

    let currentLocaleIdentifier: String
    private var defaultLanguage: Language = .en
    private var currentLanguage: Language?

    init() {
        currentLocaleIdentifier = Locale.preferredLanguages.first ?? Locale.current.identifier
    }

    func detectCurrentLanguage() -> Language {
        lock.withLock {
            Self.detectLanguage(
                localeIdentifier: currentLocaleIdentifier,
                defaultLanguage: defaultLanguage
            )
        }
    }

    private static func detectLanguage(
        localeIdentifier: String,
        defaultLanguage: Language
    ) -> Language {
        if let language = Language(rawValue: localeIdentifier) {
            return language
        }
        if let locale = localeIdentifier.components(separatedBy: "_").first {
            if let language = Language(rawValue: locale) {
                return language
            } else if let locale = locale.components(separatedBy: "-").first, let language = Language(rawValue: locale) {
                return language
            }
        }
        
        return defaultLanguage
    }
    
    static var shared: Localization {
        return localization
    }
    
    public static var current: Language {
        get {
            shared.lock.withLock {
                if let currentLanguage = shared.currentLanguage {
                    return currentLanguage
                }
                let detectedLanguage = Self.detectLanguage(
                    localeIdentifier: shared.currentLocaleIdentifier,
                    defaultLanguage: shared.defaultLanguage
                )
                shared.currentLanguage = detectedLanguage
                return detectedLanguage
            }
        }
        set {
            shared.lock.withLock {
                shared.currentLanguage = newValue
            }
        }
    }
    
    public static var `default`: Language {
        get {
            shared.lock.withLock {
                shared.defaultLanguage
            }
        }
        set {
            shared.lock.withLock {
                shared.defaultLanguage = newValue
            }
        }
    }
}
#endif
