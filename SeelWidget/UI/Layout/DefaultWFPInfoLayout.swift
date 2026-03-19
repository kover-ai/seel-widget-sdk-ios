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
        view.backgroundColor = .white
        
        // MARK: - Navigation Bar
        let navigationBar = SeelNavigationBar()
        navigationBar.title = quoteResponse?.extraInfo?.widgetTitle
        
        let closeButton = UIButton(type: .custom)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .light)
        closeButton.addTapHandler { actions.onClose() }
        navigationBar.rightBarButtonItems = [closeButton]
        
        // MARK: - Scroll Content
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        
        let contentView = UIView()
        
        let wfpView = CoverageTitleView()
        wfpView.title = quoteResponse?.extraInfo?.widgetTitle
        wfpView.price = quoteResponse?.price
        wfpView.updateViews()
        
        let seelLabel = UILabel()
        let attributedText = NSMutableAttributedString(string: "What's Covered by Seel")
        attributedText.addAttribute(.foregroundColor, value: UIColor(hex: "#2121C4"), range: NSRange(location: 18, length: 4))
        attributedText.addAttribute(.foregroundColor, value: UIColor(hex: "#000000"), range: NSRange(location: 0, length: 18))
        seelLabel.attributedText = attributedText
        seelLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
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
        let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        coverageInfoFooter.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(coverageTipsView.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-(18 + bottomInset))
        }
    }
}
