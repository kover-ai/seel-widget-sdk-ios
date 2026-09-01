import UIKit
import SnapKit

final class CoverageTitleView: UIView {
    
    public var title: String?
    
    public var price: Double?
    
    public var currency: String?
    
    private lazy var contentSV: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 4
        return sv
    }()
    
    private lazy var seelIcon = UIImageView(image: UIImage(swName: "seel_icon"))
    private lazy var titleLabel = UILabel(frame: .zero)
    
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
        contentSV.addArrangedSubview(titleLabel)
    }
    
    func configViews() {
        titleLabel.font = SeelFont.scaled(21, weight: .semibold)
        titleLabel.textColor = seelTheme.primaryText
        titleLabel.adjustsFontSizeToFitWidth = true
        
        contentSV.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        seelIcon.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
    }
    
    func updateViews() {
        let localizedTitle = seelServerText(title) ?? ""
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: SeelFont.scaled(21, weight: .semibold),
            .foregroundColor: seelTheme.primaryText,
        ]
        guard let price = price else {
            titleLabel.attributedText = NSAttributedString(string: localizedTitle, attributes: titleAttributes)
            return
        }
        let priceAttributes: [NSAttributedString.Key: Any] = [
            .font: SeelFont.scaled(16, weight: .regular),
            .foregroundColor: seelTheme.primaryText,
        ]
        titleLabel.attributedText = seelComposedText(
            .wfpTitle,
            segments: [
                "title": (localizedTitle, titleAttributes),
                "price": (formatMoney(price, currency: currency), priceAttributes),
            ],
            defaultAttributes: priceAttributes
        )
    }
    
}
