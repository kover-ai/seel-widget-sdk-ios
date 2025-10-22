import UIKit
import SnapKit

typealias InfoButtonClickEvent = () -> Void

final class SeelWFPTitleView: UIView {
    
    public var title: String?
    
    public var price: Double?
    
    public var showInfo: Bool = false
    
    public var showPowered: Bool = false
    
    public var infoClicked: InfoButtonClickEvent?
    
    private lazy var contentSV: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6
        return stackView
    }()
    
    private lazy var textSV: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var titleSV: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var detailSV: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var seelIcon = UIImageView(image: UIImage(swName: "seel_icon"))
    private lazy var titleLabel = UILabel(frame: .zero)
    private lazy var priceLable = UILabel(frame: .zero)
    
    private lazy var infoButton: UIButton = {
        let infoButton = UIButton(type: .custom)
        infoButton.setImage(UIImage(swName: "info_black"), for: .normal)
        infoButton.isEnabled = false
        return infoButton
    }()
    
    private lazy var infoExtensionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(infoButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var poweredLabel = UILabel(frame: .zero)
    private lazy var seelWordIcon = UIImageView(image: UIImage(swName: "seel_word"))
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        configViews()
        updateViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createViews() {
        addSubview(contentSV)
        contentSV.addArrangedSubview(seelIcon)
        contentSV.addArrangedSubview(textSV)
        textSV.addArrangedSubview(titleSV)
        textSV.addArrangedSubview(detailSV)
        
        titleSV.addArrangedSubview(titleLabel)
        titleSV.addArrangedSubview(priceLable)
        titleSV.addArrangedSubview(infoButton)
        
        detailSV.addArrangedSubview(poweredLabel)
        detailSV.addArrangedSubview(seelWordIcon)
        
        addSubview(infoExtensionButton)
    }
    
    func configViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = UIColor(hex: "#000000")
        
        priceLable.text = "for -"
        priceLable.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        priceLable.textColor = UIColor(hex: "#000000")
        
        poweredLabel.text = "Powered by".uppercased()
        poweredLabel.font = UIFont.systemFont(ofSize: 7.5, weight: .semibold)
        poweredLabel.textColor = UIColor(hex: "#565656")
        
        contentSV.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        seelIcon.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        infoButton.snp.makeConstraints { make in
            make.width.height.equalTo(12)
        }
        infoExtensionButton.snp.makeConstraints { make in
            make.center.equalTo(infoButton)
            make.width.height.equalTo(36)
        }
    }
    
    func updateViews() {
        titleLabel.text = title
        
        priceLable.isHidden = price == nil
        priceLable.text = "for $\(String(describing: price ?? 0))"
        
        infoButton.isHidden = !showInfo
        
        detailSV.isHidden = !showPowered
    }
    
    @objc func infoButtonClicked() {
        if infoClicked != nil {
            infoClicked!()
        }
    }
    
}
