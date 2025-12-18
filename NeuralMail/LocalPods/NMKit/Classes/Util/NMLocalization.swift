import Foundation
import NMModular

public extension String {

    /// Returns the localized string for the current language in the specified bundle.
    func localized(in bundle: Bundle = .main) -> String {
        return localizedString(forKey: self, outputBundle: bundle)
    }
    
    /// Returns the localized string with arguments.
    func localized(with arguments: CVarArg..., in bundle: Bundle = .main) -> String {
        let format = self.localized(in: bundle)
        return String(format: format, arguments: arguments)
    }
    
    func localizedString(forKey key: String, outputBundle: Bundle = .main) -> String {

        var code = NMLanguage.english.rawValue
        
        if let prefService = NMServiceContainer.shared.resolve(NMPreferenceService.self) {
            code = prefService.language.rawValue
        }
        
        if code == NMLanguage.system.rawValue {
            let preferred = Bundle.preferredLocalizations(from: outputBundle.localizations, forPreferences: Locale.preferredLanguages)
            code = preferred.first ?? NMLanguage.english.rawValue
        }
        
        if let path = outputBundle.path(forResource: code, ofType: "lproj"),
           let localizedBundle = Bundle(path: path) {
            return localizedBundle.localizedString(forKey: key, value: nil, table: nil)
        }
        
        return outputBundle.localizedString(forKey: key, value: nil, table: nil)
    }
}

public extension URL {

    static func urlForResource(name:String,ext:String, in bundle: Bundle = .main) -> URL? {

        return bundle.url(forResource: name, withExtension: ext)
    }
    
    func localizedString(forKey key: String, outputBundle: Bundle = .main) -> String {

        var code = NMLanguage.english.rawValue
        
        if let prefService = NMServiceContainer.shared.resolve(NMPreferenceService.self) {
            code = prefService.language.rawValue
        }
        
        if code == NMLanguage.system.rawValue {
            let preferred = Bundle.preferredLocalizations(from: outputBundle.localizations, forPreferences: Locale.preferredLanguages)
            code = preferred.first ?? NMLanguage.english.rawValue
        }
        
        if let path = outputBundle.path(forResource: code, ofType: "lproj"),
           let localizedBundle = Bundle(path: path) {
            return localizedBundle.localizedString(forKey: key, value: nil, table: nil)
        }
        
        return outputBundle.localizedString(forKey: key, value: nil, table: nil)
    }
}

public protocol NMLocalizable: AnyObject {
    /// Implement this method to set localized text for UI elements.
    /// This will be called on viewDidLoad and whenever the language changes.
    func setupLocalizedStrings()
}
