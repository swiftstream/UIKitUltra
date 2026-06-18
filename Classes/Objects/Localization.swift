import Foundation

private let localization = Localization()

public class Localization: @unchecked Sendable {
    let currentLocaleIdentifier = Locale.preferredLanguages.first ?? Locale.current.identifier
    
    var defaultLanguage: Language = .en
    
    lazy var currentLanguage: Language = detectCurrentLanguage()
    
    func detectCurrentLanguage() -> Language {
        if let language = Language(rawValue: currentLocaleIdentifier) {
            return language
        }
        if let locale = currentLocaleIdentifier.components(separatedBy: "_").first {
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
        get { shared.currentLanguage }
        set { shared.currentLanguage = newValue }
    }
    
    public static var `default`: Language {
        get { shared.defaultLanguage }
        set { shared.defaultLanguage = newValue }
    }
}
