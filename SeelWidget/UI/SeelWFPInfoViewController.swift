import UIKit

final class SeelWFPInfoViewController: UIViewController {
    
    public var optedInClicked: CoverageInfoFooterClicked?
    
    public var noNeedClicked: CoverageInfoFooterClicked?
    
    public var privacyPolicyClicked: CoverageInfoFooterClicked?
    
    public var termsClicked: CoverageInfoFooterClicked?
    
    public var quoteResponse: QuotesResponse?
    
    private let brandType: String?
    
    public init(quoteResponse: QuotesResponse?, brandType: String? = nil) {
        self.quoteResponse = quoteResponse
        self.brandType = brandType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let layoutProvider = WFPInfoLayoutFactory.provider(for: brandType)
        let actions = WFPInfoLayoutActions(
            onClose: { [weak self] in self?.dismiss(animated: true) },
            onOptIn: { [weak self] in self?.optedInClicked?() },
            onNoNeed: { [weak self] in self?.noNeedClicked?() },
            onPrivacyPolicy: { [weak self] in self?.privacyPolicyClicked?() },
            onTerms: { [weak self] in self?.termsClicked?() }
        )
        layoutProvider.buildLayout(in: self, quoteResponse: quoteResponse, actions: actions)
    }
    
}
