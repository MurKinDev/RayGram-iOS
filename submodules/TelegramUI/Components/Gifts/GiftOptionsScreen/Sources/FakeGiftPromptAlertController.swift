import Foundation
import UIKit
import AsyncDisplayKit
import Display
import SwiftSignalKit
import TelegramCore
import Postbox
import TelegramPresentationData
import PresentationDataUtils
import AccountContext
import OverlayStatusController
import UndoUI

public func extractGiftSlug(from input: String) -> String {
    var text = input.trimmingCharacters(in: .whitespacesAndNewlines)
    if text.contains("slug=") {
        if let range = text.range(of: "slug=") {
            text = String(text[range.upperBound...])
        }
    } else if let range = text.range(of: "/nft/") {
        text = String(text[range.upperBound...])
    } else if let range = text.range(of: "nft/") {
        text = String(text[range.upperBound...])
    }
    
    if let queryIndex = text.firstIndex(of: "?") {
        text = String(text[..<queryIndex])
    }
    if let fragmentIndex = text.firstIndex(of: "#") {
        text = String(text[..<fragmentIndex])
    }
    if let slashIndex = text.firstIndex(of: "/") {
        text = String(text[..<slashIndex])
    }
    return text.trimmingCharacters(in: .whitespacesAndNewlines)
}

public func sendFakeStarGift(
    context: AccountContext,
    peerId: EnginePeer.Id,
    gift: StarGift,
    isFromSelf: Bool,
    caption: String?
) {
    let _ = (context.account.postbox.transaction { transaction -> Void in
        let authorId: EnginePeer.Id = isFromSelf ? context.account.peerId : peerId
        let flags: StoreMessageFlags = isFromSelf ? StoreMessageFlags([.TopIndexable]) : StoreMessageFlags([.TopIndexable, .Incoming])
        let timestamp = Int32(Date().timeIntervalSince1970)
        
        let mediaAction: TelegramMediaAction
        switch gift {
        case .unique:
            mediaAction = TelegramMediaAction(action: .starGiftUnique(
                gift: gift,
                isUpgrade: false,
                isTransferred: false,
                savedToProfile: true,
                canExportDate: nil,
                transferStars: nil,
                isRefunded: false,
                isPrepaidUpgrade: false,
                peerId: peerId,
                senderId: authorId,
                savedId: nil,
                resaleAmount: nil,
                canTransferDate: nil,
                canResaleDate: nil,
                dropOriginalDetailsStars: nil,
                assigned: false,
                fromOffer: false,
                canCraftAt: nil,
                isCrafted: false,
                text: caption?.isEmpty == false ? caption : nil,
                entities: nil,
                nameHidden: false
            ))
        case let .generic(genericGift):
            mediaAction = TelegramMediaAction(action: .starGift(
                gift: gift,
                convertStars: genericGift.convertStars,
                text: caption?.isEmpty == false ? caption : nil,
                entities: nil,
                nameHidden: false,
                savedToProfile: true,
                converted: false,
                upgraded: false,
                canUpgrade: false,
                upgradeStars: nil,
                isRefunded: false,
                isPrepaidUpgrade: false,
                upgradeMessageId: nil,
                peerId: peerId,
                senderId: authorId,
                savedId: nil,
                prepaidUpgradeHash: nil,
                giftMessageId: nil,
                upgradeSeparate: false,
                isAuctionAcquired: false,
                toPeerId: peerId,
                number: nil
            ))
        }
        
        let storeMessage = StoreMessage(
            peerId: peerId,
            namespace: Namespaces.Message.Cloud,
            customStableId: nil,
            globallyUniqueId: nil,
            groupingKey: nil,
            threadId: nil,
            timestamp: timestamp,
            flags: flags,
            tags: [],
            globalTags: [],
            localTags: [],
            forwardInfo: nil,
            authorId: authorId,
            text: "",
            attributes: [],
            media: [mediaAction]
        )
        
        let _ = transaction.addMessages([storeMessage], location: .UpperHistoryBlock)
    }).startStandalone()
}

private final class FakeGiftInputFieldNode: ASDisplayNode, ASEditableTextNodeDelegate {
    private var theme: PresentationTheme
    private let backgroundNode: ASImageNode
    private let textInputNode: EditableTextNode
    private let placeholderNode: ASTextNode
    private let pasteButtonNode: HighlightableButtonNode?
    
    private let characterLimit: Int
    private let inputInsets: UIEdgeInsets
    
    var text: String {
        get {
            return self.textInputNode.attributedText?.string ?? ""
        }
        set {
            self.textInputNode.attributedText = NSAttributedString(string: newValue, font: Font.regular(14.0), textColor: self.theme.actionSheet.inputTextColor)
            self.placeholderNode.isHidden = !newValue.isEmpty
        }
    }
    
    var placeholder: String = "" {
        didSet {
            self.placeholderNode.attributedText = NSAttributedString(string: self.placeholder, font: Font.regular(14.0), textColor: self.theme.actionSheet.inputPlaceholderColor)
        }
    }
    
    init(theme: PresentationTheme, placeholder: String, characterLimit: Int = 250, hasPasteButton: Bool = false) {
        self.theme = theme
        self.characterLimit = characterLimit
        
        let rightInset: CGFloat = hasPasteButton ? 60.0 : 12.0
        self.inputInsets = UIEdgeInsets(top: 8.0, left: 12.0, bottom: 8.0, right: rightInset)
        
        self.backgroundNode = ASImageNode()
        self.backgroundNode.isLayerBacked = true
        self.backgroundNode.displaysAsynchronously = false
        self.backgroundNode.displayWithoutProcessing = true
        self.backgroundNode.image = generateStretchableFilledCircleImage(diameter: 12.0, color: theme.actionSheet.inputHollowBackgroundColor, strokeColor: theme.actionSheet.inputBorderColor, strokeWidth: 1.0)
        
        self.textInputNode = EditableTextNode()
        self.textInputNode.typingAttributes = [
            NSAttributedString.Key.font.rawValue: Font.regular(14.0),
            NSAttributedString.Key.foregroundColor.rawValue: theme.actionSheet.inputTextColor
        ]
        self.textInputNode.clipsToBounds = true
        self.textInputNode.textContainerInset = UIEdgeInsets(top: self.inputInsets.top, left: self.inputInsets.left, bottom: self.inputInsets.bottom, right: self.inputInsets.right)
        self.textInputNode.keyboardAppearance = theme.rootController.keyboardColor.keyboardAppearance
        self.textInputNode.keyboardType = .default
        self.textInputNode.autocapitalizationType = .none
        self.textInputNode.returnKeyType = .done
        self.textInputNode.autocorrectionType = .no
        self.textInputNode.tintColor = theme.actionSheet.controlAccentColor
        
        self.placeholderNode = ASTextNode()
        self.placeholderNode.isUserInteractionEnabled = false
        self.placeholderNode.displaysAsynchronously = false
        self.placeholderNode.attributedText = NSAttributedString(string: placeholder, font: Font.regular(14.0), textColor: self.theme.actionSheet.inputPlaceholderColor)
        
        if hasPasteButton {
            let button = HighlightableButtonNode()
            let pasteTitle = (theme.actionSheet.backgroundType == .light ? "Вставить" : "Вставить")
            button.setTitle(pasteTitle, with: Font.medium(12.0), with: theme.actionSheet.controlAccentColor, for: .normal)
            button.hitTestSlop = UIEdgeInsets(top: -5.0, left: -5.0, bottom: -5.0, right: -5.0)
            self.pasteButtonNode = button
        } else {
            self.pasteButtonNode = nil
        }
        
        super.init()
        
        self.textInputNode.delegate = self
        
        self.addSubnode(self.backgroundNode)
        self.addSubnode(self.textInputNode)
        self.addSubnode(self.placeholderNode)
        if let pasteButtonNode = self.pasteButtonNode {
            self.addSubnode(pasteButtonNode)
            pasteButtonNode.addTarget(self, action: #selector(self.pastePressed), forControlEvents: .touchUpInside)
        }
    }
    
    @objc private func pastePressed() {
        if let string = UIPasteboard.general.string {
            self.text = string
        }
    }
    
    func editableTextNode(_ editableTextNode: ASEditableTextNode, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = (editableTextNode.attributedText?.string ?? "") as NSString
        let resultText = currentText.replacingCharacters(in: range, with: text)
        if resultText.count > self.characterLimit {
            return false
        }
        if text == "\n" {
            self.deactivateInput()
            return false
        }
        self.placeholderNode.isHidden = !resultText.isEmpty
        return true
    }
    
    func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
        self.placeholderNode.isHidden = !(editableTextNode.attributedText?.string.isEmpty ?? true)
    }
    
    func updateTheme(theme: PresentationTheme) {
        self.theme = theme
        self.backgroundNode.image = generateStretchableFilledCircleImage(diameter: 12.0, color: theme.actionSheet.inputHollowBackgroundColor, strokeColor: theme.actionSheet.inputBorderColor, strokeWidth: 1.0)
        self.textInputNode.typingAttributes = [
            NSAttributedString.Key.font.rawValue: Font.regular(14.0),
            NSAttributedString.Key.foregroundColor.rawValue: theme.actionSheet.inputTextColor
        ]
        self.textInputNode.keyboardAppearance = theme.rootController.keyboardColor.keyboardAppearance
        self.textInputNode.tintColor = theme.actionSheet.controlAccentColor
        self.placeholderNode.attributedText = NSAttributedString(string: self.placeholder, font: Font.regular(14.0), textColor: self.theme.actionSheet.inputPlaceholderColor)
        self.pasteButtonNode?.setTitle("Вставить", with: Font.medium(12.0), with: theme.actionSheet.controlAccentColor, for: .normal)
    }
    
    func updateLayout(width: CGFloat) -> CGFloat {
        let height: CGFloat = 38.0
        let backgroundFrame = CGRect(x: 16.0, y: 0.0, width: width - 32.0, height: height)
        self.backgroundNode.frame = backgroundFrame
        self.textInputNode.frame = backgroundFrame
        
        let placeholderSize = self.placeholderNode.measure(CGSize(width: backgroundFrame.width - self.inputInsets.left - self.inputInsets.right, height: height))
        self.placeholderNode.frame = CGRect(origin: CGPoint(x: backgroundFrame.minX + self.inputInsets.left, y: backgroundFrame.minY + floor((height - placeholderSize.height) * 0.5)), size: placeholderSize)
        
        if let pasteButtonNode = self.pasteButtonNode {
            let buttonSize = pasteButtonNode.measure(CGSize(width: 80.0, height: height))
            pasteButtonNode.frame = CGRect(origin: CGPoint(x: backgroundFrame.maxX - buttonSize.width - 10.0, y: backgroundFrame.minY + floor((height - buttonSize.height) * 0.5)), size: buttonSize)
        }
        
        return height
    }
    
    func activateInput() {
        self.textInputNode.becomeFirstResponder()
    }
    
    func deactivateInput() {
        self.textInputNode.resignFirstResponder()
    }
}

private final class FakeGiftPromptAlertContentNode: AlertContentNode {
    private let context: AccountContext
    private let peerId: EnginePeer.Id
    private let peer: EnginePeer?
    private let presentationData: PresentationData
    private let availableStarGifts: [StarGift]
    private var alertTheme: AlertControllerTheme
    
    private let titleNode: ASTextNode
    private let subtitleNode: ASTextNode
    private let linkFieldNode: FakeGiftInputFieldNode
    private let segmentedControl: UISegmentedControl
    private let captionFieldNode: FakeGiftInputFieldNode
    
    private let actionNodesSeparator: ASDisplayNode
    private let actionNodes: [TextAlertContentActionNode]
    private let actionVerticalSeparators: [ASDisplayNode]
    
    private let disposable = MetaDisposable()
    private var validLayout: CGSize?
    
    var dismissAlert: (() -> Void)?
    var onSuccess: ((StarGift, Bool, String?) -> Void)?
    
    private var isRussian: Bool {
        return self.presentationData.strings.primaryComponent.languageCode == "ru"
    }
    
    init(
        context: AccountContext,
        peerId: EnginePeer.Id,
        peer: EnginePeer?,
        availableStarGifts: [StarGift],
        presentationData: PresentationData,
        theme: AlertControllerTheme,
        actions: [TextAlertAction]
    ) {
        self.context = context
        self.peerId = peerId
        self.peer = peer
        self.availableStarGifts = availableStarGifts
        self.presentationData = presentationData
        self.alertTheme = theme
        
        self.titleNode = ASTextNode()
        self.titleNode.isUserInteractionEnabled = false
        self.titleNode.displaysAsynchronously = false
        
        self.subtitleNode = ASTextNode()
        self.subtitleNode.isUserInteractionEnabled = false
        self.subtitleNode.displaysAsynchronously = false
        
        let isRu = presentationData.strings.primaryComponent.languageCode == "ru"
        let linkPlaceholder = isRu ? "Ссылка на NFT (t.me/nft/...) или slug" : "NFT link (t.me/nft/...) or slug"
        self.linkFieldNode = FakeGiftInputFieldNode(theme: presentationData.theme, placeholder: linkPlaceholder, characterLimit: 300, hasPasteButton: true)
        
        let selfTitle = isRu ? "От меня" : "From Me"
        let peerName = peer?.compactDisplayTitle
        let partnerTitle: String
        if let peerName, !peerName.isEmpty {
            partnerTitle = isRu ? "От \(peerName)" : "From \(peerName)"
        } else {
            partnerTitle = isRu ? "От собеседника" : "From Partner"
        }
        
        let items = [selfTitle, partnerTitle]
        self.segmentedControl = UISegmentedControl(items: items)
        self.segmentedControl.selectedSegmentIndex = 0
        if peerId == context.account.peerId {
            self.segmentedControl.setEnabled(false, forSegmentAt: 1)
        }
        
        let captionPlaceholder = isRu ? "Подпись к подарку (необязательно)" : "Gift caption (optional)"
        self.captionFieldNode = FakeGiftInputFieldNode(theme: presentationData.theme, placeholder: captionPlaceholder, characterLimit: 200, hasPasteButton: false)
        
        self.actionNodesSeparator = ASDisplayNode()
        self.actionNodesSeparator.isLayerBacked = true
        
        self.actionNodes = actions.map { action -> TextAlertContentActionNode in
            return TextAlertContentActionNode(theme: theme, action: action)
        }
        
        var actionVerticalSeparators: [ASDisplayNode] = []
        if actions.count > 1 {
            for _ in 0 ..< actions.count - 1 {
                let separatorNode = ASDisplayNode()
                separatorNode.isLayerBacked = true
                actionVerticalSeparators.append(separatorNode)
            }
        }
        self.actionVerticalSeparators = actionVerticalSeparators
        
        super.init()
        
        self.addSubnode(self.titleNode)
        self.addSubnode(self.subtitleNode)
        self.addSubnode(self.linkFieldNode)
        self.addSubnode(self.captionFieldNode)
        
        self.addSubnode(self.actionNodesSeparator)
        for actionNode in self.actionNodes {
            self.addSubnode(actionNode)
        }
        for separatorNode in self.actionVerticalSeparators {
            self.addSubnode(separatorNode)
        }
        
        // Auto-fill from clipboard if it's an NFT link
        if let clipboard = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines),
           clipboard.contains("nft/") || clipboard.contains("/nft/") {
            self.linkFieldNode.text = clipboard
        }
        
        self.updateTheme(theme)
    }
    
    deinit {
        self.disposable.dispose()
    }
    
    override func didLoad() {
        super.didLoad()
        self.view.addSubview(self.segmentedControl)
    }
    
    override func updateTheme(_ theme: AlertControllerTheme) {
        self.alertTheme = theme
        
        let isRu = self.isRussian
        let titleString = isRu ? "Отправить фейк подарок" : "Send Fake Gift"
        let subtitleString = isRu ? "Укажите ссылку на подарок или NFT, выберите отправителя и добавьте подпись." : "Enter a gift or NFT link, select the sender, and add an optional message."
        
        self.titleNode.attributedText = NSAttributedString(string: titleString, font: Font.bold(17.0), textColor: theme.primaryColor, paragraphAlignment: .center)
        self.subtitleNode.attributedText = NSAttributedString(string: subtitleString, font: Font.regular(13.0), textColor: theme.secondaryColor, paragraphAlignment: .center)
        
        self.linkFieldNode.updateTheme(theme: self.presentationData.theme)
        self.captionFieldNode.updateTheme(theme: self.presentationData.theme)
        
        if #available(iOS 13.0, *) {
            self.segmentedControl.overrideUserInterfaceStyle = theme.backgroundType == .light ? .light : .dark
        }
        self.segmentedControl.selectedSegmentTintColor = theme.accentColor
        self.segmentedControl.backgroundColor = theme.separatorColor.withAlphaComponent(0.2)
        self.segmentedControl.setTitleTextAttributes([
            .foregroundColor: theme.primaryColor,
            .font: Font.medium(13.0)
        ], for: .normal)
        self.segmentedControl.setTitleTextAttributes([
            .foregroundColor: theme.contrastColor,
            .font: Font.semibold(13.0)
        ], for: .selected)
        
        self.actionNodesSeparator.backgroundColor = theme.separatorColor
        for actionNode in self.actionNodes {
            actionNode.updateTheme(theme)
        }
        for separatorNode in self.actionVerticalSeparators {
            separatorNode.backgroundColor = theme.separatorColor
        }
        
        if let size = self.validLayout {
            _ = self.updateLayout(size: size, transition: .immediate)
        }
    }
    
    override func updateLayout(size: CGSize, transition: ContainedViewLayoutTransition) -> CGSize {
        var size = size
        size.width = min(size.width, 290.0)
        let measureSize = CGSize(width: size.width - 24.0 * 2.0, height: CGFloat.greatestFiniteMagnitude)
        self.validLayout = size
        
        var originY: CGFloat = 18.0
        
        let titleSize = self.titleNode.measure(measureSize)
        self.titleNode.frame = CGRect(origin: CGPoint(x: floor((size.width - titleSize.width) * 0.5), y: originY), size: titleSize)
        originY += titleSize.height + 6.0
        
        let subtitleSize = self.subtitleNode.measure(measureSize)
        self.subtitleNode.frame = CGRect(origin: CGPoint(x: floor((size.width - subtitleSize.width) * 0.5), y: originY), size: subtitleSize)
        originY += subtitleSize.height + 14.0
        
        let linkHeight = self.linkFieldNode.updateLayout(width: size.width)
        self.linkFieldNode.frame = CGRect(x: 0.0, y: originY, width: size.width, height: linkHeight)
        originY += linkHeight + 10.0
        
        let segmentedFrame = CGRect(x: 16.0, y: originY, width: size.width - 32.0, height: 32.0)
        self.segmentedControl.frame = segmentedFrame
        originY += 32.0 + 10.0
        
        let captionHeight = self.captionFieldNode.updateLayout(width: size.width)
        self.captionFieldNode.frame = CGRect(x: 0.0, y: originY, width: size.width, height: captionHeight)
        originY += captionHeight + 16.0
        
        let actionButtonHeight: CGFloat = 44.0
        let actionsHeight: CGFloat = actionButtonHeight
        let resultHeight = originY + actionsHeight
        let resultSize = CGSize(width: size.width, height: resultHeight)
        
        self.actionNodesSeparator.frame = CGRect(origin: CGPoint(x: 0.0, y: resultHeight - actionsHeight - UIScreenPixel), size: CGSize(width: size.width, height: UIScreenPixel))
        
        let actionWidth = floor(size.width / CGFloat(self.actionNodes.count))
        var actionOffset: CGFloat = 0.0
        for i in 0 ..< self.actionNodes.count {
            let actionNode = self.actionNodes[i]
            let currentWidth = (i == self.actionNodes.count - 1) ? (size.width - actionOffset) : actionWidth
            actionNode.frame = CGRect(origin: CGPoint(x: actionOffset, y: resultHeight - actionsHeight), size: CGSize(width: currentWidth, height: actionButtonHeight))
            
            if i < self.actionVerticalSeparators.count {
                let separator = self.actionVerticalSeparators[i]
                separator.frame = CGRect(origin: CGPoint(x: actionOffset + currentWidth - UIScreenPixel, y: resultHeight - actionsHeight), size: CGSize(width: UIScreenPixel, height: actionButtonHeight))
            }
            actionOffset += currentWidth
        }
        
        return resultSize
    }
    
    func submit() {
        let linkText = self.linkFieldNode.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let captionText = self.captionFieldNode.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let isFromSelf = self.segmentedControl.selectedSegmentIndex == 0
        let slug = extractGiftSlug(from: linkText)
        
        let isRu = self.isRussian
        
        if slug.isEmpty {
            if let firstGift = self.availableStarGifts.first {
                sendFakeStarGift(
                    context: self.context,
                    peerId: self.peerId,
                    gift: firstGift,
                    isFromSelf: isFromSelf,
                    caption: captionText.isEmpty ? nil : captionText
                )
                self.dismissAlert?()
                self.onSuccess?(firstGift, isFromSelf, captionText.isEmpty ? nil : captionText)
            } else {
                let text = isRu ? "Пожалуйста, укажите ссылку на подарок или его slug (например, MightyArm-1486)." : "Please enter a gift link or slug (e.g. MightyArm-1486)."
                let errorAlert = textAlertController(
                    context: self.context,
                    title: nil,
                    text: text,
                    actions: [TextAlertAction(type: .defaultAction, title: "OK", action: {})]
                )
                (self.view.window?.rootViewController as? ViewController)?.present(errorAlert, in: .window(.root))
            }
            return
        }
        
        // Show status loading overlay
        let statusController = OverlayStatusController(theme: self.presentationData.theme, type: .loading(cancelled: nil))
        (self.view.window?.rootViewController as? ViewController)?.present(statusController, in: .window(.root))
        
        self.disposable.set((self.context.engine.payments.getUniqueStarGift(slug: slug)
        |> deliverOnMainQueue).start(next: { [weak self, weak statusController] uniqueGift in
            statusController?.dismiss()
            guard let self else { return }
            let gift = StarGift.unique(uniqueGift)
            sendFakeStarGift(
                context: self.context,
                peerId: self.peerId,
                gift: gift,
                isFromSelf: isFromSelf,
                caption: captionText.isEmpty ? nil : captionText
            )
            self.dismissAlert?()
            self.onSuccess?(gift, isFromSelf, captionText.isEmpty ? nil : captionText)
        }, error: { [weak self, weak statusController] _ in
            statusController?.dismiss()
            guard let self else { return }
            let errorText = isRu ? "Не удалось загрузить NFT подарок по этой ссылке. Убедитесь, что ссылка или slug правильные (например, https://t.me/nft/MightyArm-1486)." : "Could not load NFT gift with this slug. Please verify the link or slug (e.g. https://t.me/nft/MightyArm-1486)."
            let errorAlert = textAlertController(
                context: self.context,
                title: nil,
                text: errorText,
                actions: [TextAlertAction(type: .defaultAction, title: "OK", action: {})]
            )
            (self.view.window?.rootViewController as? ViewController)?.present(errorAlert, in: .window(.root))
        }))
    }
}

public func fakeGiftPromptAlertController(
    context: AccountContext,
    peerId: EnginePeer.Id,
    peer: EnginePeer?,
    availableStarGifts: [StarGift],
    presentationData: PresentationData,
    onSuccess: @escaping (StarGift, Bool, String?) -> Void
) -> AlertController {
    let theme = AlertControllerTheme(presentationData: presentationData)
    let isRu = presentationData.strings.primaryComponent.languageCode == "ru"
    
    var contentNode: FakeGiftPromptAlertContentNode?
    
    let actions: [TextAlertAction] = [
        TextAlertAction(type: .genericAction, title: isRu ? "Отмена" : "Cancel", action: {
            contentNode?.dismissAlert?()
        }),
        TextAlertAction(type: .defaultAction, title: isRu ? "Отправить" : "Send", action: {
            contentNode?.submit()
        })
    ]
    
    let node = FakeGiftPromptAlertContentNode(
        context: context,
        peerId: peerId,
        peer: peer,
        availableStarGifts: availableStarGifts,
        presentationData: presentationData,
        theme: theme,
        actions: actions
    )
    contentNode = node
    
    let controller = AlertController(theme: theme, contentNode: node)
    node.dismissAlert = { [weak controller] in
        controller?.dismissAnimated()
    }
    node.onSuccess = onSuccess
    return controller
}
