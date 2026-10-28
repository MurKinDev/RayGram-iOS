import Foundation
import UIKit
import AsyncDisplayKit
import Display
import TelegramPresentationData
import AccountContext

final class PeerInfoScreenCreatorBadgeItem: PeerInfoScreenItem {
    let id: AnyHashable
    let text: String
    
    init(id: AnyHashable, text: String = "Creator of RayGram") {
        self.id = id
        self.text = text
    }
    
    func node() -> PeerInfoScreenItemNode {
        return PeerInfoScreenCreatorBadgeItemNode()
    }
}

private final class PeerInfoScreenCreatorBadgeItemNode: PeerInfoScreenItemNode {
    private let containerNode: ASDisplayNode
    private let textNode: ImmediateTextNode
    
    override init() {
        self.containerNode = ASDisplayNode()
        self.containerNode.clipsToBounds = true
        self.containerNode.cornerRadius = 12.0
        self.containerNode.backgroundColor = UIColor(rgb: 0x8B5CF6).withAlphaComponent(0.22)
        
        self.textNode = ImmediateTextNode()
        self.textNode.displaysAsynchronously = false
        self.textNode.isUserInteractionEnabled = false
        
        super.init()
        
        self.containerNode.addSubnode(self.textNode)
        self.addSubnode(self.containerNode)
    }
    
    override func update(context: AccountContext, width: CGFloat, safeInsets: UIEdgeInsets, presentationData: PresentationData, item: PeerInfoScreenItem, topItem: PeerInfoScreenItem?, bottomItem: PeerInfoScreenItem?, hasCorners: Bool, transition: ContainedViewLayoutTransition) -> CGFloat {
        guard let item = item as? PeerInfoScreenCreatorBadgeItem else {
            return 0.0
        }
        
        let isDark = presentationData.theme.overallDarkAppearance
        self.containerNode.backgroundColor = UIColor(rgb: 0x8B5CF6).withAlphaComponent(isDark ? 0.22 : 0.14)
        
        self.textNode.attributedText = NSAttributedString(
            string: item.text,
            font: Font.bold(12.0),
            textColor: isDark ? UIColor(rgb: 0xD8B4FE) : UIColor(rgb: 0x7C3AED)
        )
        let textPaddingH: CGFloat = 12.0
        let textPaddingV: CGFloat = 5.0
        let textSize = self.textNode.updateLayout(CGSize(width: width - (safeInsets.left + safeInsets.right + 32.0), height: 30.0))
        let badgeSize = CGSize(width: textSize.width + textPaddingH * 2.0, height: textSize.height + textPaddingV * 2.0)
        
        let topInset: CGFloat = 4.0
        let bottomInset: CGFloat = 4.0
        let badgeOriginX = floorToScreenPixels((width - badgeSize.width) / 2.0)
        let badgeFrame = CGRect(origin: CGPoint(x: badgeOriginX, y: topInset), size: badgeSize)
        
        transition.updateFrame(node: self.containerNode, frame: badgeFrame)
        self.textNode.frame = CGRect(origin: CGPoint(x: textPaddingH, y: textPaddingV), size: textSize)
        
        return badgeSize.height + topInset + bottomInset
    }
}
