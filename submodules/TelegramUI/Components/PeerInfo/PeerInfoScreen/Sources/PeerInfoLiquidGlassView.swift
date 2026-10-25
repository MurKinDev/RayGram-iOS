import Foundation
import UIKit
import Display

public final class PeerInfoLiquidGlassView: UIView {
    public enum MaterialKind {
        case ultraThin
        case thin
    }
    
    private let effectView: UIVisualEffectView
    private let tintOverlayView: UIView
    private var currentIsDark: Bool?
    private var currentMaterialKind: MaterialKind?
    private var currentCornerRadius: CGFloat = 0.0
    
    public init() {
        self.effectView = UIVisualEffectView()
        self.tintOverlayView = UIView()
        self.tintOverlayView.isUserInteractionEnabled = false
        
        super.init(frame: CGRect())
        
        self.clipsToBounds = true
        self.layer.cornerCurve = .continuous
        self.effectView.clipsToBounds = true
        self.effectView.layer.cornerCurve = .continuous
        
        self.addSubview(self.effectView)
        self.addSubview(self.tintOverlayView)
        
        self.layer.borderWidth = UIScreenPixel
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(
        size: CGSize,
        cornerRadius: CGFloat,
        isDark: Bool,
        materialKind: MaterialKind = .thin,
        customTintColor: UIColor? = nil,
        transition: ContainedViewLayoutTransition
    ) {
        if self.currentIsDark != isDark || self.currentMaterialKind != materialKind {
            self.currentIsDark = isDark
            self.currentMaterialKind = materialKind
            
            let style: UIBlurEffect.Style
            if #available(iOS 13.0, *) {
                switch materialKind {
                case .ultraThin:
                    style = isDark ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight
                case .thin:
                    style = isDark ? .systemThinMaterialDark : .systemThinMaterialLight
                }
            } else {
                style = isDark ? .dark : .light
            }
            self.effectView.effect = UIBlurEffect(style: style)
        }
        
        let bounds = CGRect(origin: CGPoint(), size: size)
        transition.updateFrame(view: self.effectView, frame: bounds)
        transition.updateFrame(view: self.tintOverlayView, frame: bounds)
        
        if self.currentCornerRadius != cornerRadius {
            self.currentCornerRadius = cornerRadius
            transition.updateCornerRadius(layer: self.layer, cornerRadius: cornerRadius)
            transition.updateCornerRadius(layer: self.effectView.layer, cornerRadius: cornerRadius)
        }
        
        let borderColor = isDark ? UIColor(white: 1.0, alpha: 0.14) : UIColor(white: 1.0, alpha: 0.45)
        self.layer.borderColor = borderColor.cgColor
        
        if let customTintColor = customTintColor {
            self.tintOverlayView.backgroundColor = customTintColor
        } else {
            self.tintOverlayView.backgroundColor = isDark ? UIColor(white: 1.0, alpha: 0.04) : UIColor(white: 1.0, alpha: 0.16)
        }
    }
}
