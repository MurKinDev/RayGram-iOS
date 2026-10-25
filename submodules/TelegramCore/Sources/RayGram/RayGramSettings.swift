import Foundation
import Postbox

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
        static let bypassSensitiveContent = "RayGram_bypassSensitiveContent"
        
        static let blockSponsoredMessages = "RayGram_blockSponsoredMessages"
        static let disableSimilarChannels = "RayGram_disableSimilarChannels"
        static let disableJumpToNextChannel = "RayGram_disableJumpToNextChannel"
        
        static let confirmCalls = "RayGram_confirmCalls"
        static let showSeconds = "RayGram_showSeconds"
        
        static let enableFakeGifts = "RayGram_enableFakeGifts"
        
        static let showUserId = "RayGram_showUserId"
        static let showAccountAge = "RayGram_showAccountAge"
        static let liquidGlassProfile = "RayGram_liquidGlassProfile"
    }
    
    public static var hasFullAccess: Bool {
        get {
            return true
        }
        set {
        }
    }
    
    public static func recordVerification(hasAccess: Bool) {
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
        get { return getBool(key: Keys.ghostOnline, defaultValue: false) }
        set { setBool(key: Keys.ghostOnline, value: newValue) }
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
        return true
    }
    
    public static var saveExpiringMedia: Bool {
        get { return getBool(key: Keys.saveExpiringMedia, defaultValue: true) }
        set { setBool(key: Keys.saveExpiringMedia, value: newValue) }
    }
    
    public static var saveEditHistory: Bool {
        get { return getBool(key: Keys.saveEditHistory, defaultValue: true) }
        set { setBool(key: Keys.saveEditHistory, value: newValue) }
    }
    
    public static var bypassNoForwards: Bool {
        get { return getBool(key: Keys.bypassNoForwards, defaultValue: true) }
        set { setBool(key: Keys.bypassNoForwards, value: newValue) }
    }
    
    public static var bypassSensitiveContent: Bool {
        get { return getBool(key: Keys.bypassSensitiveContent, defaultValue: true) }
        set { setBool(key: Keys.bypassSensitiveContent, value: newValue) }
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
    
    public static var enableFakeGifts: Bool {
        get { return getBool(key: Keys.enableFakeGifts, defaultValue: true) }
        set { setBool(key: Keys.enableFakeGifts, value: newValue) }
    }
    
    public static var showUserId: Bool {
        get { return getBool(key: Keys.showUserId, defaultValue: true) }
        set { setBool(key: Keys.showUserId, value: newValue) }
    }
    
    public static var showAccountAge: Bool {
        get { return getBool(key: Keys.showAccountAge, defaultValue: true) }
        set { setBool(key: Keys.showAccountAge, value: newValue) }
    }
    
    public static var liquidGlassProfile: Bool {
        get { return getBool(key: Keys.liquidGlassProfile, defaultValue: true) }
        set { setBool(key: Keys.liquidGlassProfile, value: newValue) }
    }
    
    public static let developerId: Int64 = 7313341262
    public static let developerUsernames: Set<String> = ["murkindev"]
    
    public static func isDeveloper(peerId: PeerId?) -> Bool {
        guard let peerId = peerId else { return false }
        return peerId.id._internalGetInt64Value() == developerId
    }
    
    public static func isDeveloper(peer: Peer?) -> Bool {
        guard let peer = peer else { return false }
        if peer.id.id._internalGetInt64Value() == developerId {
            return true
        }
        if let user = peer as? TelegramUser {
            if let username = user.username, developerUsernames.contains(username.lowercased()) {
                return true
            }
            for u in user.usernames {
                if developerUsernames.contains(u.username.lowercased()) {
                    return true
                }
            }
        }
        return false
    }
    
    public static func isDeveloper(enginePeer: EnginePeer?) -> Bool {
        guard let enginePeer = enginePeer else { return false }
        if enginePeer.id.id._internalGetInt64Value() == developerId {
            return true
        }
        if let addressName = enginePeer.addressName, developerUsernames.contains(addressName.lowercased()) {
            return true
        }
        for u in enginePeer.usernames {
            if developerUsernames.contains(u.username.lowercased()) {
                return true
            }
        }
        switch enginePeer {
        case let .user(user):
            return isDeveloper(peer: user)
        default:
            return false
        }
    }
}
