import UIKit
import SnapKit

final class SeelSwitch: UIView {
    
    public var isOn: Bool = false {
        didSet {
            updateSwitchState()
        }
    }
    
    public var onTintColor: UIColor = UIColor(hex: "#2121C4") {
        didSet {
            updateColors()
        }
    }
    
    public var thumbTintColor: UIColor = .white {
        didSet {
            updateColors()
        }
    }
    
    public var trackTintColor: UIColor = UIColor.lightGray {
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
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            if self.isOn {
                self.thumbLeadingConstraint?.update(offset: 23) // 50 - 24 - 3
                self.trackView.backgroundColor = self.onTintColor
            } else {
                self.thumbLeadingConstraint?.update(offset: 3)
                self.trackView.backgroundColor = self.trackTintColor
            }
            self.layoutIfNeeded()
        })
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
