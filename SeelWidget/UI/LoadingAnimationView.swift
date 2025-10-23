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
    
    private func setupAnimation() {
        // Set view style
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
        // Configure gradient layer
        gradientLayer.colors = [
            UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.00).cgColor, // #f0f0f0
            UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.00).cgColor, // #e0e0e0
            UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.00).cgColor  // #f0f0f0
        ]
        
        gradientLayer.locations = [0.25, 0.5, 0.75]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        updateGradientFrame()
        
        self.layer.addSublayer(gradientLayer)
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
