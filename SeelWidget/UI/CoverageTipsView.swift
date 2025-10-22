import UIKit

final class CoverageTipsView: UIView {
    
    private lazy var resolutionTitleLabel = UILabel(frame: .zero)
    
    private lazy var resolutionDetailLabel = UILabel(frame: .zero)
    
    private lazy var peaceTipTitleLabel = UILabel(frame: .zero)
    
    private lazy var peaceTipDetailLabel = UILabel(frame: .zero)
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        configViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createViews() {
        addSubview(resolutionTitleLabel)
        addSubview(resolutionDetailLabel)
        addSubview(peaceTipTitleLabel)
        addSubview(peaceTipDetailLabel)
    }
    
    func configViews() {
        resolutionTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        resolutionTitleLabel.textColor = UIColor(hex: "#1E2022")
        resolutionTitleLabel.numberOfLines = 0
        resolutionTitleLabel.text = "Easy resolution"
        
        resolutionDetailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        resolutionDetailLabel.textColor = UIColor(hex: "#565656")
        resolutionDetailLabel.numberOfLines = 0
        resolutionDetailLabel.text = "Resolve your issues with just a few clicks"
        
        peaceTipTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        peaceTipTitleLabel.textColor = UIColor(hex: "#1E2022")
        peaceTipTitleLabel.numberOfLines = 0
        peaceTipTitleLabel.text = "Complete Peace of Mind"
        
        peaceTipDetailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        peaceTipDetailLabel.textColor = UIColor(hex: "#565656")
        peaceTipDetailLabel.numberOfLines = 0
        peaceTipDetailLabel.text = """
• Zero-risk on your order with our protection
• Get your refund promptly
"""
        
        resolutionTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
        }
        resolutionDetailLabel.snp.makeConstraints { make in
            make.left.right.equalTo(resolutionTitleLabel)
            make.top.equalTo(resolutionTitleLabel.snp.bottom).offset(3)
        }
        peaceTipTitleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(resolutionTitleLabel)
            make.top.equalTo(resolutionDetailLabel.snp.bottom).offset(15)
        }
        peaceTipDetailLabel.snp.makeConstraints { make in
            make.left.right.equalTo(resolutionTitleLabel)
            make.top.equalTo(peaceTipTitleLabel.snp.bottom).offset(3)
            make.bottom.equalToSuperview()
        }
    }
    
}
