import Foundation
import UIKit
import Display
import AsyncDisplayKit
import AccountContext
import TelegramPresentationData
import ComponentFlow
import GlassBackgroundComponent
import TelegramCore

final class PeerInfoScreenItemSectionContainerNode: ASDisplayNode {
    private let backgroundNode: ASDisplayNode
    private let topSeparatorNode: ASDisplayNode
    private let bottomSeparatorNode: ASDisplayNode
    private let itemContainerNode: ASDisplayNode
    private var liquidGlassView: PeerInfoLiquidGlassView?
    
    private var currentItems: [PeerInfoScreenItem] = []
    var itemNodes: [AnyHashable: PeerInfoScreenItemNode] = [:]
    
    override init() {
        self.backgroundNode = ASDisplayNode()
        self.backgroundNode.isLayerBacked = true
        
        self.topSeparatorNode = ASDisplayNode()
        self.topSeparatorNode.isLayerBacked = true
        
        self.bottomSeparatorNode = ASDisplayNode()
        self.bottomSeparatorNode.isLayerBacked = true
        
        self.itemContainerNode = ASDisplayNode()
        self.itemContainerNode.clipsToBounds = true
        
        super.init()
        
        self.addSubnode(self.backgroundNode)
        self.addSubnode(self.itemContainerNode)
        self.addSubnode(self.topSeparatorNode)
        self.addSubnode(self.bottomSeparatorNode)
    }
    
    func update(context: AccountContext, width: CGFloat, safeInsets: UIEdgeInsets, hasCorners: Bool, presentationData: PresentationData, items: [PeerInfoScreenItem], isLiquidGlass: Bool = false, transition: ContainedViewLayoutTransition) -> CGFloat {
        if isLiquidGlass {
            self.backgroundNode.isHidden = true
            self.topSeparatorNode.isHidden = true
            self.bottomSeparatorNode.isHidden = true
        } else {
            self.backgroundNode.isHidden = false
            self.backgroundNode.backgroundColor = presentationData.theme.list.itemBlocksBackgroundColor
            self.topSeparatorNode.backgroundColor = presentationData.theme.list.itemBlocksSeparatorColor
            self.bottomSeparatorNode.backgroundColor = presentationData.theme.list.itemBlocksSeparatorColor
            
            self.topSeparatorNode.isHidden = hasCorners
            self.bottomSeparatorNode.isHidden = hasCorners
        }
        
        var contentHeight: CGFloat = 0.0
        var contentWithBackgroundHeight: CGFloat = 0.0
        var contentWithBackgroundOffset: CGFloat = 0.0
        
        for i in 0 ..< items.count {
            let item = items[i]
            
            let itemNode: PeerInfoScreenItemNode
            var wasAdded = false
            if let current = self.itemNodes[item.id] {
                itemNode = current
            } else {
                wasAdded = true
                itemNode = item.node()
                self.itemNodes[item.id] = itemNode
                self.itemContainerNode.addSubnode(itemNode)
                itemNode.bringToFrontForHighlight = { [weak self, weak itemNode] in
                    guard let strongSelf = self, let itemNode = itemNode else {
                        return
                    }
                    strongSelf.view.bringSubviewToFront(itemNode.view)
                }
            }
            
            let itemTransition: ContainedViewLayoutTransition = wasAdded ? .immediate : transition
            
            let topItem: PeerInfoScreenItem?
            if i == 0 {
                topItem = nil
            } else if items[i - 1] is PeerInfoScreenHeaderItem {
                topItem = nil
            } else {
                topItem = items[i - 1]
            }
            
            let bottomItem: PeerInfoScreenItem?
            if i == items.count - 1 {
                bottomItem = nil
            } else if items[i + 1] is PeerInfoScreenCommentItem {
                bottomItem = nil
            } else {
                bottomItem = items[i + 1]
            }
            
            let itemHasCorners = isLiquidGlass ? false : hasCorners
            let itemHeight = itemNode.update(context: context, width: width, safeInsets: safeInsets, presentationData: presentationData, item: item, topItem: topItem, bottomItem: bottomItem, hasCorners: itemHasCorners, transition: itemTransition)
            let itemFrame = CGRect(origin: CGPoint(x: 0.0, y: contentHeight), size: CGSize(width: width, height: itemHeight))
            itemTransition.updateFrame(node: itemNode, frame: itemFrame)
            if wasAdded {
                itemNode.alpha = 0.0
                let alphaTransition: ContainedViewLayoutTransition = transition.isAnimated ? .animated(duration: 0.35, curve: .linear) : .immediate
                alphaTransition.updateAlpha(node: itemNode, alpha: 1.0)
            }
            
            if item is PeerInfoScreenCommentItem {
            } else {
                contentWithBackgroundHeight += itemHeight
            }
            contentHeight += itemHeight
            
            if item is PeerInfoScreenHeaderItem {
                contentWithBackgroundOffset = contentHeight
            }
        }
        
        var removeIds: [AnyHashable] = []
        for (id, _) in self.itemNodes {
            if !items.contains(where: { $0.id == id }) {
                removeIds.append(id)
            }
        }
        for id in removeIds {
            if let itemNode = self.itemNodes.removeValue(forKey: id) {
                itemNode.view.superview?.sendSubviewToBack(itemNode.view)
                transition.updateAlpha(node: itemNode, alpha: 0.0, completion: { [weak itemNode] _ in
                    itemNode?.removeFromSupernode()
                })
            }
        }
        
        let backgroundFrame = CGRect(origin: CGPoint(x: 0.0, y: contentWithBackgroundOffset), size: CGSize(width: width, height: max(0.0, contentWithBackgroundHeight - contentWithBackgroundOffset)))
        
        if isLiquidGlass {
            let cornerRadius: CGFloat = 26.0
            let liquidGlassView: PeerInfoLiquidGlassView
            if let current = self.liquidGlassView {
                liquidGlassView = current
            } else {
                liquidGlassView = PeerInfoLiquidGlassView()
                self.liquidGlassView = liquidGlassView
                self.view.insertSubview(liquidGlassView, at: 0)
            }
            if backgroundFrame.height > 0.0 {
                liquidGlassView.isHidden = false
                transition.updateFrame(view: liquidGlassView, frame: backgroundFrame)
                liquidGlassView.update(
                    size: backgroundFrame.size,
                    cornerRadius: cornerRadius,
                    isDark: presentationData.theme.overallDarkAppearance,
                    materialKind: .thin,
                    transition: transition
                )
            } else {
                liquidGlassView.isHidden = true
            }
            
            if hasCorners && backgroundFrame.height > 0.0 {
                let maskPath = UIBezierPath()
                if contentWithBackgroundOffset > 0.0 {
                    maskPath.append(UIBezierPath(rect: CGRect(x: 0.0, y: 0.0, width: width, height: contentWithBackgroundOffset)))
                }
                maskPath.append(UIBezierPath(roundedRect: backgroundFrame, cornerRadius: cornerRadius))
                let maskLayer = CAShapeLayer()
                maskLayer.path = maskPath.cgPath
                self.itemContainerNode.layer.mask = maskLayer
            } else {
                self.itemContainerNode.layer.mask = nil
            }
        } else {
            self.itemContainerNode.layer.mask = nil
            if let liquidGlassView = self.liquidGlassView {
                liquidGlassView.isHidden = true
            }
        }
        
        transition.updateFrame(node: self.itemContainerNode, frame: CGRect(origin: CGPoint(), size: CGSize(width: width, height: contentHeight)))
        transition.updateFrame(node: self.backgroundNode, frame: backgroundFrame)
        transition.updateFrame(node: self.topSeparatorNode, frame: CGRect(origin: CGPoint(x: 0.0, y: contentWithBackgroundOffset - UIScreenPixel), size: CGSize(width: width, height: UIScreenPixel)))
        transition.updateFrame(node: self.bottomSeparatorNode, frame: CGRect(origin: CGPoint(x: 0.0, y: contentWithBackgroundHeight), size: CGSize(width: width, height: UIScreenPixel)))
        
        if contentHeight.isZero || isLiquidGlass {
            transition.updateAlpha(node: self.topSeparatorNode, alpha: 0.0)
            transition.updateAlpha(node: self.bottomSeparatorNode, alpha: 0.0)
        } else {
            transition.updateAlpha(node: self.topSeparatorNode, alpha: 1.0)
            transition.updateAlpha(node: self.bottomSeparatorNode, alpha: 1.0)
        }
        
        return contentHeight
    }
    
    func animateErrorIfNeeded() {
        for (_, itemNode) in self.itemNodes {
            if let itemNode = itemNode as? PeerInfoScreenMultilineInputItemNode {
                itemNode.animateErrorIfNeeded()
            }
        }
    }
}
