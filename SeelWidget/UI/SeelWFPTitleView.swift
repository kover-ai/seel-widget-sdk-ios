import UIKit
import SnapKit

typealias InfoButtonClickEvent = () -> Void

final class SeelWFPTitleView: UIView {
    
    public var title: String?
    
    public var price: Double?
    
    public var currency: String?
    
    public var loading: Bool = false
    
    public var showInfo: Bool = false
    
    public var showPowered: Bool = false
    
    public var infoClicked: InfoButtonClickEvent?
    
    private lazy var contentSV: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6
        return stackView
    }()
    
    private lazy var textSV: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var titleSV: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var detailSV: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var seelIcon = UIImageView(image: UIImage(swName: "seel_icon"))
    private lazy var titleLabel = UILabel(frame: .zero)
    private lazy var priceLabel = UILabel(frame: .zero)
    private lazy var animationView = LoadingAnimationView(frame: .init(x: 0, y: 0, width: 30, height: 11))
    
    private lazy var infoButton: UIButton = {
        let infoButton = UIButton(type: .custom)
        infoButton.setImage(seelThemedIcon("info_black", darkTint: \.iconMutedTint), for: .normal)
        infoButton.isEnabled = false
        // 真正可点的是下面那个 44pt 的扩展按钮，这个只负责画图标。
        infoButton.markAsSeelDecoration()
        return infoButton
    }()
    
    private lazy var infoExtensionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(infoButtonClicked), for: .touchUpInside)
        button.isAccessibilityElement = true
        button.accessibilityTraits = .button
        button.accessibilityLabel = seelText(.a11yInfoButtonLabel)
        return button
    }()
    
    private lazy var poweredLabel = UILabel(frame: .zero)
    private lazy var seelWordIcon = UIImageView(image: UIImage(swName: "seel_word"))
    
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
        seelIcon.markAsSeelDecoration()
        seelWordIcon.markAsSeelDecoration()
        addSubview(contentSV)
        contentSV.addArrangedSubview(seelIcon)
        contentSV.addArrangedSubview(textSV)
        textSV.addArrangedSubview(titleSV)
        textSV.addArrangedSubview(detailSV)
        
        titleSV.addArrangedSubview(titleLabel)
        titleSV.addArrangedSubview(priceLabel)
        titleSV.addArrangedSubview(animationView)
        titleSV.addArrangedSubview(infoButton)
        
        detailSV.addArrangedSubview(poweredLabel)
        detailSV.addArrangedSubview(seelWordIcon)
        
        addSubview(infoExtensionButton)
    }
    
    func configViews() {
        titleLabel.font = SeelFont.scaled(12, weight: .semibold)
        titleLabel.textColor = seelTheme.primaryText
        
        priceLabel.font = SeelFont.scaled(10, weight: .regular)
        priceLabel.textColor = seelTheme.primaryText
        
        // 品牌名在这里是图片（seel_word），所以只取模板里 {{seel}} 之外的字面量。
        // 已知限制：若某语言把品牌名放在句首，图片仍在文字之后。
        poweredLabel.text = seelText(.poweredBy, ["seel": ""])
            .trimmingCharacters(in: .whitespaces)
        poweredLabel.font = SeelFont.scaled(7.5, weight: .semibold)
        poweredLabel.textColor = seelTheme.secondaryText
        
        contentSV.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        seelIcon.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        infoButton.snp.makeConstraints { make in
            make.width.height.equalTo(12)
        }
        animationView.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(11)
        }
        infoExtensionButton.snp.makeConstraints { make in
            make.center.equalTo(infoButton)
            // HIG 要求可点区域不小于 44pt，图标本身只有 12pt。
            make.width.height.equalTo(44)
        }
    }
    
    func updateViews() {
        let localizedTitle = seelServerText(title) ?? ""
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: SeelFont.scaled(12, weight: .semibold),
            .foregroundColor: seelTheme.primaryText,
        ]
        let priceAttributes: [NSAttributedString.Key: Any] = [
            .font: SeelFont.scaled(10, weight: .regular),
            .foregroundColor: seelTheme.primaryText,
        ]

        animationView.isHidden = !loading
        if loading {
            // 加载中价格还没回来，标题与占位骨架分成两个视图，
            // 中间的连接词从模板里取（把 title / price 替换成空再去掉多余空格）。
            titleLabel.attributedText = NSAttributedString(string: localizedTitle, attributes: titleAttributes)
            priceLabel.text = priceConnector()
            priceLabel.isHidden = false
            animationView.startAnimating()
        } else if let price = price {
            // 词序交给模板决定，不要在代码里拼 "标题 + for + 价格"。
            titleLabel.attributedText = seelComposedText(
                .wfpTitle,
                segments: [
                    "title": (localizedTitle, titleAttributes),
                    "price": (formatMoney(price, currency: currency), priceAttributes),
                ],
                defaultAttributes: priceAttributes
            )
            priceLabel.isHidden = true
            animationView.stopAnimating()
        } else {
            titleLabel.attributedText = NSAttributedString(string: localizedTitle, attributes: titleAttributes)
            priceLabel.isHidden = true
            animationView.stopAnimating()
        }
        
        infoButton.isHidden = !showInfo
        infoExtensionButton.isHidden = !showInfo
        
        detailSV.isHidden = !showPowered

        configureAccessibility()
    }

    /// 标题、价格、"Powered by" 分散在多个 label 里，
    /// 合并成一条朗读，并把 info 按钮排在它后面。
    private func configureAccessibility() {
        let spoken = [
            titleLabel.attributedText?.string ?? titleLabel.text,
            priceLabel.isHidden ? nil : priceLabel.text,
        ].compactMap { $0 }.filter { !$0.isEmpty }

        textSV.markAsSeelA11yGroup(label: spoken.joined(separator: " "))
        accessibilityElements = showInfo ? [textSV, infoExtensionButton] : [textSV]
    }

    /// 模板里连接标题与价格的字面量部分，例如英文的 "for"。
    private func priceConnector() -> String {
        seelText(.wfpTitle, ["title": "", "price": ""])
            .trimmingCharacters(in: .whitespaces)
    }
    
    @objc func infoButtonClicked() {
        if infoClicked != nil {
            infoClicked!()
        }
    }
    
}
