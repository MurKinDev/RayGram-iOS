import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import ItemListUI
import PresentationDataUtils
import AccountContext
import AlertUI
import LegacyMediaPickerUI
import TelegramUIPreferences

private final class RayGramFontPickerArguments {
    let context: AccountContext
    let selectFont: (RayGramFontItem) -> Void
    let deleteFont: (RayGramFontItem) -> Void
    let importFont: () -> Void
    
    init(
        context: AccountContext,
        selectFont: @escaping (RayGramFontItem) -> Void,
        deleteFont: @escaping (RayGramFontItem) -> Void,
        importFont: @escaping () -> Void
    ) {
        self.context = context
        self.selectFont = selectFont
        self.deleteFont = deleteFont
        self.importFont = importFont
    }
}

private enum RayGramFontPickerSection: Int32 {
    case preview
    case importAction
    case importedFonts
    case presets
}

private enum RayGramFontPickerEntry: ItemListNodeEntry {
    case previewHeader(PresentationTheme, String)
    case previewCard(PresentationTheme, String)
    case importAction(PresentationTheme, String)
    case importedHeader(PresentationTheme, String)
    case importedFontItem(PresentationTheme, RayGramFontItem, Bool, Int)
    case presetsHeader(PresentationTheme, String)
    case presetFontItem(PresentationTheme, RayGramFontItem, Bool, Int)
    case footer(PresentationTheme, String)
    
    var section: ItemListSectionId {
        switch self {
        case .previewHeader, .previewCard:
            return RayGramFontPickerSection.preview.rawValue
        case .importAction:
            return RayGramFontPickerSection.importAction.rawValue
        case .importedHeader, .importedFontItem:
            return RayGramFontPickerSection.importedFonts.rawValue
        case .presetsHeader, .presetFontItem, .footer:
            return RayGramFontPickerSection.presets.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .previewHeader:
            return 0
        case .previewCard:
            return 1
        case .importAction:
            return 2
        case .importedHeader:
            return 100
        case let .importedFontItem(_, _, _, index):
            return 101 + Int32(index)
        case .presetsHeader:
            return 1000
        case let .presetFontItem(_, _, _, index):
            return 1001 + Int32(index)
        case .footer:
            return 2000
        }
    }
    
    static func ==(lhs: RayGramFontPickerEntry, rhs: RayGramFontPickerEntry) -> Bool {
        switch lhs {
        case let .previewHeader(lhsTheme, lhsText):
            if case let .previewHeader(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            }
            return false
        case let .previewCard(lhsTheme, lhsText):
            if case let .previewCard(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            }
            return false
        case let .importAction(lhsTheme, lhsText):
            if case let .importAction(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            }
            return false
        case let .importedHeader(lhsTheme, lhsText):
            if case let .importedHeader(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            }
            return false
        case let .importedFontItem(lhsTheme, lhsFont, lhsChecked, lhsIndex):
            if case let .importedFontItem(rhsTheme, rhsFont, rhsChecked, rhsIndex) = rhs,
               lhsTheme === rhsTheme, lhsFont == rhsFont, lhsChecked == rhsChecked, lhsIndex == rhsIndex {
                return true
            }
            return false
        case let .presetsHeader(lhsTheme, lhsText):
            if case let .presetsHeader(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            }
            return false
        case let .presetFontItem(lhsTheme, lhsFont, lhsChecked, lhsIndex):
            if case let .presetFontItem(rhsTheme, rhsFont, rhsChecked, rhsIndex) = rhs,
               lhsTheme === rhsTheme, lhsFont == rhsFont, lhsChecked == rhsChecked, lhsIndex == rhsIndex {
                return true
            }
            return false
        case let .footer(lhsTheme, lhsText):
            if case let .footer(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            }
            return false
        }
    }
    
    static func <(lhs: RayGramFontPickerEntry, rhs: RayGramFontPickerEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        guard let arguments = arguments as? RayGramFontPickerArguments else {
            return ItemListTextItem(presentationData: presentationData, text: .plain(""), sectionId: self.section)
        }
        switch self {
        case let .previewHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .previewCard(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .importAction(_, title):
            return ItemListActionItem(
                presentationData: presentationData,
                title: title,
                kind: .generic,
                alignment: .natural,
                sectionId: self.section,
                style: .blocks,
                action: {
                    arguments.importFont()
                }
            )
        case let .importedHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .importedFontItem(_, font, checked, _):
            return ItemListCheckboxItem(
                presentationData: presentationData,
                title: font.displayName,
                titleFont: RayGramFontManager.shared.previewFont(for: font.postscriptName, size: presentationData.fontSize.itemListBaseFontSize),
                subtitle: font.fileName,
                style: .right,
                color: .accent,
                checked: checked,
                zeroSeparatorInsets: false,
                sectionId: self.section,
                action: {
                    arguments.selectFont(font)
                },
                deleteAction: {
                    arguments.deleteFont(font)
                }
            )
        case let .presetsHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .presetFontItem(_, font, checked, _):
            return ItemListCheckboxItem(
                presentationData: presentationData,
                title: font.displayName,
                titleFont: RayGramFontManager.shared.previewFont(for: font.postscriptName, size: presentationData.fontSize.itemListBaseFontSize),
                style: .right,
                color: .accent,
                checked: checked,
                zeroSeparatorInsets: false,
                sectionId: self.section,
                action: {
                    arguments.selectFont(font)
                }
            )
        case let .footer(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        }
    }
}

public func rayGramFontPickerScreen(context: AccountContext) -> ViewController {
    let updatePromise = ValuePromise<Bool>(true, ignoreRepeated: false)
    
    var presentControllerImpl: ((ViewController, Any?) -> Void)?
    
    let fontManager = RayGramFontManager.shared
    
    let arguments = RayGramFontPickerArguments(
        context: context,
        selectFont: { font in
            fontManager.currentFontPostscriptName = font.postscriptName
            RayGramSettings.customFont = fontManager.currentFontPostscriptName
            let _ = updatePresentationThemeSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                return current.withUpdatedCustomFont(fontManager.currentFontPostscriptName)
            }).start()
            updatePromise.set(true)
        },
        deleteFont: { font in
            let alert = textAlertController(
                context: context,
                title: "Удалить шрифт?",
                text: "Шрифт \"\(font.displayName)\" будет удален из памяти устройства.",
                actions: [
                    TextAlertAction(type: .defaultAction, title: "Отмена", action: {}),
                    TextAlertAction(type: .destructiveAction, title: "Удалить", action: {
                        fontManager.deleteImportedFont(font)
                        RayGramSettings.customFont = fontManager.currentFontPostscriptName
                        let _ = updatePresentationThemeSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                            return current.withUpdatedCustomFont(fontManager.currentFontPostscriptName)
                        }).start()
                        updatePromise.set(true)
                    })
                ]
            )
            presentControllerImpl?(alert, nil)
        },
        importFont: {
            let presentationData = context.sharedContext.currentPresentationData.with { $0 }
            let picker = legacyICloudFilePicker(
                theme: presentationData.theme,
                mode: .import,
                hasMultiselection: false,
                documentTypes: ["public.font", "public.truetype-ttf-font", "public.opentype-font", "public.data"],
                completion: { urls in
                    guard let url = urls.first else { return }
                    if let imported = fontManager.importFont(from: url) {
                        fontManager.currentFontPostscriptName = imported.postscriptName
                        RayGramSettings.customFont = imported.postscriptName
                        let _ = updatePresentationThemeSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                            return current.withUpdatedCustomFont(imported.postscriptName)
                        }).start()
                        updatePromise.set(true)
                    } else {
                        let alert = textAlertController(
                            context: context,
                            title: "Ошибка импорта",
                            text: "Не удалось прочитать или зарегистрировать файл шрифта. Убедитесь, что файл имеет расширение .ttf или .otf.",
                            actions: [TextAlertAction(type: .defaultAction, title: "OK", action: {})]
                        )
                        presentControllerImpl?(alert, nil)
                    }
                }
            )
            presentControllerImpl?(picker, nil)
        }
    )
    
    let signal = combineLatest(queue: .mainQueue(),
        context.sharedContext.presentationData,
        updatePromise.get()
    )
    |> deliverOnMainQueue
    |> map { presentationData, _ -> (ItemListControllerState, (ItemListNodeState, Any)) in
        var entries: [RayGramFontPickerEntry] = []
        
        let currentPostscript = fontManager.currentFontPostscriptName ?? ""
        
        let sample = "Съешь же ещё этих мягких французских булок, да выпей чаю.\nThe quick brown fox jumps over the lazy dog.\n1234567890 !@#$%^&*()"
        
        entries.append(.previewHeader(presentationData.theme, "ПРЕДПРОСМОТР (\(fontManager.currentFontDisplayName.uppercased()))"))
        entries.append(.previewCard(presentationData.theme, sample))
        
        entries.append(.importAction(presentationData.theme, "+ Загрузить шрифт (.ttf, .otf)"))
        
        let imported = fontManager.importedFonts
        if !imported.isEmpty {
            entries.append(.importedHeader(presentationData.theme, "ЗАГРУЖЕННЫЕ ШРИФТЫ"))
            for (idx, font) in imported.enumerated() {
                let isChecked = (font.postscriptName == currentPostscript)
                entries.append(.importedFontItem(presentationData.theme, font, isChecked, idx))
            }
        }
        
        entries.append(.presetsHeader(presentationData.theme, "СИСТЕМНЫЕ ПРЕСЕТЫ"))
        for (idx, font) in fontManager.presetFonts.enumerated() {
            let isChecked = (font.postscriptName == currentPostscript)
            entries.append(.presetFontItem(presentationData.theme, font, isChecked, idx))
        }
        
        entries.append(.footer(presentationData.theme, "Выбранный шрифт применяется ко всем надписям, диалогам и элементам интерфейса RayGram."))
        
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text("Шрифт интерфейса"),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back),
            animateChanges: true
        )
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: entries,
            style: .blocks,
            animateChanges: true
        )
        return (controllerState, (listState, arguments))
    }
    
    let controller = ItemListController(context: context, state: signal)
    presentControllerImpl = { [weak controller] c, a in
        controller?.present(c, in: .window(.root), with: a)
    }
    return controller
}
