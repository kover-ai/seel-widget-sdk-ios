import UIKit

final class CoverageDetailsView: UIView {
    
    public var quoteResponse: QuotesResponse?
    
    private lazy var stackView: UIStackView = {
      let view = UIStackView()
      view.axis = .vertical
      view.spacing = 8
      return view
    }()
    
    private lazy var titleLine = UILabel(frame: .zero)
    
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
        addSubview(stackView)
        stackView.addArrangedSubview(titleLine)
    }
    
    func configViews() {
        backgroundColor = UIColor(hex: "#333333")
        layer.cornerRadius = 4
        
        titleLine.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        titleLine.textColor = UIColor(hex: "#ffffff")
        titleLine.numberOfLines = 0
        titleLine.text = "Get a Full Refund, No Questions Asked"
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 23, left: 23, bottom: 23, right: 23))
        }
    }
    
    func updateViews() {
        let msgs: [String] = quoteResponse?.extraInfo?.coverageDetailsText ?? []
        
        stackView.isHidden = msgs.count <= 0
        
        let deltaCount = msgs.count - (stackView.arrangedSubviews.count - 1)
        if deltaCount > 0 {
            for _ in 0...deltaCount {
                stackView.addArrangedSubview(CoverageLineView(frame: .zero))
            }
        }
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            if index - 1 < msgs.count {
                view.isHidden = false
                if let lineView = view as? CoverageLineView {
                    lineView.iconImage = UIImage(swName: "icon_bg_select")
                    lineView.content = msgs[index - 1]
                    lineView.contentColor = UIColor(hex: "#ffffff")
                    lineView.updateViews()
                }
            } else {
                view.isHidden = true
            }
        }
    }
    
}
