import UIKit
import SnapKit

final class SeelCheckbox: UIView {
    
    public var isOn: Bool = false {
        didSet {
            guard oldValue != isOn else { return }
            updateState()
        }
    }
    
    public var onValueChanged: ((Bool) -> Void)?
    
    private lazy var button: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(seelThemedIcon("checkbox_normal"), for: .normal)
        btn.setImage(UIImage(swName: "checkbox_selected"), for: .selected)
        btn.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        btn.isAccessibilityElement = true
        btn.accessibilityTraits = .button
        return btn
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 44, height: 44)
    }
    
    private func setupUI() {
        addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(44)
        }
        self.snp.makeConstraints { make in
            make.width.height.equalTo(44)
        }
        button.imageView?.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        updateState()
    }
    
    @objc private func tapped() {
        isOn.toggle()
        onValueChanged?(isOn)
    }
    
    /// 勾选框描述的对象，用作 VoiceOver 的朗读内容（如 "Worry-Free Purchase®"）。
    /// 不设时退回通用的「已选中 / 未选中」。
    public var accessibilityTitle: String? {
        didSet { updateState() }
    }

    private func updateState() {
        button.isSelected = isOn
        // label 说「是什么」，状态交给 traits/value —— 否则读屏只会念出
        // 一句孤零零的 "Selected"，用户并不知道选中的是哪一项。
        button.accessibilityLabel = accessibilityTitle ?? (isOn ? seelText(.selected) : seelText(.unselected))
        button.accessibilityValue = accessibilityTitle == nil ? nil : (isOn ? seelText(.a11yOn) : seelText(.a11yOff))
        button.accessibilityHint = seelText(.a11yToggleHint)
        if isOn {
            button.accessibilityTraits.insert(.selected)
        } else {
            button.accessibilityTraits.remove(.selected)
        }
    }
    
    public func setOn(_ on: Bool) {
        isOn = on
    }
}
