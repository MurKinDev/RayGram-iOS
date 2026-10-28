import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import TelegramUIPreferences
import ItemListUI
import PresentationDataUtils
import AccountContext

private final class RayGramSettingsControllerArguments {
    let updateGhostOnline: (Bool) -> Void
    let updateGhostReadMessages: (Bool) -> Void
    let updateGhostReadStories: (Bool) -> Void
    let updateGhostTyping: (Bool) -> Void
    
    let updateAntiRecall: (Bool) -> Void
    let updateSaveEditHistory: (Bool) -> Void
    let updateSaveExpiringMedia: (Bool) -> Void
    
    let updateBypassNoForwards: (Bool) -> Void
    let updateBypassSensitiveContent: (Bool) -> Void
    let updateAntiScreenshot: (Bool) -> Void
    
    let updateBlockSponsoredMessages: (Bool) -> Void
    let updateDisableSimilarChannels: (Bool) -> Void
    let updateDisableJumpToNextChannel: (Bool) -> Void
    
    let updateShowUserId: (Bool) -> Void
    let updateShowAccountAge: (Bool) -> Void
    let updateLiquidGlassProfile: (Bool) -> Void
    
    let updateConfirmCalls: (Bool) -> Void
    let updateShowSeconds: (Bool) -> Void
    let updateFakeGifts: (Bool) -> Void
    
    let updateLocalPremium: (Bool) -> Void
    let updateLocalSpeechToText: (Bool) -> Void
    let updateUnlockStoryFeatures: (Bool) -> Void
    
    let updateAmoledMode: (Bool) -> Void
    let openFontPicker: () -> Void
    
    init(
        updateGhostOnline: @escaping (Bool) -> Void,
        updateGhostReadMessages: @escaping (Bool) -> Void,
        updateGhostReadStories: @escaping (Bool) -> Void,
        updateGhostTyping: @escaping (Bool) -> Void,
        updateAntiRecall: @escaping (Bool) -> Void,
        updateSaveEditHistory: @escaping (Bool) -> Void,
        updateSaveExpiringMedia: @escaping (Bool) -> Void,
        updateBypassNoForwards: @escaping (Bool) -> Void,
        updateBypassSensitiveContent: @escaping (Bool) -> Void,
        updateAntiScreenshot: @escaping (Bool) -> Void,
        updateBlockSponsoredMessages: @escaping (Bool) -> Void,
        updateDisableSimilarChannels: @escaping (Bool) -> Void,
        updateDisableJumpToNextChannel: @escaping (Bool) -> Void,
        updateShowUserId: @escaping (Bool) -> Void,
        updateShowAccountAge: @escaping (Bool) -> Void,
        updateLiquidGlassProfile: @escaping (Bool) -> Void,
        updateConfirmCalls: @escaping (Bool) -> Void,
        updateShowSeconds: @escaping (Bool) -> Void,
        updateFakeGifts: @escaping (Bool) -> Void,
        updateLocalPremium: @escaping (Bool) -> Void,
        updateLocalSpeechToText: @escaping (Bool) -> Void,
        updateUnlockStoryFeatures: @escaping (Bool) -> Void,
        updateAmoledMode: @escaping (Bool) -> Void,
        openFontPicker: @escaping () -> Void
    ) {
        self.updateGhostOnline = updateGhostOnline
        self.updateGhostReadMessages = updateGhostReadMessages
        self.updateGhostReadStories = updateGhostReadStories
        self.updateGhostTyping = updateGhostTyping
        self.updateAntiRecall = updateAntiRecall
        self.updateSaveEditHistory = updateSaveEditHistory
        self.updateSaveExpiringMedia = updateSaveExpiringMedia
        self.updateBypassNoForwards = updateBypassNoForwards
        self.updateBypassSensitiveContent = updateBypassSensitiveContent
        self.updateAntiScreenshot = updateAntiScreenshot
        self.updateBlockSponsoredMessages = updateBlockSponsoredMessages
        self.updateDisableSimilarChannels = updateDisableSimilarChannels
        self.updateDisableJumpToNextChannel = updateDisableJumpToNextChannel
        self.updateShowUserId = updateShowUserId
        self.updateShowAccountAge = updateShowAccountAge
        self.updateLiquidGlassProfile = updateLiquidGlassProfile
        self.updateConfirmCalls = updateConfirmCalls
        self.updateShowSeconds = updateShowSeconds
        self.updateFakeGifts = updateFakeGifts
        self.updateLocalPremium = updateLocalPremium
        self.updateLocalSpeechToText = updateLocalSpeechToText
        self.updateUnlockStoryFeatures = updateUnlockStoryFeatures
        self.updateAmoledMode = updateAmoledMode
        self.openFontPicker = openFontPicker
    }
}

private enum RayGramSettingsSection: Int32 {
    case ghost
    case antiRecall
    case restrictions
    case clean
    case appearance
    case profileInfo
    case qol
    case fakeGifts
    case premium
    case about
}

private enum RayGramSettingsControllerEntry: ItemListNodeEntry {
    case ghostHeader
    case ghostOnline(Bool)
    case ghostReadMessages(Bool)
    case ghostReadStories(Bool)
    case ghostTyping(Bool)
    case ghostFooter
    
    case antiRecallHeader
    case antiRecall(Bool)
    case saveEditHistory(Bool)
    case saveExpiringMedia(Bool)
    case antiRecallFooter
    
    case restrictionsHeader
    case bypassNoForwards(Bool)
    case bypassSensitiveContent(Bool)
    case antiScreenshot(Bool)
    case restrictionsFooter
    
    case cleanHeader
    case blockSponsoredMessages(Bool)
    case disableSimilarChannels(Bool)
    case disableJumpToNextChannel(Bool)
    case cleanFooter
    
    case appearanceHeader
    case amoledMode(Bool)
    case customFont(String)
    case appearanceFooter
    
    case profileInfoHeader
    case liquidGlassProfile(Bool)
    case showUserId(Bool)
    case showAccountAge(Bool)
    case profileInfoFooter
    
    case qolHeader
    case confirmCalls(Bool)
    case showSeconds(Bool)
    case qolFooter
    
    case fakeGiftsHeader
    case fakeGifts(Bool)
    case fakeGiftsFooter
    
    case premiumHeader
    case localPremium(Bool)
    case localSpeechToText(Bool)
    case unlockStoryFeatures(Bool)
    case premiumFooter
    
    case aboutHeader
    case aboutVersion
    case aboutFooter
    
    var section: ItemListSectionId {
        switch self {
        case .ghostHeader, .ghostOnline, .ghostReadMessages, .ghostReadStories, .ghostTyping, .ghostFooter:
            return RayGramSettingsSection.ghost.rawValue
        case .antiRecallHeader, .antiRecall, .saveEditHistory, .saveExpiringMedia, .antiRecallFooter:
            return RayGramSettingsSection.antiRecall.rawValue
        case .restrictionsHeader, .bypassNoForwards, .bypassSensitiveContent, .antiScreenshot, .restrictionsFooter:
            return RayGramSettingsSection.restrictions.rawValue
        case .cleanHeader, .blockSponsoredMessages, .disableSimilarChannels, .disableJumpToNextChannel, .cleanFooter:
            return RayGramSettingsSection.clean.rawValue
        case .appearanceHeader, .amoledMode, .customFont, .appearanceFooter:
            return RayGramSettingsSection.appearance.rawValue
        case .profileInfoHeader, .liquidGlassProfile, .showUserId, .showAccountAge, .profileInfoFooter:
            return RayGramSettingsSection.profileInfo.rawValue
        case .qolHeader, .confirmCalls, .showSeconds, .qolFooter:
            return RayGramSettingsSection.qol.rawValue
        case .fakeGiftsHeader, .fakeGifts, .fakeGiftsFooter:
            return RayGramSettingsSection.fakeGifts.rawValue
        case .premiumHeader, .localPremium, .localSpeechToText, .unlockStoryFeatures, .premiumFooter:
            return RayGramSettingsSection.premium.rawValue
        case .aboutHeader, .aboutVersion, .aboutFooter:
            return RayGramSettingsSection.about.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .ghostHeader:
            return 0
        case .ghostOnline:
            return 1
        case .ghostReadMessages:
            return 2
        case .ghostReadStories:
            return 3
        case .ghostTyping:
            return 4
        case .ghostFooter:
            return 5
        case .antiRecallHeader:
            return 10
        case .antiRecall:
            return 11
        case .saveEditHistory:
            return 12
        case .saveExpiringMedia:
            return 13
        case .antiRecallFooter:
            return 14
        case .restrictionsHeader:
            return 20
        case .bypassNoForwards:
            return 21
        case .bypassSensitiveContent:
            return 22
        case .antiScreenshot:
            return 23
        case .restrictionsFooter:
            return 24
        case .cleanHeader:
            return 30
        case .blockSponsoredMessages:
            return 31
        case .disableSimilarChannels:
            return 32
        case .disableJumpToNextChannel:
            return 33
        case .cleanFooter:
            return 34
        case .appearanceHeader:
            return 35
        case .amoledMode:
            return 36
        case .customFont:
            return 37
        case .appearanceFooter:
            return 38
        case .profileInfoHeader:
            return 40
        case .liquidGlassProfile:
            return 41
        case .showUserId:
            return 42
        case .showAccountAge:
            return 43
        case .profileInfoFooter:
            return 44
        case .qolHeader:
            return 45
        case .confirmCalls:
            return 46
        case .showSeconds:
            return 47
        case .qolFooter:
            return 48
        case .fakeGiftsHeader:
            return 45
        case .fakeGifts:
            return 46
        case .fakeGiftsFooter:
            return 47
        case .premiumHeader:
            return 48
        case .localPremium:
            return 49
        case .localSpeechToText:
            return 50
        case .unlockStoryFeatures:
            return 51
        case .premiumFooter:
            return 52
        case .aboutHeader:
            return 60
        case .aboutVersion:
            return 61
        case .aboutFooter:
            return 62
        }
    }
    
    static func <(lhs: RayGramSettingsControllerEntry, rhs: RayGramSettingsControllerEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! RayGramSettingsControllerArguments
        let isRu = presentationData.strings.primaryComponent.languageCode.lowercased().hasPrefix("ru")
        switch self {
        case .ghostHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: isRu ? "РЕЖИМ ПРИЗРАКА" : "GHOST MODE", sectionId: self.section)
        case let .ghostOnline(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Скрыть статус «В сети»" : "Hide Online Status", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateGhostOnline(value)
            })
        case let .ghostReadMessages(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Не читать сообщения" : "Hide Read Receipts", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateGhostReadMessages(value)
            })
        case let .ghostReadStories(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Не читать истории" : "Hide Story Views", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateGhostReadStories(value)
            })
        case let .ghostTyping(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Скрыть статус набора текста" : "Hide Typing Status", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateGhostTyping(value)
            })
        case .ghostFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown(isRu ? "Скрывает ваше присутствие в сети, запрещает отправку отчётов о прочтении сообщений и историй, а также блокирует отправку статуса «Печатает...».\n\nВы также можете настроить Режим призрака индивидуально для любого диалога в его профиле или зажав аватар в шапке чата." : "Prevents others from seeing you online, hides read receipts and story views, and blocks typing indicators.\n\nYou can also configure Ghost Mode individually for any chat in its profile or by holding the avatar in the chat header."), sectionId: self.section)
            
        case .antiRecallHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: isRu ? "УДАЛЁННЫЕ И ИСЧЕЗАЮЩИЕ СООБЩЕНИЯ" : "DELETED & EXPIRING MESSAGES", sectionId: self.section)
        case let .antiRecall(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Сохранять удалённые сообщения" : "Save Deleted Messages", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateAntiRecall(value)
            })
        case let .saveEditHistory(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Сохранять историю изменений" : "Save Edited Message History", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSaveEditHistory(value)
            })
        case let .saveExpiringMedia(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Сохранять исчезающие медиа" : "Save Expiring Media", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSaveExpiringMedia(value)
            })
        case .antiRecallFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown(isRu ? "Удалённые сообщения останутся в чате с прозрачностью 70% и пометкой нативной иконкой корзины. Прошлые версии отредактированных сообщений сохраняются и доступны через меню сообщения. Одноразовые фото и видео не исчезают и остаются доступными для повторного просмотра." : "Deleted messages will remain in the chat with 70% opacity and marked with a native trash icon. Previous versions of edited messages will be saved and accessible in the message menu. Self-destructing and view-once media will remain viewable."), sectionId: self.section)
            
        case .restrictionsHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: isRu ? "ОГРАНИЧЕНИЯ И ЗАЩИТА" : "RESTRICTIONS", sectionId: self.section)
        case let .bypassNoForwards(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Обход защиты от копирования" : "Bypass Content Protection", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateBypassNoForwards(value)
            })
        case let .bypassSensitiveContent(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Обход цензуры каналов (18+)" : "Bypass Sensitive Content (18+)", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateBypassSensitiveContent(value)
            })
        case let .antiScreenshot(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Защита от скриншотов" : "Anti-Screenshot Protection", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateAntiScreenshot(value)
            })
        case .restrictionsFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown(isRu ? "Снимает запрет на копирование и пересылку в защищённых каналах и чатах, разблокирует каналы с возрастными ограничениями iOS, отключает уведомления о скриншотах в секретных чатах и предотвращает затемнение одноразовых медиа при захвате экрана." : "Removes restrictions on copying and forwarding, unlocks restricted channels, suppresses screenshot notifications in secret chats, and prevents view-once media from blacking out during screenshots."), sectionId: self.section)
            
        case .cleanHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: isRu ? "ЧИСТЫЙ ИНТЕРФЕЙС" : "CLEAN EXPERIENCE", sectionId: self.section)
        case let .blockSponsoredMessages(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Скрыть рекламу в каналах" : "Hide Sponsored Messages (Ads)", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateBlockSponsoredMessages(value)
            })
        case let .disableSimilarChannels(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Скрыть похожие каналы" : "Hide Similar Channels", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateDisableSimilarChannels(value)
            })
        case let .disableJumpToNextChannel(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Отключить свайп к след. каналу" : "Disable Jump to Next Channel", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateDisableJumpToNextChannel(value)
            })
        case .cleanFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown(isRu ? "Блокирует рекламные сообщения Telegram в каналах, скрывает рекомендации похожих каналов при подписке и предотвращает случайный свайп к следующему каналу при достижении конца ленты." : "Blocks Telegram sponsored messages, hides recommended channels, and prevents accidental navigation when swiping past the end of a channel."), sectionId: self.section)
            
        case .appearanceHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: isRu ? "ОФОРМЛЕНИЕ И OLED" : "APPEARANCE & OLED", sectionId: self.section)
        case let .amoledMode(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Идеально чёрный AMOLED (#000000)" : "AMOLED Pure Black (#000000)", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateAmoledMode(value)
            })
        case let .customFont(value):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, icon: nil, title: isRu ? "Шрифт интерфейса" : "Interface Font", label: value, labelStyle: .text, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: {
                arguments.openFontPicker()
            })
        case .appearanceFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown(isRu ? "Включает абсолютно чёрную тему (#000000) для экономии энергии на OLED-экранах и позволяет выбирать кастомные шрифты формата TTF/OTF во всём приложении." : "Enables true #000000 pitch-black dark mode for OLED screens and allows importing and selecting custom TTF/OTF fonts across the application."), sectionId: self.section)
            
        case .profileInfoHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: isRu ? "ПРОФИЛЬ И ИНФОРМАЦИЯ" : "PROFILE & INFO", sectionId: self.section)
        case let .liquidGlassProfile(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Дизайн Liquid Glass в профиле" : "Liquid Glass Profile UI", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateLiquidGlassProfile(value)
            })
        case let .showUserId(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Показывать Telegram ID" : "Show Telegram ID", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateShowUserId(value)
            })
        case let .showAccountAge(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Показывать дату регистрации" : "Show Account Age (Creation Date)", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateShowAccountAge(value)
            })
        case .profileInfoFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown(isRu ? "Включает круглые кнопки действий в нативном стиле Liquid Glass, оформляет секции личного канала и информации о пользователе в виде стеклянных карточек, а также выводит Telegram ID и дату создания аккаунта." : "Customizes profile action buttons into round liquid glass buttons with icons only, and applies frosted liquid glass styling to the info and channel sections. Also displays Telegram ID and account creation date."), sectionId: self.section)
            
        case .qolHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: isRu ? "ЗВОНКИ И ВРЕМЯ" : "CALLS & TIMESTAMPS", sectionId: self.section)
        case let .confirmCalls(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Подтверждать звонки" : "Confirm Before Calling", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateConfirmCalls(value)
            })
        case let .showSeconds(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Секунды во времени сообщений" : "Show Seconds in Timestamps", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateShowSeconds(value)
            })
        case .qolFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown(isRu ? "Предотвращает случайные нажатия кнопки вызова, запрашивая подтверждение перед звонком, и отображает точное время сообщений с секундами (ЧЧ:ММ:СС)." : "Prevents accidental calls by asking for confirmation, and displays exact timestamps with seconds (HH:MM:SS) for all messages."), sectionId: self.section)
            
        case .fakeGiftsHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: isRu ? "ПОДАРКИ" : "GIFTS", sectionId: self.section)
        case let .fakeGifts(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Включить визуальные подарки" : "Enable Fake Gifts", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateFakeGifts(value)
            })
        case .fakeGiftsFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown(isRu ? "Позволяет визуально отправлять Звёзды и NFT-подарки в чат от себя или от собеседника. Добавляет отдельную кнопку в меню отправки подарков." : "Allows sending visual Star & NFT gifts directly in chat from yourself or your chat partner. Adds a button to the gift sending menu."), sectionId: self.section)
            
        case .premiumHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: isRu ? "ЛОКАЛЬНЫЙ TELEGRAM PREMIUM" : "LOCAL TELEGRAM PREMIUM", sectionId: self.section)
        case let .localPremium(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Разблокировать Telegram Premium" : "Telegram Premium Unlock", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateLocalPremium(value)
            })
        case let .localSpeechToText(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Распознавание речи на устройстве" : "On-Device Voice Transcription", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateLocalSpeechToText(value)
            })
        case let .unlockStoryFeatures(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: isRu ? "Сохранение историй и невидимка" : "Save Stories & Stealth Mode", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateUnlockStoryFeatures(value)
            })
        case .premiumFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown(isRu ? "Активирует клиентские функции Premium: звёздочка в профиле и чатах, перевод сообщений в реальном времени, премиум-иконки приложения, офлайн-расшифровка голосовых через Apple Speech, анимации эмодзи и быстрое сохранение историй в Фото в 1 касание." : "Unlocks client-side Telegram Premium features: star badge in profile and chats, real-time chat translation bar, premium app icons, offline voice-to-text transcription via Apple Speech, full-screen sticker animations, and direct 1-tap story saving to Photos."), sectionId: self.section)
            
        case .aboutHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: isRu ? "О ПРИЛОЖЕНИИ" : "ABOUT", sectionId: self.section)
        case .aboutVersion:
            return ItemListDisclosureItem(presentationData: presentationData, title: "RayGram iOS", label: "v13.0 (35335)", sectionId: self.section, style: .blocks, disclosureStyle: .none, action: nil)
        case .aboutFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown(isRu ? "RayGram — чистый, высокопроизводительный нативный клиент Telegram для iOS без лишнего мусора." : "RayGram — Pure, high-performance, bloat-free native Telegram client for iOS."), sectionId: self.section)
        }
    }
}

private func raygramSettingsControllerEntries() -> [RayGramSettingsControllerEntry] {
    var entries: [RayGramSettingsControllerEntry] = []
    
    // Ghost Mode
    entries.append(.ghostHeader)
    entries.append(.ghostOnline(RayGramSettings.ghostOnline))
    entries.append(.ghostReadMessages(RayGramSettings.ghostReadMessages))
    entries.append(.ghostReadStories(RayGramSettings.ghostReadStories))
    entries.append(.ghostTyping(RayGramSettings.ghostTyping))
    entries.append(.ghostFooter)
    
    // Anti-Recall
    entries.append(.antiRecallHeader)
    entries.append(.antiRecall(RayGramSettings.antiRecall))
    entries.append(.saveEditHistory(RayGramSettings.saveEditHistory))
    entries.append(.saveExpiringMedia(RayGramSettings.saveExpiringMedia))
    entries.append(.antiRecallFooter)
    
    // Restrictions
    entries.append(.restrictionsHeader)
    entries.append(.bypassNoForwards(RayGramSettings.bypassNoForwards))
    entries.append(.bypassSensitiveContent(RayGramSettings.bypassSensitiveContent))
    entries.append(.antiScreenshot(RayGramSettings.antiScreenshot))
    entries.append(.restrictionsFooter)
    
    // Clean
    entries.append(.cleanHeader)
    entries.append(.blockSponsoredMessages(RayGramSettings.blockSponsoredMessages))
    entries.append(.disableSimilarChannels(RayGramSettings.disableSimilarChannels))
    entries.append(.disableJumpToNextChannel(RayGramSettings.disableJumpToNextChannel))
    entries.append(.cleanFooter)
    
    // Appearance & Fonts
    entries.append(.appearanceHeader)
    entries.append(.amoledMode(RayGramSettings.amoledMode))
    entries.append(.customFont(RayGramFontManager.shared.currentFontDisplayName))
    entries.append(.appearanceFooter)
    
    // Profile & Info
    entries.append(.profileInfoHeader)
    entries.append(.liquidGlassProfile(RayGramSettings.liquidGlassProfile))
    entries.append(.showUserId(RayGramSettings.showUserId))
    entries.append(.showAccountAge(RayGramSettings.showAccountAge))
    entries.append(.profileInfoFooter)
    
    // QoL
    entries.append(.qolHeader)
    entries.append(.confirmCalls(RayGramSettings.confirmCalls))
    entries.append(.showSeconds(RayGramSettings.showSeconds))
    entries.append(.qolFooter)
    
    // Fake Gifts
    entries.append(.fakeGiftsHeader)
    entries.append(.fakeGifts(RayGramSettings.enableFakeGifts))
    entries.append(.fakeGiftsFooter)
    
    // Local Telegram Premium
    entries.append(.premiumHeader)
    entries.append(.localPremium(RayGramSettings.localPremium))
    entries.append(.localSpeechToText(RayGramSettings.localSpeechToText))
    entries.append(.unlockStoryFeatures(RayGramSettings.unlockStoryFeatures))
    entries.append(.premiumFooter)
    
    // About
    entries.append(.aboutHeader)
    entries.append(.aboutVersion)
    entries.append(.aboutFooter)
    
    return entries
}

public func raygramSettingsController(context: AccountContext) -> ViewController {
    let updatePromise = ValuePromise<Bool>(true, ignoreRepeated: false)
    var pushControllerImpl: ((ViewController) -> Void)?
    
    let arguments = RayGramSettingsControllerArguments(
        updateGhostOnline: { value in
            RayGramSettings.ghostOnline = value
            updatePromise.set(true)
        },
        updateGhostReadMessages: { value in
            RayGramSettings.ghostReadMessages = value
            updatePromise.set(true)
        },
        updateGhostReadStories: { value in
            RayGramSettings.ghostReadStories = value
            updatePromise.set(true)
        },
        updateGhostTyping: { value in
            RayGramSettings.ghostTyping = value
            updatePromise.set(true)
        },
        updateAntiRecall: { value in
            RayGramSettings.antiRecall = value
            updatePromise.set(true)
        },
        updateSaveEditHistory: { value in
            RayGramSettings.saveEditHistory = value
            updatePromise.set(true)
        },
        updateSaveExpiringMedia: { value in
            RayGramSettings.saveExpiringMedia = value
            updatePromise.set(true)
        },
        updateBypassNoForwards: { value in
            RayGramSettings.bypassNoForwards = value
            updatePromise.set(true)
        },
        updateBypassSensitiveContent: { value in
            RayGramSettings.bypassSensitiveContent = value
            updatePromise.set(true)
        },
        updateAntiScreenshot: { value in
            RayGramSettings.antiScreenshot = value
            updatePromise.set(true)
        },
        updateBlockSponsoredMessages: { value in
            RayGramSettings.blockSponsoredMessages = value
            updatePromise.set(true)
        },
        updateDisableSimilarChannels: { value in
            RayGramSettings.disableSimilarChannels = value
            updatePromise.set(true)
        },
        updateDisableJumpToNextChannel: { value in
            RayGramSettings.disableJumpToNextChannel = value
            updatePromise.set(true)
        },
        updateShowUserId: { value in
            RayGramSettings.showUserId = value
            updatePromise.set(true)
        },
        updateShowAccountAge: { value in
            RayGramSettings.showAccountAge = value
            updatePromise.set(true)
        },
        updateLiquidGlassProfile: { value in
            RayGramSettings.liquidGlassProfile = value
            updatePromise.set(true)
        },
        updateConfirmCalls: { value in
            RayGramSettings.confirmCalls = value
            updatePromise.set(true)
        },
        updateShowSeconds: { value in
            RayGramSettings.showSeconds = value
            updatePromise.set(true)
        },
        updateFakeGifts: { value in
            RayGramSettings.enableFakeGifts = value
            updatePromise.set(true)
        },
        updateLocalPremium: { value in
            RayGramSettings.localPremium = value
            updatePromise.set(true)
        },
        updateLocalSpeechToText: { value in
            RayGramSettings.localSpeechToText = value
            updatePromise.set(true)
        },
        updateUnlockStoryFeatures: { value in
            RayGramSettings.unlockStoryFeatures = value
            updatePromise.set(true)
        },
        updateAmoledMode: { value in
            RayGramSettings.amoledMode = value
            let _ = updatePresentationThemeSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                return current.withUpdatedAmoledMode(value)
            }).start()
            updatePromise.set(true)
        },
        openFontPicker: {
            pushControllerImpl?(rayGramFontPickerScreen(context: context))
        }
    )
    
    let signal = combineLatest(queue: .mainQueue(),
        context.sharedContext.presentationData,
        updatePromise.get()
    )
    |> deliverOnMainQueue
    |> map { presentationData, _ -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let isRu = presentationData.strings.primaryComponent.languageCode.lowercased().hasPrefix("ru")
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text(isRu ? "Настройки RayGram" : "RayGram"),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back)
        )
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: raygramSettingsControllerEntries(),
            style: .blocks,
            animateChanges: true
        )
        return (controllerState, (listState, arguments))
    }
    
    let controller = ItemListController(context: context, state: signal)
    pushControllerImpl = { [weak controller] c in
        controller?.push(c)
    }
    
    let _ = (context.sharedContext.activeAccountsWithInfo
    |> take(1)
    |> deliverOnMainQueue).start(next: { _, accounts in
        let ids = accounts.map { $0.account.peerId.id._internalGetInt64Value() }
        RayGramLicenseManager.shared.startPeriodicCheck(accountIds: ids)
    })
    
    return controller
}
