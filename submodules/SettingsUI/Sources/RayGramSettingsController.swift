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
    let updateGhostReadMessages: (Bool) -> Void
    let updateGhostReadStories: (Bool) -> Void
    let updateGhostTyping: (Bool) -> Void
    
    let updateAntiRecall: (Bool) -> Void
    let updateSaveExpiringMedia: (Bool) -> Void
    
    let updateBypassNoForwards: (Bool) -> Void
    
    let updateBlockSponsoredMessages: (Bool) -> Void
    let updateDisableSimilarChannels: (Bool) -> Void
    let updateDisableJumpToNextChannel: (Bool) -> Void
    
    let updateConfirmCalls: (Bool) -> Void
    let updateShowSeconds: (Bool) -> Void
    
    init(
        updateGhostReadMessages: @escaping (Bool) -> Void,
        updateGhostReadStories: @escaping (Bool) -> Void,
        updateGhostTyping: @escaping (Bool) -> Void,
        updateAntiRecall: @escaping (Bool) -> Void,
        updateSaveExpiringMedia: @escaping (Bool) -> Void,
        updateBypassNoForwards: @escaping (Bool) -> Void,
        updateBlockSponsoredMessages: @escaping (Bool) -> Void,
        updateDisableSimilarChannels: @escaping (Bool) -> Void,
        updateDisableJumpToNextChannel: @escaping (Bool) -> Void,
        updateConfirmCalls: @escaping (Bool) -> Void,
        updateShowSeconds: @escaping (Bool) -> Void
    ) {
        self.updateGhostReadMessages = updateGhostReadMessages
        self.updateGhostReadStories = updateGhostReadStories
        self.updateGhostTyping = updateGhostTyping
        self.updateAntiRecall = updateAntiRecall
        self.updateSaveExpiringMedia = updateSaveExpiringMedia
        self.updateBypassNoForwards = updateBypassNoForwards
        self.updateBlockSponsoredMessages = updateBlockSponsoredMessages
        self.updateDisableSimilarChannels = updateDisableSimilarChannels
        self.updateDisableJumpToNextChannel = updateDisableJumpToNextChannel
        self.updateConfirmCalls = updateConfirmCalls
        self.updateShowSeconds = updateShowSeconds
    }
}

private enum RayGramSettingsSection: Int32 {
    case ghost
    case antiRecall
    case restrictions
    case clean
    case qol
    case about
}

private enum RayGramSettingsControllerEntry: ItemListNodeEntry {
    case ghostHeader
    case ghostReadMessages(Bool)
    case ghostReadStories(Bool)
    case ghostTyping(Bool)
    case ghostFooter
    
    case antiRecallHeader
    case antiRecall(Bool)
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
    
    case aboutHeader
    case aboutVersion
    case aboutFooter
    
    var section: ItemListSectionId {
        switch self {
        case .ghostHeader, .ghostReadMessages, .ghostReadStories, .ghostTyping, .ghostFooter:
            return RayGramSettingsSection.ghost.rawValue
        case .antiRecallHeader, .antiRecall, .saveExpiringMedia, .antiRecallFooter:
            return RayGramSettingsSection.antiRecall.rawValue
        case .restrictionsHeader, .bypassNoForwards, .restrictionsFooter:
            return RayGramSettingsSection.restrictions.rawValue
        case .cleanHeader, .blockSponsoredMessages, .disableSimilarChannels, .disableJumpToNextChannel, .cleanFooter:
            return RayGramSettingsSection.clean.rawValue
        case .qolHeader, .confirmCalls, .showSeconds, .qolFooter:
            return RayGramSettingsSection.qol.rawValue
        case .aboutHeader, .aboutVersion, .aboutFooter:
            return RayGramSettingsSection.about.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .ghostHeader:
            return 0
        case .ghostReadMessages:
            return 1
        case .ghostReadStories:
            return 2
        case .ghostTyping:
            return 3
        case .ghostFooter:
            return 4
        case .antiRecallHeader:
            return 10
        case .antiRecall:
            return 11
        case .saveExpiringMedia:
            return 12
        case .antiRecallFooter:
            return 13
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
        case .ghostHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "GHOST MODE", sectionId: self.section)
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
            return ItemListTextItem(presentationData: presentationData, text: .markdown("Allows you to read messages, watch stories, and compose replies without notifying other users."), sectionId: self.section)
            
        case .antiRecallHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "DELETED & EXPIRING MESSAGES", sectionId: self.section)
        case let .antiRecall(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Save Deleted Messages", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateAntiRecall(value)
            })
        case let .saveExpiringMedia(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Save Expiring Media", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSaveExpiringMedia(value)
            })
        case .antiRecallFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown("Deleted messages will remain in the chat marked with a 🗑 icon. Self-destructing and view-once media will remain viewable."), sectionId: self.section)
            
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
            
        case .aboutHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "ABOUT", sectionId: self.section)
        case .aboutVersion:
            return ItemListDisclosureItem(presentationData: presentationData, title: "RayGram iOS", label: "v13.0 (35313)", sectionId: self.section, style: .blocks, disclosureStyle: .none, action: nil)
        case .aboutFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown("RayGram — Pure, high-performance, bloat-free native Telegram client for iOS."), sectionId: self.section)
        }
    }
}

private func raygramSettingsControllerEntries() -> [RayGramSettingsControllerEntry] {
    var entries: [RayGramSettingsControllerEntry] = []
    
    // Ghost Mode
    entries.append(.ghostHeader)
    entries.append(.ghostReadMessages(RayGramSettings.ghostReadMessages))
    entries.append(.ghostReadStories(RayGramSettings.ghostReadStories))
    entries.append(.ghostTyping(RayGramSettings.ghostTyping))
    entries.append(.ghostFooter)
    
    // Anti-Recall
    entries.append(.antiRecallHeader)
    entries.append(.antiRecall(RayGramSettings.antiRecall))
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
    
    // About
    entries.append(.aboutHeader)
    entries.append(.aboutVersion)
    entries.append(.aboutFooter)
    
    return entries
}

public func raygramSettingsController(context: AccountContext) -> ViewController {
    let updatePromise = ValuePromise<Bool>(true, ignoreRepeated: false)
    
    let arguments = RayGramSettingsControllerArguments(
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
    return controller
}
