import UIKit
import SnapKit

final class CoverageTitleView: UIView {
    
    public var title: String?
    
    public var price: Double?
    
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
        titleLabel.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        titleLabel.textColor = UIColor(hex: "#000000")
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
        let attributedText = NSMutableAttributedString(string: title ?? "")
        if let _price = price {
            attributedText.append(NSAttributedString(string: " for $\(String(describing: _price))", attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            ]))
        }
        titleLabel.attributedText = attributedText
    }
    
}
