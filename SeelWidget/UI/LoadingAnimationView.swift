import UIKit

class LoadingAnimationView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAnimation()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAnimation()
    }
    
    private var themeObserver: SeelUIRefreshObserver?

    private func setupAnimation() {
        // 加载占位是纯视觉的，读屏应该跳过。
        markAsSeelDecoration()

        // Set view style
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
        updateGradientColors()
        
        gradientLayer.locations = [0.25, 0.5, 0.75]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        updateGradientFrame()
        
        self.layer.addSublayer(gradientLayer)
        
        themeObserver = SeelUIRefreshObserver { [weak self] in self?.updateGradientColors() }
    }
    
    /// CAGradientLayer 只吃 CGColor，动态色必须按当前 trait 解析后再写入，
    /// 并在外观变化时重新写一次。
    private func updateGradientColors() {
        let base = seelTheme.skeletonBase.resolvedSeelColor(for: traitCollection).cgColor
        let highlight = seelTheme.skeletonHighlight.resolvedSeelColor(for: traitCollection).cgColor
        gradientLayer.colors = [base, highlight, base]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateGradientColors()
    }
    
    private func updateGradientFrame() {
        // Make gradient layer wider to prevent white gaps
        gradientLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: self.bounds.width * 3,
            height: self.bounds.height
        )
    }
    
    // Start loading animation
    func startAnimating() {
        // 无限循环的位移动画正是「减弱动态效果」要关掉的东西，
        // 静态的骨架块同样能表达"加载中"。
        guard !SeelA11y.isReduceMotionEnabled else {
            stopAnimating()
            return
        }
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -self.bounds.width * 2
        animation.toValue = 0
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        gradientLayer.add(animation, forKey: "loadingAnimation")
    }
    
    // Stop loading animation
    func stopAnimating() {
        gradientLayer.removeAnimation(forKey: "loadingAnimation")
    }
    
    // Check if animation is running
    var isAnimating: Bool {
        return gradientLayer.animation(forKey: "loadingAnimation") != nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }
}
