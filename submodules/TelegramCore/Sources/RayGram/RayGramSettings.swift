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
        static let antiScreenshot = "RayGram_antiScreenshot"
        
        static let blockSponsoredMessages = "RayGram_blockSponsoredMessages"
        static let disableSimilarChannels = "RayGram_disableSimilarChannels"
        static let disableJumpToNextChannel = "RayGram_disableJumpToNextChannel"
        
        static let confirmCalls = "RayGram_confirmCalls"
        static let showSeconds = "RayGram_showSeconds"
        
        static let enableFakeGifts = "RayGram_enableFakeGifts"
        
        static let showUserId = "RayGram_showUserId"
        static let showAccountAge = "RayGram_showAccountAge"
        static let liquidGlassProfile = "RayGram_liquidGlassProfile"
        
        static let localPremium = "RayGram_localPremium"
        static let localSpeechToText = "RayGram_localSpeechToText"
        static let unlockStoryFeatures = "RayGram_unlockStoryFeatures"
        
        static let amoledMode = "RayGram_amoledMode"
        static let customFont = "RayGram_customFont"
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
    
    public static var antiScreenshot: Bool {
        get { return getBool(key: Keys.antiScreenshot, defaultValue: true) }
        set { setBool(key: Keys.antiScreenshot, value: newValue) }
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
    
    public static var localPremium: Bool {
        get { return getBool(key: Keys.localPremium, defaultValue: true) }
        set { setBool(key: Keys.localPremium, value: newValue) }
    }
    
    public static var localSpeechToText: Bool {
        get { return getBool(key: Keys.localSpeechToText, defaultValue: true) }
        set { setBool(key: Keys.localSpeechToText, value: newValue) }
    }
    
    public static var unlockStoryFeatures: Bool {
        get { return getBool(key: Keys.unlockStoryFeatures, defaultValue: true) }
        set { setBool(key: Keys.unlockStoryFeatures, value: newValue) }
    }
    
    public static var amoledMode: Bool {
        get { return getBool(key: Keys.amoledMode, defaultValue: false) }
        set { setBool(key: Keys.amoledMode, value: newValue) }
    }
    
    public static var customFont: String? {
        get { return defaults.string(forKey: Keys.customFont) }
        set {
            if let value = newValue {
                defaults.set(value, forKey: Keys.customFont)
            } else {
                defaults.removeObject(forKey: Keys.customFont)
            }
            NotificationCenter.default.post(name: didChangeNotification, object: nil)
        }
    }
    
    private static let peerIdsLock = NSLock()
    private static var registeredAccountPeerIds: Set<Int64> = {
        if let array = defaults.array(forKey: "RayGram_accountPeerIds") as? [Int64] {
            return Set(array)
        }
        return []
    }()
    
    public static func registerAccountPeerId(_ peerId: PeerId) {
        peerIdsLock.lock()
        let val = peerId.id._internalGetInt64Value()
        if !registeredAccountPeerIds.contains(val) {
            registeredAccountPeerIds.insert(val)
            defaults.set(Array(registeredAccountPeerIds), forKey: "RayGram_accountPeerIds")
        }
        peerIdsLock.unlock()
    }
    
    public static func isAccountPeerId(_ peerId: PeerId) -> Bool {
        peerIdsLock.lock()
        defer { peerIdsLock.unlock() }
        return registeredAccountPeerIds.contains(peerId.id._internalGetInt64Value())
    }
    
    private static var customEmojiStatuses: [Int64: Int64] = {
        if let dict = defaults.dictionary(forKey: "RayGram_customEmojiStatuses") as? [String: NSNumber] {
            var result: [Int64: Int64] = [:]
            for (k, v) in dict {
                if let peerIdInt = Int64(k) {
                    result[peerIdInt] = v.int64Value
                }
            }
            return result
        }
        return [:]
    }()
    
    private static var customEmojiStatusesData: [Int64: Data] = {
        if let dict = defaults.dictionary(forKey: "RayGram_customEmojiStatusesData") as? [String: Data] {
            var result: [Int64: Data] = [:]
            for (k, v) in dict {
                if let peerIdInt = Int64(k) {
                    result[peerIdInt] = v
                }
            }
            return result
        }
        return [:]
    }()
    
    private static var customNameColors: [Int64: Int32] = {
        if let dict = defaults.dictionary(forKey: "RayGram_customNameColors") as? [String: NSNumber] {
            var result: [Int64: Int32] = [:]
            for (k, v) in dict {
                if let peerIdInt = Int64(k) {
                    result[peerIdInt] = v.int32Value
                }
            }
            return result
        }
        return [:]
    }()
    
    private static var customBackgroundEmojiIds: [Int64: Int64] = {
        if let dict = defaults.dictionary(forKey: "RayGram_customBackgroundEmojiIds") as? [String: NSNumber] {
            var result: [Int64: Int64] = [:]
            for (k, v) in dict {
                if let peerIdInt = Int64(k) {
                    result[peerIdInt] = v.int64Value
                }
            }
            return result
        }
        return [:]
    }()
    
    private static var customProfileColors: [Int64: Int32] = {
        if let dict = defaults.dictionary(forKey: "RayGram_customProfileColors") as? [String: NSNumber] {
            var result: [Int64: Int32] = [:]
            for (k, v) in dict {
                if let peerIdInt = Int64(k) {
                    result[peerIdInt] = v.int32Value
                }
            }
            return result
        }
        return [:]
    }()
    
    private static var customProfileBackgroundEmojiIds: [Int64: Int64] = {
        if let dict = defaults.dictionary(forKey: "RayGram_customProfileBackgroundEmojiIds") as? [String: NSNumber] {
            var result: [Int64: Int64] = [:]
            for (k, v) in dict {
                if let peerIdInt = Int64(k) {
                    result[peerIdInt] = v.int64Value
                }
            }
            return result
        }
        return [:]
    }()
    
    public enum GhostModeOverride: Int, Codable {
        case `default` = 0
        case enabled = 1
        case disabled = 2
    }
    
    private static var ghostOverrides: [Int64: Int] = {
        if let dict = defaults.dictionary(forKey: "RayGram_ghostOverrides") as? [String: NSNumber] {
            var result: [Int64: Int] = [:]
            for (k, v) in dict {
                if let peerIdInt = Int64(k) {
                    result[peerIdInt] = v.intValue
                }
            }
            return result
        }
        return [:]
    }()
    
    public static func ghostOverride(for peerId: PeerId) -> GhostModeOverride {
        peerIdsLock.lock()
        defer { peerIdsLock.unlock() }
        let rawId = peerId.id._internalGetInt64Value()
        if let raw = ghostOverrides[rawId], let override = GhostModeOverride(rawValue: raw) {
            return override
        }
        return .default
    }
    
    public static func setGhostOverride(_ override: GhostModeOverride, for peerId: PeerId) {
        peerIdsLock.lock()
        let rawId = peerId.id._internalGetInt64Value()
        if override == .default {
            ghostOverrides.removeValue(forKey: rawId)
        } else {
            ghostOverrides[rawId] = override.rawValue
        }
        var dict: [String: NSNumber] = [:]
        for (k, v) in ghostOverrides {
            dict[String(k)] = NSNumber(value: v)
        }
        defaults.set(dict, forKey: "RayGram_ghostOverrides")
        peerIdsLock.unlock()
        NotificationCenter.default.post(name: didChangeNotification, object: nil)
    }
    
    public static func isGhostReadMessages(for peerId: PeerId) -> Bool {
        switch ghostOverride(for: peerId) {
        case .enabled:
            return true
        case .disabled:
            return false
        case .default:
            return ghostReadMessages
        }
    }
    
    public static func isGhostTyping(for peerId: PeerId) -> Bool {
        switch ghostOverride(for: peerId) {
        case .enabled:
            return true
        case .disabled:
            return false
        case .default:
            return ghostTyping
        }
    }
    
    public static func customEmojiStatusFileId(for peerId: PeerId) -> Int64? {
        peerIdsLock.lock()
        defer { peerIdsLock.unlock() }
        return customEmojiStatuses[peerId.id._internalGetInt64Value()]
    }
    
    public static func setCustomEmojiStatusFileId(_ fileId: Int64?, for peerId: PeerId) {
        peerIdsLock.lock()
        let val = peerId.id._internalGetInt64Value()
        if let fileId = fileId {
            customEmojiStatuses[val] = fileId
            let status = PeerEmojiStatus(content: .emoji(fileId: fileId), expirationDate: nil)
            if let data = try? JSONEncoder().encode(status) {
                customEmojiStatusesData[val] = data
            }
        } else {
            customEmojiStatuses.removeValue(forKey: val)
            customEmojiStatusesData.removeValue(forKey: val)
        }
        var dict: [String: NSNumber] = [:]
        for (k, v) in customEmojiStatuses {
            dict[String(k)] = NSNumber(value: v)
        }
        defaults.set(dict, forKey: "RayGram_customEmojiStatuses")
        
        var dataDict: [String: Data] = [:]
        for (k, v) in customEmojiStatusesData {
            dataDict[String(k)] = v
        }
        defaults.set(dataDict, forKey: "RayGram_customEmojiStatusesData")
        peerIdsLock.unlock()
    }
    
    public static func persistEmojiStatus(_ emojiStatus: PeerEmojiStatus?, for peerId: PeerId) {
        peerIdsLock.lock()
        let val = peerId.id._internalGetInt64Value()
        if let emojiStatus = emojiStatus {
            if let data = try? JSONEncoder().encode(emojiStatus) {
                customEmojiStatusesData[val] = data
            }
            switch emojiStatus.content {
            case let .emoji(fileId):
                customEmojiStatuses[val] = fileId
            case let .starGift(_, fileId, _, _, _, _, _, _, _):
                customEmojiStatuses[val] = fileId
            }
        } else {
            customEmojiStatusesData.removeValue(forKey: val)
            customEmojiStatuses.removeValue(forKey: val)
        }
        var dataDict: [String: Data] = [:]
        for (k, v) in customEmojiStatusesData {
            dataDict[String(k)] = v
        }
        defaults.set(dataDict, forKey: "RayGram_customEmojiStatusesData")
        
        var dict: [String: NSNumber] = [:]
        for (k, v) in customEmojiStatuses {
            dict[String(k)] = NSNumber(value: v)
        }
        defaults.set(dict, forKey: "RayGram_customEmojiStatuses")
        peerIdsLock.unlock()
        NotificationCenter.default.post(name: didChangeNotification, object: nil)
    }
    
    public static func resolveEmojiStatus(forRawId rawId: Int64, server: PeerEmojiStatus?) -> PeerEmojiStatus? {
        peerIdsLock.lock()
        defer { peerIdsLock.unlock() }
        if let data = customEmojiStatusesData[rawId], let status = try? JSONDecoder().decode(PeerEmojiStatus.self, from: data) {
            return status
        }
        if let fileId = customEmojiStatuses[rawId] {
            return PeerEmojiStatus(content: .emoji(fileId: fileId), expirationDate: nil)
        }
        return server
    }
    
    public static func persistAppearance(nameColor: PeerColor?, backgroundEmojiId: Int64?, profileColor: PeerNameColor?, profileBackgroundEmojiId: Int64?, for peerId: PeerId) {
        peerIdsLock.lock()
        let val = peerId.id._internalGetInt64Value()
        
        if let nameColor = nameColor {
            switch nameColor {
            case let .preset(preset):
                customNameColors[val] = preset.rawValue
            case .collectible:
                break
            }
        } else {
            customNameColors.removeValue(forKey: val)
        }
        var nameDict: [String: NSNumber] = [:]
        for (k, v) in customNameColors {
            nameDict[String(k)] = NSNumber(value: v)
        }
        defaults.set(nameDict, forKey: "RayGram_customNameColors")
        
        if let bgId = backgroundEmojiId {
            customBackgroundEmojiIds[val] = bgId
        } else {
            customBackgroundEmojiIds.removeValue(forKey: val)
        }
        var bgDict: [String: NSNumber] = [:]
        for (k, v) in customBackgroundEmojiIds {
            bgDict[String(k)] = NSNumber(value: v)
        }
        defaults.set(bgDict, forKey: "RayGram_customBackgroundEmojiIds")
        
        if let profColor = profileColor {
            customProfileColors[val] = profColor.rawValue
        } else {
            customProfileColors.removeValue(forKey: val)
        }
        var profDict: [String: NSNumber] = [:]
        for (k, v) in customProfileColors {
            profDict[String(k)] = NSNumber(value: v)
        }
        defaults.set(profDict, forKey: "RayGram_customProfileColors")
        
        if let profBgId = profileBackgroundEmojiId {
            customProfileBackgroundEmojiIds[val] = profBgId
        } else {
            customProfileBackgroundEmojiIds.removeValue(forKey: val)
        }
        var profBgDict: [String: NSNumber] = [:]
        for (k, v) in customProfileBackgroundEmojiIds {
            profBgDict[String(k)] = NSNumber(value: v)
        }
        defaults.set(profBgDict, forKey: "RayGram_customProfileBackgroundEmojiIds")
        
        peerIdsLock.unlock()
        NotificationCenter.default.post(name: didChangeNotification, object: nil)
    }
    
    public static func resolveNameColor(forRawId rawId: Int64, server: PeerColor?) -> PeerColor? {
        peerIdsLock.lock()
        defer { peerIdsLock.unlock() }
        if let raw = customNameColors[rawId] {
            return .preset(PeerNameColor(rawValue: raw))
        }
        return server
    }
    
    public static func resolveProfileColor(forRawId rawId: Int64, server: PeerNameColor?) -> PeerNameColor? {
        peerIdsLock.lock()
        defer { peerIdsLock.unlock() }
        if let raw = customProfileColors[rawId] {
            return PeerNameColor(rawValue: raw)
        }
        return server
    }
    
    public static func resolveBackgroundEmojiId(forRawId rawId: Int64, server: Int64?) -> Int64? {
        peerIdsLock.lock()
        defer { peerIdsLock.unlock() }
        if let custom = customBackgroundEmojiIds[rawId] {
            return custom
        }
        return server
    }
    
    public static func resolveProfileBackgroundEmojiId(forRawId rawId: Int64, server: Int64?) -> Int64? {
        peerIdsLock.lock()
        defer { peerIdsLock.unlock() }
        if let custom = customProfileBackgroundEmojiIds[rawId] {
            return custom
        }
        return server
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
