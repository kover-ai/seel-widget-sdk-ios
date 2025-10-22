import UIKit

public typealias CoverageInfoFooterClicked = () -> Void

final class CoverageInfoFooter: UIView {
    
    public var optedInClicked: CoverageInfoFooterClicked?
    
    public var noNeedClicked: CoverageInfoFooterClicked?
    
    public var privacyPolicyClicked: CoverageInfoFooterClicked?
    
    public var termsClicked: CoverageInfoFooterClicked?
    
    private lazy var optedInButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
        button.setTitle("Opt-In Now for Full Protection", for: .normal)
        button.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        button.addTarget(self, action: #selector(optedInButtonClicked), for: .touchUpInside)
        button.backgroundColor = UIColor(hex: "#333333")
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return button
    }()
    
    private lazy var noNeedButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("No Need", for: .normal)
        button.setTitleColor(UIColor(hex: "#4F4F4F"), for: .normal)
        button.addTarget(self, action: #selector(noNeedButtonClicked), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
      let view = UIStackView()
      view.axis = .horizontal
      view.spacing = 20
      return view
    }()
    
    private lazy var privacyPolicyButton: UIButton = {
        let button = UIButton(type: .custom)
        let attributedString = NSAttributedString(
            string: "Privacy Policy",
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]
        )
        button.setAttributedTitle(attributedString, for: .normal)
        button.setTitleColor(UIColor(hex: "#5C5F62"), for: .normal)
        button.addTarget(self, action: #selector(privacyPolicyButtonClicked), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return button
    }()
    
    private lazy var termsButton: UIButton = {
        let button = UIButton(type: .custom)
        let attributedString = NSAttributedString(
            string: "Terms of Service",
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]
        )
        button.setAttributedTitle(attributedString, for: .normal)
        button.setTitleColor(UIColor(hex: "#5C5F62"), for: .normal)
        button.addTarget(self, action: #selector(termsButtonClicked), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return button
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        configViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createViews() {
        addSubview(optedInButton)
        addSubview(noNeedButton)
        addSubview(stackView)
        stackView.addArrangedSubview(privacyPolicyButton)
        stackView.addArrangedSubview(termsButton)
    }
    
    func configViews() {
        optedInButton.layer.cornerRadius = 38 / 2
        optedInButton.backgroundColor = UIColor(hex: "#333333")
        
        optedInButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(38)
        }
        noNeedButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(optedInButton.snp.bottom).offset(6)
        }
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(noNeedButton.snp.bottom).offset(24)
            make.bottom.equalToSuperview()
        }
    }
    
    @objc func optedInButtonClicked() {
        if optedInClicked != nil {
            optedInClicked!()
        }
    }
    
    @objc func noNeedButtonClicked() {
        if noNeedClicked != nil {
            noNeedClicked!()
        }
    }
    
    @objc func privacyPolicyButtonClicked() {
        if privacyPolicyClicked != nil {
            privacyPolicyClicked!()
        }
    }
    
    @objc func termsButtonClicked() {
        if termsClicked != nil {
            termsClicked!()
        }
    }
    
}
