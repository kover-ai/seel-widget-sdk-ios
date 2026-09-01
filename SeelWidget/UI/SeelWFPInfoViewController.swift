import UIKit

final class SeelWFPInfoViewController: UIViewController {
    
    public var optedInClicked: CoverageInfoFooterClicked?
    
    public var noNeedClicked: CoverageInfoFooterClicked?
    
    public var privacyPolicyClicked: CoverageInfoFooterClicked?
    
    public var termsClicked: CoverageInfoFooterClicked?
    
    public var quoteResponse: QuotesResponse?
    
    private let brandType: String?

    private var themeObserver: SeelUIRefreshObserver?
    
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

        buildLayout()
        themeObserver = SeelUIRefreshObserver { [weak self] in self?.rebuildLayout() }
    }

    /// 主题切换后整屏重建：弹窗里的颜色都是在构建时写入子视图的。
    private func rebuildLayout() {
        view.subviews.forEach { $0.removeFromSuperview() }
        buildLayout()
    }

    private func buildLayout() {
        applySeelUserInterfaceStyle()

        let layoutProvider = WFPInfoLayoutFactory.provider(for: brandType)
        let actions = WFPInfoLayoutActions(
            onClose: { [weak self] in self?.dismiss(animated: true) },
            onOptIn: { [weak self] in self?.optedInClicked?() },
            onNoNeed: { [weak self] in self?.noNeedClicked?() },
            onPrivacyPolicy: { [weak self] in self?.privacyPolicyClicked?() },
            onTerms: { [weak self] in self?.termsClicked?() }
        )
        layoutProvider.buildLayout(in: self, quoteResponse: quoteResponse, actions: actions)

        // 弹窗盖在宿主页面之上，不隔离的话 VoiceOver 会滑到底下的内容上去。
        view.accessibilityViewIsModal = true
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SeelA11y.announceScreenChange(focusing: view)
    }

}
