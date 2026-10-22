import Foundation

public final class RayGramSettings {
    public static let didChangeNotification = Notification.Name("RayGramSettingsDidChangeNotification")
    
    private static let defaults: UserDefaults = {
        return UserDefaults.standard
    }()
    
    private enum Keys {
        static let ghostReadMessages = "RayGram_ghostReadMessages"
        static let ghostReadStories = "RayGram_ghostReadStories"
        static let ghostTyping = "RayGram_ghostTyping"
        
        static let antiRecall = "RayGram_antiRecall"
        static let markDeletedMessages = "RayGram_markDeletedMessages"
        static let saveExpiringMedia = "RayGram_saveExpiringMedia"
        
        static let bypassNoForwards = "RayGram_bypassNoForwards"
        
        static let blockSponsoredMessages = "RayGram_blockSponsoredMessages"
        static let disableSimilarChannels = "RayGram_disableSimilarChannels"
        static let disableJumpToNextChannel = "RayGram_disableJumpToNextChannel"
        
        static let confirmCalls = "RayGram_confirmCalls"
        static let showSeconds = "RayGram_showSeconds"
    }
    
    private static func getBool(key: String, defaultValue: Bool) -> Bool {
        if defaults.object(forKey: key) == nil {
            return defaultValue
        }
        return defaults.bool(forKey: key)
    }
    
    private static func setBool(key: String, value: Bool) {
        defaults.set(value, forKey: key)
        NotificationCenter.default.post(name: didChangeNotification, object: nil)
    }
    
    public static var ghostReadMessages: Bool {
        get { return getBool(key: Keys.ghostReadMessages, defaultValue: false) }
        set { setBool(key: Keys.ghostReadMessages, value: newValue) }
    }
    
    public static var ghostReadStories: Bool {
        get { return getBool(key: Keys.ghostReadStories, defaultValue: false) }
        set { setBool(key: Keys.ghostReadStories, value: newValue) }
    }
    
    public static var ghostTyping: Bool {
        get { return getBool(key: Keys.ghostTyping, defaultValue: false) }
        set { setBool(key: Keys.ghostTyping, value: newValue) }
    }
    
    public static var antiRecall: Bool {
        get { return getBool(key: Keys.antiRecall, defaultValue: true) }
        set { setBool(key: Keys.antiRecall, value: newValue) }
    }
    
    public static var markDeletedMessages: Bool {
        get { return getBool(key: Keys.markDeletedMessages, defaultValue: true) }
        set { setBool(key: Keys.markDeletedMessages, value: newValue) }
    }
    
    public static var saveExpiringMedia: Bool {
        get { return getBool(key: Keys.saveExpiringMedia, defaultValue: true) }
        set { setBool(key: Keys.saveExpiringMedia, value: newValue) }
    }
    
    public static var bypassNoForwards: Bool {
        get { return getBool(key: Keys.bypassNoForwards, defaultValue: true) }
        set { setBool(key: Keys.bypassNoForwards, value: newValue) }
    }
    
    public static var blockSponsoredMessages: Bool {
        get { return getBool(key: Keys.blockSponsoredMessages, defaultValue: true) }
        set { setBool(key: Keys.blockSponsoredMessages, value: newValue) }
    }
    
    public static var disableSimilarChannels: Bool {
        get { return getBool(key: Keys.disableSimilarChannels, defaultValue: true) }
        set { setBool(key: Keys.disableSimilarChannels, value: newValue) }
    }
    
    public static var disableJumpToNextChannel: Bool {
        get { return getBool(key: Keys.disableJumpToNextChannel, defaultValue: false) }
        set { setBool(key: Keys.disableJumpToNextChannel, value: newValue) }
    }
    
    public static var confirmCalls: Bool {
        get { return getBool(key: Keys.confirmCalls, defaultValue: true) }
        set { setBool(key: Keys.confirmCalls, value: newValue) }
    }
    
    public static var showSeconds: Bool {
        get { return getBool(key: Keys.showSeconds, defaultValue: false) }
        set { setBool(key: Keys.showSeconds, value: newValue) }
    }
}
