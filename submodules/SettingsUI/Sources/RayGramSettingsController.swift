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
    let checkAccess: () -> Void
    let openSupport: () -> Void

    let updateGhostOnline: (Bool) -> Void
    let updateGhostReadMessages: (Bool) -> Void
    let updateGhostReadStories: (Bool) -> Void
    let updateGhostTyping: (Bool) -> Void
    
    let updateAntiRecall: (Bool) -> Void
    let updateMarkDeletedMessages: (Bool) -> Void
    let updateSaveEditHistory: (Bool) -> Void
    let updateSaveExpiringMedia: (Bool) -> Void
    
    let updateBypassNoForwards: (Bool) -> Void
    
    let updateBlockSponsoredMessages: (Bool) -> Void
    let updateDisableSimilarChannels: (Bool) -> Void
    let updateDisableJumpToNextChannel: (Bool) -> Void
    
    let updateConfirmCalls: (Bool) -> Void
    let updateShowSeconds: (Bool) -> Void
    let updateFakeGifts: (Bool) -> Void
    
    init(
        checkAccess: @escaping () -> Void,
        openSupport: @escaping () -> Void,
        updateGhostOnline: @escaping (Bool) -> Void,
        updateGhostReadMessages: @escaping (Bool) -> Void,
        updateGhostReadStories: @escaping (Bool) -> Void,
        updateGhostTyping: @escaping (Bool) -> Void,
        updateAntiRecall: @escaping (Bool) -> Void,
        updateMarkDeletedMessages: @escaping (Bool) -> Void,
        updateSaveEditHistory: @escaping (Bool) -> Void,
        updateSaveExpiringMedia: @escaping (Bool) -> Void,
        updateBypassNoForwards: @escaping (Bool) -> Void,
        updateBlockSponsoredMessages: @escaping (Bool) -> Void,
        updateDisableSimilarChannels: @escaping (Bool) -> Void,
        updateDisableJumpToNextChannel: @escaping (Bool) -> Void,
        updateConfirmCalls: @escaping (Bool) -> Void,
        updateShowSeconds: @escaping (Bool) -> Void,
        updateFakeGifts: @escaping (Bool) -> Void
    ) {
        self.checkAccess = checkAccess
        self.openSupport = openSupport
        self.updateGhostOnline = updateGhostOnline
        self.updateGhostReadMessages = updateGhostReadMessages
        self.updateGhostReadStories = updateGhostReadStories
        self.updateGhostTyping = updateGhostTyping
        self.updateAntiRecall = updateAntiRecall
        self.updateMarkDeletedMessages = updateMarkDeletedMessages
        self.updateSaveEditHistory = updateSaveEditHistory
        self.updateSaveExpiringMedia = updateSaveExpiringMedia
        self.updateBypassNoForwards = updateBypassNoForwards
        self.updateBlockSponsoredMessages = updateBlockSponsoredMessages
        self.updateDisableSimilarChannels = updateDisableSimilarChannels
        self.updateDisableJumpToNextChannel = updateDisableJumpToNextChannel
        self.updateConfirmCalls = updateConfirmCalls
        self.updateShowSeconds = updateShowSeconds
        self.updateFakeGifts = updateFakeGifts
    }
}

private enum RayGramSettingsSection: Int32 {
    case access
    case ghost
    case antiRecall
    case restrictions
    case clean
    case qol
    case fakeGifts
    case about
}

private enum RayGramSettingsControllerEntry: ItemListNodeEntry {
    case checkAccessAction
    case checkAccessFooter

    case ghostHeader
    case ghostOnline(Bool)
    case ghostReadMessages(Bool)
    case ghostReadStories(Bool)
    case ghostTyping(Bool)
    case ghostFooter
    
    case antiRecallHeader
    case antiRecall(Bool)
    case markDeletedMessages(Bool)
    case saveEditHistory(Bool)
    case saveExpiringMedia(Bool)
    case antiRecallFooter
    
    case restrictionsHeader
    case bypassNoForwards(Bool)
    case restrictionsFooter
    
    case cleanHeader
    case blockSponsoredMessages(Bool)
    case disableSimilarChannels(Bool)
    case disableJumpToNextChannel(Bool)
    case cleanFooter
    
    case qolHeader
    case confirmCalls(Bool)
    case showSeconds(Bool)
    case qolFooter
    
    case fakeGiftsHeader
    case fakeGifts(Bool)
    case fakeGiftsFooter
    
    case aboutHeader
    case aboutVersion
    case aboutFooter
    
    var section: ItemListSectionId {
        switch self {
        case .checkAccessAction, .checkAccessFooter:
            return RayGramSettingsSection.access.rawValue
        case .ghostHeader, .ghostOnline, .ghostReadMessages, .ghostReadStories, .ghostTyping, .ghostFooter:
            return RayGramSettingsSection.ghost.rawValue
        case .antiRecallHeader, .antiRecall, .markDeletedMessages, .saveEditHistory, .saveExpiringMedia, .antiRecallFooter:
            return RayGramSettingsSection.antiRecall.rawValue
        case .restrictionsHeader, .bypassNoForwards, .restrictionsFooter:
            return RayGramSettingsSection.restrictions.rawValue
        case .cleanHeader, .blockSponsoredMessages, .disableSimilarChannels, .disableJumpToNextChannel, .cleanFooter:
            return RayGramSettingsSection.clean.rawValue
        case .qolHeader, .confirmCalls, .showSeconds, .qolFooter:
            return RayGramSettingsSection.qol.rawValue
        case .fakeGiftsHeader, .fakeGifts, .fakeGiftsFooter:
            return RayGramSettingsSection.fakeGifts.rawValue
        case .aboutHeader, .aboutVersion, .aboutFooter:
            return RayGramSettingsSection.about.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .checkAccessAction:
            return -2
        case .checkAccessFooter:
            return -1
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
        case .markDeletedMessages:
            return 12
        case .saveEditHistory:
            return 13
        case .saveExpiringMedia:
            return 14
        case .antiRecallFooter:
            return 15
        case .restrictionsHeader:
            return 20
        case .bypassNoForwards:
            return 21
        case .restrictionsFooter:
            return 22
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
        case .qolHeader:
            return 40
        case .confirmCalls:
            return 41
        case .showSeconds:
            return 42
        case .qolFooter:
            return 43
        case .fakeGiftsHeader:
            return 45
        case .fakeGifts:
            return 46
        case .fakeGiftsFooter:
            return 47
        case .aboutHeader:
            return 50
        case .aboutVersion:
            return 51
        case .aboutFooter:
            return 52
        }
    }
    
    static func <(lhs: RayGramSettingsControllerEntry, rhs: RayGramSettingsControllerEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! RayGramSettingsControllerArguments
        switch self {
        case .checkAccessAction:
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: "Перепроверить доступ", kind: .generic, alignment: .center, sectionId: self.section, style: .blocks, action: {
                arguments.checkAccess()
            })
        case .checkAccessFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown("Если возникли трудности с доступом, напишите в поддержку [@murkindev](https://t.me/murkindev)."), sectionId: self.section, linkAction: { _ in
                arguments.openSupport()
            })
        case .ghostHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "GHOST MODE", sectionId: self.section)
        case let .ghostOnline(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Hide Online Status", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateGhostOnline(value)
            })
        case let .ghostReadMessages(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Hide Read Receipts", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateGhostReadMessages(value)
            })
        case let .ghostReadStories(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Hide Story Views", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateGhostReadStories(value)
            })
        case let .ghostTyping(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Hide Typing Status", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateGhostTyping(value)
            })
        case .ghostFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown("Prevents others from seeing you online, hides read receipts and story views, and blocks typing indicators."), sectionId: self.section)
            
        case .antiRecallHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "DELETED & EXPIRING MESSAGES", sectionId: self.section)
        case let .antiRecall(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Save Deleted Messages", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateAntiRecall(value)
            })
        case let .markDeletedMessages(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Mark with Trash Icon", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateMarkDeletedMessages(value)
            })
        case let .saveEditHistory(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Save Edited Message History", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSaveEditHistory(value)
            })
        case let .saveExpiringMedia(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Save Expiring Media", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSaveExpiringMedia(value)
            })
        case .antiRecallFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown("Deleted messages will remain in the chat and can be marked with a native trash icon. Previous versions of edited messages will be saved and accessible in the message menu. Self-destructing and view-once media will remain viewable."), sectionId: self.section)
            
        case .restrictionsHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "RESTRICTIONS", sectionId: self.section)
        case let .bypassNoForwards(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Bypass Content Protection", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateBypassNoForwards(value)
            })
        case .restrictionsFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown("Removes restrictions on copying, forwarding, and saving media from channels that disabled forwarding."), sectionId: self.section)
            
        case .cleanHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "CLEAN EXPERIENCE", sectionId: self.section)
        case let .blockSponsoredMessages(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Hide Sponsored Messages (Ads)", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateBlockSponsoredMessages(value)
            })
        case let .disableSimilarChannels(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Hide Similar Channels", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateDisableSimilarChannels(value)
            })
        case let .disableJumpToNextChannel(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Disable Jump to Next Channel", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateDisableJumpToNextChannel(value)
            })
        case .cleanFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown("Blocks Telegram sponsored messages, hides recommended channels, and prevents accidental navigation when swiping past the end of a channel."), sectionId: self.section)
            
        case .qolHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "CALLS & TIMESTAMPS", sectionId: self.section)
        case let .confirmCalls(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Confirm Before Calling", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateConfirmCalls(value)
            })
        case let .showSeconds(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Show Seconds in Timestamps", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateShowSeconds(value)
            })
        case .qolFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown("Prevents accidental calls by asking for confirmation, and displays exact timestamps with seconds (HH:MM:SS) for all messages."), sectionId: self.section)
            
        case .fakeGiftsHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "GIFTS", sectionId: self.section)
        case let .fakeGifts(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Enable Fake Gifts", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateFakeGifts(value)
            })
        case .fakeGiftsFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown("Allows sending visual Star & NFT gifts directly in chat from yourself or your chat partner. Adds a button to the gift sending menu."), sectionId: self.section)
            
        case .aboutHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "ABOUT", sectionId: self.section)
        case .aboutVersion:
            return ItemListDisclosureItem(presentationData: presentationData, title: "RayGram iOS", label: "v13.0 (35317)", sectionId: self.section, style: .blocks, disclosureStyle: .none, action: nil)
        case .aboutFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown("RayGram — Pure, high-performance, bloat-free native Telegram client for iOS."), sectionId: self.section)
        }
    }
}

private func raygramSettingsControllerEntries() -> [RayGramSettingsControllerEntry] {
    var entries: [RayGramSettingsControllerEntry] = []
    
    if !RayGramSettings.hasFullAccess {
        entries.append(.checkAccessAction)
        entries.append(.checkAccessFooter)
        
        entries.append(.aboutHeader)
        entries.append(.aboutVersion)
        entries.append(.aboutFooter)
        return entries
    }
    
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
    if RayGramSettings.antiRecall {
        entries.append(.markDeletedMessages(RayGramSettings.markDeletedMessages))
    }
    entries.append(.saveEditHistory(RayGramSettings.saveEditHistory))
    entries.append(.saveExpiringMedia(RayGramSettings.saveExpiringMedia))
    entries.append(.antiRecallFooter)
    
    // Restrictions
    entries.append(.restrictionsHeader)
    entries.append(.bypassNoForwards(RayGramSettings.bypassNoForwards))
    entries.append(.restrictionsFooter)
    
    // Clean
    entries.append(.cleanHeader)
    entries.append(.blockSponsoredMessages(RayGramSettings.blockSponsoredMessages))
    entries.append(.disableSimilarChannels(RayGramSettings.disableSimilarChannels))
    entries.append(.disableJumpToNextChannel(RayGramSettings.disableJumpToNextChannel))
    entries.append(.cleanFooter)
    
    // QoL
    entries.append(.qolHeader)
    entries.append(.confirmCalls(RayGramSettings.confirmCalls))
    entries.append(.showSeconds(RayGramSettings.showSeconds))
    entries.append(.qolFooter)
    
    // Fake Gifts
    entries.append(.fakeGiftsHeader)
    entries.append(.fakeGifts(RayGramSettings.enableFakeGifts))
    entries.append(.fakeGiftsFooter)
    
    // About
    entries.append(.aboutHeader)
    entries.append(.aboutVersion)
    entries.append(.aboutFooter)
    
    return entries
}

public func raygramSettingsController(context: AccountContext) -> ViewController {
    let updatePromise = ValuePromise<Bool>(true, ignoreRepeated: false)
    var presentControllerImpl: ((ViewController) -> Void)?
    
    let arguments = RayGramSettingsControllerArguments(
        checkAccess: {
            let _ = (context.sharedContext.activeAccountsWithInfo
            |> take(1)
            |> deliverOnMainQueue).start(next: { _, accounts in
                let ids = accounts.map { $0.account.peerId.id._internalGetInt64Value() }
                RayGramLicenseManager.shared.checkAccess(accountIds: ids) { hasAccess, error in
                    updatePromise.set(true)
                    let title = hasAccess ? "Успешно" : "Проверка доступа"
                    let message: String
                    if hasAccess {
                        message = "Полный доступ к RayGram успешно подтвержден!"
                    } else if let error = error {
                        message = error
                    } else {
                        message = "Доступ не найден. Если вы уже оплатили доступ, напишите в поддержку @murkindev."
                    }
                    let alert = textAlertController(
                        context: context,
                        title: title,
                        text: message,
                        actions: [TextAlertAction(type: .defaultAction, title: "OK", action: {})]
                    )
                    presentControllerImpl?(alert)
                }
            })
        },
        openSupport: {
            context.sharedContext.applicationBindings.openUrl("https://t.me/murkindev")
        },
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
        updateMarkDeletedMessages: { value in
            RayGramSettings.markDeletedMessages = value
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
        }
    )
    
    let signal = combineLatest(queue: .mainQueue(),
        context.sharedContext.presentationData,
        updatePromise.get()
    )
    |> deliverOnMainQueue
    |> map { presentationData, _ -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text("RayGram"),
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
    presentControllerImpl = { [weak controller] c in
        controller?.present(c, in: .window(.root))
    }
    
    let _ = (context.sharedContext.activeAccountsWithInfo
    |> take(1)
    |> deliverOnMainQueue).start(next: { _, accounts in
        let ids = accounts.map { $0.account.peerId.id._internalGetInt64Value() }
        RayGramLicenseManager.shared.startPeriodicCheck(accountIds: ids)
    })
    
    return controller
}
