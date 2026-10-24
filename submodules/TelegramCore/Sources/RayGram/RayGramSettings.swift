import Foundation

public final class RayGramSettings {
    public static let didChangeNotification = Notification.Name("RayGramSettingsDidChangeNotification")
    public static let didSendMessageNotification = Notification.Name("RayGramDidSendMessageNotification")
    
    private static let defaults: UserDefaults = {
        return UserDefaults.standard
    }()
    
    private enum Keys {
        static let ghostOnline = "RayGram_ghostOnline"
        static let ghostReadMessages = "RayGram_ghostReadMessages"
        static let ghostReadStories = "RayGram_ghostReadStories"
        static let ghostTyping = "RayGram_ghostTyping"
        
        static let antiRecall = "RayGram_antiRecall"
        static let markDeletedMessages = "RayGram_markDeletedMessages"
        static let saveExpiringMedia = "RayGram_saveExpiringMedia"
        static let saveEditHistory = "RayGram_saveEditHistory"
        
        static let bypassNoForwards = "RayGram_bypassNoForwards"
        
        static let blockSponsoredMessages = "RayGram_blockSponsoredMessages"
        static let disableSimilarChannels = "RayGram_disableSimilarChannels"
        static let disableJumpToNextChannel = "RayGram_disableJumpToNextChannel"
        
        static let confirmCalls = "RayGram_confirmCalls"
        static let showSeconds = "RayGram_showSeconds"
        
        static let enableFakeGifts = "RayGram_enableFakeGifts"
        
        static let hasFullAccess = "RayGram_hasFullAccess"
        static let lastVerifiedTimestamp = "RayGram_lastVerifiedTimestamp"
    }
    
    public static var hasFullAccess: Bool {
        get {
            let access = getBool(key: Keys.hasFullAccess, defaultValue: false)
            if !access {
                return false
            }
            let lastVerified = defaults.double(forKey: Keys.lastVerifiedTimestamp)
            if lastVerified > 0 {
                let elapsed = Date().timeIntervalSince1970 - lastVerified
                // 3 days grace period (3 * 24 * 3600 = 259200 seconds)
                if elapsed > 259200 {
                    return false
                }
            }
            return true
        }
        set {
            setBool(key: Keys.hasFullAccess, value: newValue)
            if newValue {
                defaults.set(Date().timeIntervalSince1970, forKey: Keys.lastVerifiedTimestamp)
            }
        }
    }
    
    public static func recordVerification(hasAccess: Bool) {
        defaults.set(hasAccess, forKey: Keys.hasFullAccess)
        if hasAccess {
            defaults.set(Date().timeIntervalSince1970, forKey: Keys.lastVerifiedTimestamp)
        }
        NotificationCenter.default.post(name: didChangeNotification, object: nil)
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
    
    public static var ghostOnline: Bool {
        get { return hasFullAccess && getBool(key: Keys.ghostOnline, defaultValue: false) }
        set { setBool(key: Keys.ghostOnline, value: newValue) }
    }
    
    public static var ghostReadMessages: Bool {
        get { return hasFullAccess && getBool(key: Keys.ghostReadMessages, defaultValue: false) }
        set { setBool(key: Keys.ghostReadMessages, value: newValue) }
    }
    
    public static var ghostReadStories: Bool {
        get { return hasFullAccess && getBool(key: Keys.ghostReadStories, defaultValue: false) }
        set { setBool(key: Keys.ghostReadStories, value: newValue) }
    }
    
    public static var ghostTyping: Bool {
        get { return hasFullAccess && getBool(key: Keys.ghostTyping, defaultValue: false) }
        set { setBool(key: Keys.ghostTyping, value: newValue) }
    }
    
    public static var antiRecall: Bool {
        get { return hasFullAccess && getBool(key: Keys.antiRecall, defaultValue: true) }
        set { setBool(key: Keys.antiRecall, value: newValue) }
    }
    
    public static var markDeletedMessages: Bool {
        return true
    }
    
    public static var saveExpiringMedia: Bool {
        get { return hasFullAccess && getBool(key: Keys.saveExpiringMedia, defaultValue: true) }
        set { setBool(key: Keys.saveExpiringMedia, value: newValue) }
    }
    
    public static var saveEditHistory: Bool {
        get { return hasFullAccess && getBool(key: Keys.saveEditHistory, defaultValue: true) }
        set { setBool(key: Keys.saveEditHistory, value: newValue) }
    }
    
    public static var bypassNoForwards: Bool {
        get { return hasFullAccess && getBool(key: Keys.bypassNoForwards, defaultValue: true) }
        set { setBool(key: Keys.bypassNoForwards, value: newValue) }
    }
    
    public static var blockSponsoredMessages: Bool {
        get { return hasFullAccess && getBool(key: Keys.blockSponsoredMessages, defaultValue: true) }
        set { setBool(key: Keys.blockSponsoredMessages, value: newValue) }
    }
    
    public static var disableSimilarChannels: Bool {
        get { return hasFullAccess && getBool(key: Keys.disableSimilarChannels, defaultValue: true) }
        set { setBool(key: Keys.disableSimilarChannels, value: newValue) }
    }
    
    public static var disableJumpToNextChannel: Bool {
        get { return hasFullAccess && getBool(key: Keys.disableJumpToNextChannel, defaultValue: false) }
        set { setBool(key: Keys.disableJumpToNextChannel, value: newValue) }
    }
    
    public static var confirmCalls: Bool {
        get { return hasFullAccess && getBool(key: Keys.confirmCalls, defaultValue: true) }
        set { setBool(key: Keys.confirmCalls, value: newValue) }
    }
    
    public static var showSeconds: Bool {
        get { return hasFullAccess && getBool(key: Keys.showSeconds, defaultValue: false) }
        set { setBool(key: Keys.showSeconds, value: newValue) }
    }
    
    public static var enableFakeGifts: Bool {
        get { return hasFullAccess && getBool(key: Keys.enableFakeGifts, defaultValue: true) }
        set { setBool(key: Keys.enableFakeGifts, value: newValue) }
    }
}
