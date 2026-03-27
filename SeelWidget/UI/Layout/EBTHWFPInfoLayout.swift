import UIKit
import SnapKit

/// EBTH-specific WFP info modal layout.
/// Matches the design with background image header, white card overlay,
/// feature cards, and full-width CTA button.
final class EBTHWFPInfoLayout: WFPInfoLayoutProvider {
    
    var enableBlurEffect: Bool = false
    
    var preferredPresentationStyle: UIModalPresentationStyle { .overFullScreen }
    
    func buildLayout(
        in viewController: UIViewController,
        quoteResponse: QuotesResponse?,
        actions: WFPInfoLayoutActions
    ) {
        let view = viewController.view!
        view.backgroundColor = .clear
        
        // MARK: - Dim overlay (tap to close)
        let dimOverlay = UIView()
        dimOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.addSubview(dimOverlay)
        
        let overlayTap = UITapGestureRecognizer()
        dimOverlay.addGestureRecognizer(overlayTap)
        let overlayTarget = ClosureTarget { actions.onClose() }
        overlayTap.addTarget(overlayTarget, action: #selector(ClosureTarget.invoke))
        objc_setAssociatedObject(dimOverlay, "overlayTarget", overlayTarget, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        dimOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // MARK: - Bottom sheet container
        let sheetContainer = UIView()
        sheetContainer.backgroundColor = .white
        sheetContainer.layer.cornerRadius = 16
        sheetContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetContainer.clipsToBounds = true
        view.addSubview(sheetContainer)
        
        sheetContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            make.left.right.bottom.equalToSuperview()
        }
        
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        
        let contentView = UIView()
        
        sheetContainer.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(sheetContainer)
        }
        
        // MARK: - Header (background image + logo + close + titles)
        let headerContainer = UIView()
        contentView.addSubview(headerContainer)
        
        let backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.image = UIImage(swName: "background_image")
        backgroundImageView.backgroundColor = UIColor(hex: "#3A3A5C")
        backgroundImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        headerContainer.addSubview(backgroundImageView)
        
        let headerBlur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        headerBlur.alpha = 0.3
        headerContainer.addSubview(headerBlur)
        
        let seelLogoIcon = UIImageView()
        seelLogoIcon.contentMode = .scaleAspectFit
        seelLogoIcon.image = UIImage(swName: "seel_logo")
        headerContainer.addSubview(seelLogoIcon)
        
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(swName: "close_white") ?? UIImage(swName: "button_close_background"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTapHandler { actions.onClose() }
        headerContainer.addSubview(closeButton)
        
        let headerTitleLabel = UILabel()
        headerTitleLabel.text = "We've Got You Covered"
        headerTitleLabel.font = .systemFont(ofSize: 20, weight: .heavy)// 800
        headerTitleLabel.textColor = .white
        headerTitleLabel.numberOfLines = 0
        headerContainer.addSubview(headerTitleLabel)
        
        let headerSubtitleLabel = UILabel()
        let priceText = formatMoney(quoteResponse?.price, currency: quoteResponse?.currency)
        headerSubtitleLabel.text = quoteResponse?.price != nil ? "Only \(priceText) for Complete Peace of Mind" : ""
        headerSubtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        headerSubtitleLabel.textColor = UIColor.white
        headerSubtitleLabel.numberOfLines = 0
        headerContainer.addSubview(headerSubtitleLabel)
        
        let headerHeight = max(180, UIScreen.main.bounds.height * 0.20)
        headerContainer.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(headerHeight)
        }
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headerBlur.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        seelLogoIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(24)
            make.width.equalTo(78)
            make.height.equalTo(22)
        }
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(seelLogoIcon)
            make.right.equalToSuperview().offset(-24)
            make.width.height.equalTo(26)
        }
        headerTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(seelLogoIcon.snp.bottom).offset(24)
        }
        headerSubtitleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(headerTitleLabel)
            make.top.equalTo(headerTitleLabel.snp.bottom).offset(24)
        }
        
        // MARK: - White Card (with optional blur)
        let cardContainer: UIView
        let whiteCard: UIView
        
        if enableBlurEffect {
            let blurEffect = UIBlurEffect(style: .light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.layer.cornerRadius = 10
            blurView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            blurView.clipsToBounds = true
            cardContainer = blurView
            whiteCard = blurView.contentView
        } else {
            let plainView = UIView()
            plainView.backgroundColor = .white
            plainView.layer.cornerRadius = 10
            plainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            plainView.clipsToBounds = true
            cardContainer = plainView
            whiteCard = plainView
        }
        
        contentView.addSubview(cardContainer)
        cardContainer.snp.makeConstraints { make in
            make.top.equalTo(headerContainer.snp.bottom).offset(-20)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        // MARK: - "Worry-Free Purchase®" Title
        let wfpTitleLabel = UILabel()
        wfpTitleLabel.text = quoteResponse?.extraInfo?.widgetTitle ?? ""
        wfpTitleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        wfpTitleLabel.textColor = UIColor(hex: "#1E2022")
        wfpTitleLabel.textAlignment = .center
        whiteCard.addSubview(wfpTitleLabel)
        
        wfpTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.right.equalToSuperview().inset(24)
        }
        
        // MARK: - Coverage Card
        let coverageCard = UIView()
        coverageCard.backgroundColor = UIColor(hex: "#F8F9FF")
        coverageCard.layer.cornerRadius = 10
        whiteCard.addSubview(coverageCard)
        
        coverageCard.snp.makeConstraints { make in
            make.top.equalTo(wfpTitleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(24)
        }
        
        let coverageHeaderSV = UIStackView()
        coverageHeaderSV.axis = .horizontal
        coverageHeaderSV.spacing = 8
        coverageHeaderSV.alignment = .center
        coverageCard.addSubview(coverageHeaderSV)
        
        let shieldIcon = UIImageView()
        shieldIcon.image = UIImage(swName: "accredited")
        shieldIcon.tintColor = UIColor(hex: "#1E2022")
        shieldIcon.contentMode = .scaleAspectFit
        coverageHeaderSV.addArrangedSubview(shieldIcon)
        
        let coverageHeaderLabel = UILabel()
        coverageHeaderLabel.text = "What's Covered"
        coverageHeaderLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        coverageHeaderLabel.textColor = UIColor(hex: "#000000")
        coverageHeaderSV.addArrangedSubview(coverageHeaderLabel)
        
        shieldIcon.setContentHuggingPriority(.required, for: .vertical)
        shieldIcon.setContentCompressionResistancePriority(.required, for: .vertical)
        shieldIcon.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
        
        coverageHeaderSV.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(32)
        }
        
        let coverageItemsSV = UIStackView()
        coverageItemsSV.axis = .vertical
        coverageItemsSV.spacing = 20
        coverageCard.addSubview(coverageItemsSV)
        
        coverageItemsSV.snp.makeConstraints { make in
            make.top.equalTo(coverageHeaderSV.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        let coverageTexts = quoteResponse?.extraInfo?.coverageDetailsText ?? []
        for text in coverageTexts {
            let itemView = buildCoverageItem(text: text)
            coverageItemsSV.addArrangedSubview(itemView)
        }
        
        // MARK: - Feature Cards (Instant Resolution + 24/7 Support)
        let featureRow = UIStackView()
        featureRow.axis = .horizontal
        featureRow.spacing = 12
        featureRow.distribution = .fillEqually
        whiteCard.addSubview(featureRow)
        
        featureRow.snp.makeConstraints { make in
            make.top.equalTo(coverageCard.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(24)
        }
        
        let resolutionCard = buildFeatureCard(
            iconName: "bolt",
            title: "Instant Resolution",
            detail: "Quick resolution in just a few clicks"
        )
        let supportCard = buildFeatureCard(
            iconName: "headphones",
            title: "24/7 Support by Seel",
            detail: "Get help anytime with fast response"
        )
        featureRow.addArrangedSubview(resolutionCard)
        featureRow.addArrangedSubview(supportCard)
        
        // MARK: - Footer
        let footerContainer = UIView()
        whiteCard.addSubview(footerContainer)
        
        let safeBottom = view.safeAreaInsets.bottom
        let footerBottomPadding: CGFloat = safeBottom > 0 ? safeBottom : 24
        footerContainer.snp.makeConstraints { make in
            make.top.equalTo(featureRow.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-footerBottomPadding)
        }
        
        let optInButton = UIButton(type: .custom)
        optInButton.setTitle("Secure Your Purchase Now", for: .normal)
        optInButton.setTitleColor(.white, for: .normal)
        optInButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        optInButton.backgroundColor = UIColor(hex: "#000000")
        optInButton.layer.cornerRadius = 10
        optInButton.addTapHandler { actions.onOptIn() }
        footerContainer.addSubview(optInButton)
        
        let noNeedButton = UIButton(type: .custom)
        noNeedButton.setTitle("Continue Without Protection", for: .normal)
        noNeedButton.setTitleColor(UIColor(hex: "#808692"), for: .normal)
        noNeedButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        noNeedButton.addTapHandler { actions.onNoNeed() }
        footerContainer.addSubview(noNeedButton)
        
        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.distribution = .equalSpacing
        bottomRow.alignment = .center
        footerContainer.addSubview(bottomRow)
        
        let linksStack = UIStackView()
        linksStack.axis = .horizontal
        linksStack.spacing = 16
        
        let privacyButton = buildUnderlineButton(title: "Privacy Policy") { actions.onPrivacyPolicy() }
        let termsButton = buildUnderlineButton(title: "Terms of Service") { actions.onTerms() }
        linksStack.addArrangedSubview(privacyButton)
        linksStack.addArrangedSubview(termsButton)
        
        let poweredBySV = UIStackView()
        poweredBySV.axis = .horizontal
        poweredBySV.spacing = 2
        poweredBySV.alignment = .center
        let poweredByLabel = UILabel()
        poweredByLabel.text = "Powered By"
        poweredByLabel.font = .systemFont(ofSize: 10, weight: .regular)
        poweredByLabel.textColor = UIColor(hex: "#000000")
        let seelTextLabel = UILabel()
        seelTextLabel.text = "Seel"
        seelTextLabel.font = .systemFont(ofSize: 10, weight: .bold)
        seelTextLabel.textColor = UIColor(hex: "#000000")
        poweredBySV.addArrangedSubview(poweredByLabel)
        poweredBySV.addArrangedSubview(seelTextLabel)
        
        bottomRow.addArrangedSubview(linksStack)
        bottomRow.addArrangedSubview(poweredBySV)
        
        // Footer constraints
        optInButton.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(52)
        }
        noNeedButton.snp.makeConstraints { make in
            make.top.equalTo(optInButton.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        let divider = UIView()
        divider.backgroundColor = UIColor(hex: "#E0E0E0")
        footerContainer.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.equalTo(noNeedButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        bottomRow.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Private Helpers
    
    /// accredited: 32x32, left=0 in coverageHeaderSV, center=16, text left=40
    /// checkIcon: 20x20, left=7, center=17 (~aligned with accredited center 16)
    /// label left=40 (aligned with coverageHeaderLabel), gap=40-27=13
    private func buildCoverageItem(text: String) -> UIView {
        let container = UIView()
        
        let checkIcon = UIImageView()
        checkIcon.image = UIImage(swName: "icon_check_selected_black")
        checkIcon.tintColor = UIColor(hex: "#34C759")
        checkIcon.contentMode = .scaleAspectFit
        container.addSubview(checkIcon)
        
        let label = UILabel()
        label.numberOfLines = 0
        
        let parts = text.components(separatedBy: " - ")
        if parts.count >= 2 {
            let attr = NSMutableAttributedString(
                string: parts[0],
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                    .foregroundColor: UIColor(hex: "#000000")
                ]
            )
            attr.append(NSAttributedString(
                string: " - " + parts.dropFirst().joined(separator: " - "),
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                    .foregroundColor: UIColor(hex: "#000000")
                ]
            ))
            label.attributedText = attr
        } else {
            let dashParts = text.components(separatedBy: " – ")
            if dashParts.count >= 2 {
                let attr = NSMutableAttributedString(
                    string: dashParts[0],
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                        .foregroundColor: UIColor(hex: "#000000")
                    ]
                )
                attr.append(NSAttributedString(
                    string: " – " + dashParts.dropFirst().joined(separator: " – "),
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                        .foregroundColor: UIColor(hex: "#000000")
                    ]
                ))
                label.attributedText = attr
            } else {
                label.text = text
                label.font = .systemFont(ofSize: 14)
                label.textColor = UIColor(hex: "#000000")
            }
        }
        
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let firstLineCenter = font.ascender / 2
        checkIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(7)
            make.centerY.equalTo(label.snp.top).offset(firstLineCenter)
            make.width.height.equalTo(20)
        }
        
        return container
    }
    
    private func buildFeatureCard(iconName: String, title: String, detail: String) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(hex: "#F8F9FF")
        card.layer.cornerRadius = 10
        
        let iconView = UIImageView()
        iconView.image = UIImage(swName: iconName)
        iconView.tintColor = UIColor(hex: "#000000")
        iconView.contentMode = .scaleAspectFit
        card.addSubview(iconView)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(hex: "#000000")
        titleLabel.numberOfLines = 0
        card.addSubview(titleLabel)
        
        let detailLabel = UILabel()
        detailLabel.text = detail
        detailLabel.font = .systemFont(ofSize: 14, weight: .regular)
        detailLabel.textColor = UIColor(hex: "#000000")
        detailLabel.numberOfLines = 0
        card.addSubview(detailLabel)
        
        iconView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(20)
            make.width.height.equalTo(32)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        return card
    }
    
    private func buildUnderlineButton(title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .custom)
        let attr = NSAttributedString(
            string: title,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: UIFont.systemFont(ofSize: 11, weight: .regular),
                .foregroundColor: UIColor(hex: "#5C5F62")
            ]
        )
        button.setAttributedTitle(attr, for: .normal)
        button.addTapHandler { action() }
        return button
    }
}
