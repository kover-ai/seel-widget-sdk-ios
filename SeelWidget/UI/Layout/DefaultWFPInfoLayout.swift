import UIKit
import SnapKit

/// The original WFP info modal layout — used when brandType is nil or unrecognized.
final class DefaultWFPInfoLayout: WFPInfoLayoutProvider {
    
    func buildLayout(
        in viewController: UIViewController,
        quoteResponse: QuotesResponse?,
        actions: WFPInfoLayoutActions
    ) {
        let view = viewController.view!
        view.backgroundColor = seelTheme.background
        
        // MARK: - Navigation Bar
        let navigationBar = SeelNavigationBar()
        navigationBar.title = seelServerText(quoteResponse?.extraInfo?.widgetTitle)
        
        let closeButton = UIButton(type: .custom)
        closeButton.setTitle(seelText(.close), for: .normal)
        closeButton.setTitleColor(seelTheme.primaryText, for: .normal)
        closeButton.titleLabel?.font = SeelFont.scaled(17, weight: .light)
        closeButton.addTapHandler { actions.onClose() }
        closeButton.accessibilityLabel = seelText(.a11yCloseLabel)
        navigationBar.rightBarButtonItems = [closeButton]
        
        // MARK: - Scroll Content
        let backgroundView = UIView()
        backgroundView.backgroundColor = seelTheme.background
        
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        
        let contentView = UIView()
        
        let wfpView = CoverageTitleView()
        wfpView.title = seelServerText(quoteResponse?.extraInfo?.widgetTitle)
        wfpView.price = quoteResponse?.price
        wfpView.currency = quoteResponse?.currency
        wfpView.updateViews()
        
        let seelLabel = UILabel()
        let seelFullText = seelText(.whatsCoveredBySeel)
        let seelKeyword = "Seel"
        let attributedText = NSMutableAttributedString(string: seelFullText)
        let nsFullText = seelFullText as NSString
        attributedText.addAttribute(.foregroundColor, value: seelTheme.primaryText, range: NSRange(location: 0, length: nsFullText.length))
        let seelRange = nsFullText.range(of: seelKeyword)
        if seelRange.location != NSNotFound {
            attributedText.addAttribute(.foregroundColor, value: seelTheme.primary, range: seelRange)
        }
        seelLabel.attributedText = attributedText
        seelLabel.font = SeelFont.scaled(16, weight: .semibold)
        
        let coverageDetailsView = CoverageDetailsView(frame: .zero)
        coverageDetailsView.quoteResponse = quoteResponse
        coverageDetailsView.updateViews()
        
        let coverageTipsView = CoverageTipsView()
        
        let coverageInfoFooter = CoverageInfoFooter()
        coverageInfoFooter.optedInClicked = { actions.onOptIn() }
        coverageInfoFooter.noNeedClicked = { actions.onNoNeed() }
        coverageInfoFooter.privacyPolicyClicked = { actions.onPrivacyPolicy() }
        coverageInfoFooter.termsClicked = { actions.onTerms() }
        
        // MARK: - View Hierarchy
        view.addSubview(navigationBar)
        view.addSubview(backgroundView)
        backgroundView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(wfpView)
        contentView.addSubview(seelLabel)
        contentView.addSubview(coverageDetailsView)
        contentView.addSubview(coverageTipsView)
        contentView.addSubview(coverageInfoFooter)
        
        // MARK: - Constraints
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
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
        let bottomInset: CGFloat
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first(where: { $0.activationState == .foregroundActive })
            bottomInset = scene?.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.bottom ?? 0
        } else {
            bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        coverageInfoFooter.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(coverageTipsView.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-(18 + bottomInset))
        }
    }
}
