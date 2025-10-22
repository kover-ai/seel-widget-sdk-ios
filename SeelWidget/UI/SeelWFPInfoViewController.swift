import UIKit

final class SeelWFPInfoViewController: UIViewController {
    
    public var optedInClicked: CoverageInfoFooterClicked?
    
    public var noNeedClicked: CoverageInfoFooterClicked?
    
    public var privacyPolicyClicked: CoverageInfoFooterClicked?
    
    public var termsClicked: CoverageInfoFooterClicked?
    
    public var quoteResponse: QuotesResponse?
    
    public init(quoteResponse: QuotesResponse?) {
        self.quoteResponse = quoteResponse
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var navigationBar: SeelNavigationBar = {
        let bar = SeelNavigationBar()
        bar.title = "What's Covered"
        let close = UIButton(type: .custom)
        close.setImage(UIImage(swName: "button_close"), for: .normal)
        close.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        bar.setRightBarButtonItems([close])
        return bar
    }()
    
    private lazy var backgroundView = UIView(frame: .zero)
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView = UIView(frame: .zero)
    
    private lazy var wfpView = CoverageTitleView()
    
    private lazy var seelLabel: UILabel = {
        let seelLabel = UILabel(frame: .zero)
        let attributedText = NSMutableAttributedString(string: "What's Covered by Seel")
        let seelRange = NSRange(location: 18, length: 4)
        attributedText.addAttribute(.foregroundColor, value: UIColor(hex: "#2121C4"), range: seelRange)
        attributedText.addAttribute(.foregroundColor, value: UIColor(hex: "#000000"), range: NSRange(location: 0, length: 18))
        seelLabel.attributedText = attributedText
        seelLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return seelLabel
    }()
    
    private lazy var coverageDetailsView = CoverageDetailsView(frame: .zero)
    
    private lazy var coverageTipsView = CoverageTipsView()
    
    private lazy var coverageInfoFooter = CoverageInfoFooter()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        createViews()
        configViews()
        updateViews()
    }
    
    func createViews() {
        view.addSubview(navigationBar)
        view.addSubview(backgroundView)
        backgroundView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(wfpView)
        contentView.addSubview(seelLabel)
        
        contentView.addSubview(coverageDetailsView)
        contentView.addSubview(coverageTipsView)
        contentView.addSubview(coverageInfoFooter)
    }
    
    func configViews() {
        let closeButton = UIButton(type: .custom)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .light)
        closeButton.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        navigationBar.rightBarButtonItems = [closeButton]
        
        backgroundView.backgroundColor = .white
        
        coverageInfoFooter.optedInClicked = optedInClicked
        coverageInfoFooter.noNeedClicked = noNeedClicked
        coverageInfoFooter.privacyPolicyClicked = privacyPolicyClicked
        coverageInfoFooter.termsClicked = termsClicked
        
        navigationBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        backgroundView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(navigationBar.snp.bottom)
        }
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(backgroundView)
        }
        wfpView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(10)
        }
        seelLabel.snp.makeConstraints { make in
            make.left.right.equalTo(wfpView)
            make.top.equalTo(wfpView.snp.bottom).offset(20)
        }
        coverageDetailsView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(seelLabel.snp.bottom).offset(20)
        }
        coverageTipsView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.top.equalTo(coverageDetailsView.snp.bottom).offset(20)
        }
        coverageInfoFooter.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(coverageTipsView.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-18)
        }
    }
    
    func updateViews() {
        navigationBar.title = quoteResponse?.extraInfo?.widgetTitle
        
        wfpView.title = quoteResponse?.extraInfo?.widgetTitle
        wfpView.price = quoteResponse?.price
        wfpView.updateViews()
        
        coverageDetailsView.quoteResponse = quoteResponse
        coverageDetailsView.updateViews()
    }
    
    @objc func closeButtonClicked() {
        dismiss(animated: true)
    }
    
}
