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
        btn.setImage(UIImage(swName: "checkbox_normal"), for: .normal)
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
    
    private func updateState() {
        button.isSelected = isOn
        button.accessibilityLabel = isOn ? "Selected" : "Unselected"
    }
    
    public func setOn(_ on: Bool) {
        isOn = on
    }
}
