import UIKit

final class CoverageLineView: UIView {
    
    public var iconImage: UIImage?
    
    public var content: String?
    
    public var contentFont: UIFont?
    
    public var contentColor: UIColor?
    
    private lazy var contentSV: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var icon = UIImageView(image: UIImage(swName: "icon_select"))
    private lazy var contentLabel = UILabel(frame: .zero)
    
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
        contentSV.addArrangedSubview(icon)
        contentSV.addArrangedSubview(contentLabel)
    }
    
    func configViews() {
        contentLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        contentLabel.textColor = UIColor(hex: "#414141")
        contentLabel.numberOfLines = 0
        
        contentSV.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(18)
        }
    }
    
    func updateViews() {
        icon.isHidden = iconImage == nil
        icon.image = iconImage
        
        contentLabel.text = content
        contentLabel.font = contentFont ?? UIFont.systemFont(ofSize: 12, weight: .medium)
        contentLabel.textColor = contentColor ?? UIColor(hex: "#414141")
    }
}
