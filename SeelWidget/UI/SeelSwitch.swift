import UIKit
import SnapKit

final class SeelSwitch: UIView {
    
    public var isOn: Bool = false {
        didSet {
            updateSwitchState()
        }
    }
    
    public var onTintColor: UIColor = seelTheme.primary {
        didSet {
            updateColors()
        }
    }
    
    public var thumbTintColor: UIColor = seelTheme.toggleThumb {
        didSet {
            updateColors()
        }
    }
    
    public var trackTintColor: UIColor = seelTheme.toggleTrack {
        didSet {
            updateColors()
        }
    }
    
    public var onValueChanged: ((Bool) -> Void)?
    
    // Track (background)
    private lazy var trackView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = trackTintColor
        return view
    }()
    
    // Thumb (sliding circle)
    private lazy var thumbView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = thumbTintColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 3
        return view
    }()
    
    // Thumb constraint for animation
    private var thumbLeadingConstraint: Constraint?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 50, height: 30)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        configureAccessibility()
        addSubview(trackView)
        addSubview(thumbView)
        
        trackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        
        thumbView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
            thumbLeadingConstraint = make.leading.equalToSuperview().offset(3).constraint
        }
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(switchTapped))
        addGestureRecognizer(tapGesture)
        
        updateSwitchState()
    }
    
    @objc private func switchTapped() {
        toggle()
    }
    
    public func toggle() {
        isOn.toggle()
        onValueChanged?(isOn)
    }
    
    private func updateSwitchState() {
        let apply = {
            if self.isOn {
                self.thumbLeadingConstraint?.update(offset: 23) // 50 - 24 - 3
                self.trackView.backgroundColor = self.onTintColor
            } else {
                self.thumbLeadingConstraint?.update(offset: 3)
                self.trackView.backgroundColor = self.trackTintColor
            }
            self.layoutIfNeeded()
        }

        updateAccessibilityState()

        // 「减弱动态效果」下直接落位，不做滑动动画。
        if SeelA11y.isReduceMotionEnabled {
            apply()
            return
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: apply)
    }

    // MARK: - Accessibility

    /// 这是个纯自绘的开关，不继承 UISwitch，所有语义都得自己给，
    /// 否则 VoiceOver 既读不出状态也无法激活它。
    private func configureAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityHint = seelText(.a11yToggleHint)
        updateAccessibilityState()
    }

    private func updateAccessibilityState() {
        accessibilityValue = isOn ? seelText(.a11yOn) : seelText(.a11yOff)
        if isOn {
            accessibilityTraits.insert(.selected)
        } else {
            accessibilityTraits.remove(.selected)
        }
    }

    public override func accessibilityActivate() -> Bool {
        toggle()
        return true
    }
    
    private func updateColors() {
        if isOn {
            trackView.backgroundColor = onTintColor
        } else {
            trackView.backgroundColor = trackTintColor
        }
        thumbView.backgroundColor = thumbTintColor
    }
    
    public func setOn(_ on: Bool, animated: Bool = true) {
        if animated {
            isOn = on
        } else {
            isOn = on
            updateSwitchState()
        }
    }
}
