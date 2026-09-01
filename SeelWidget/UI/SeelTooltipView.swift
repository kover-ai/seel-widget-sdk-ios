import UIKit
import SnapKit

final class SeelTooltipView: UIView {

    private static weak var currentTooltip: SeelTooltipView?

    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = SeelFont.scaled(12, weight: .regular)
        label.enableSeelDynamicType()
        label.textColor = seelTheme.primaryText
        return label
    }()

    private lazy var cardView: UIView = {
        let v = UIView()
        v.backgroundColor = seelTheme.elevatedBackground
        v.layer.cornerRadius = 8
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.1
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 8
        return v
    }()

    private lazy var dismissOverlay: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(dismissTooltip), for: .touchUpInside)
        btn.accessibilityLabel = seelText(.a11yCloseLabel)
        btn.accessibilityTraits = .button
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        applySeelUserInterfaceStyle()
        // 浮层盖在整页之上：隔离读屏焦点，并让正文先被读到、关闭动作排在后面。
        accessibilityViewIsModal = true
        addSubview(dismissOverlay)
        addSubview(cardView)
        cardView.addSubview(contentLabel)
        accessibilityElements = [contentLabel, dismissOverlay]

        dismissOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentLabel.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }
    }

    @objc private func dismissTooltip() {
        guard !SeelA11y.isReduceMotionEnabled else {
            removeFromSuperview()
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

    // MARK: - Public

    static func show(in window: UIWindow, anchorView: UIView, quoteResponse: QuotesResponse?) {
        currentTooltip?.removeFromSuperview()

        let tooltip = SeelTooltipView(frame: window.bounds)
        currentTooltip = tooltip
        tooltip.alpha = 0

        tooltip.contentLabel.attributedText = buildTooltipText(from: quoteResponse)

        window.addSubview(tooltip)
        tooltip.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let horizontalPadding: CGFloat = 20

        tooltip.cardView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(horizontalPadding)
            make.right.equalToSuperview().offset(-horizontalPadding)
            make.centerY.equalToSuperview()
        }

        tooltip.layoutIfNeeded()

        if SeelA11y.isReduceMotionEnabled {
            tooltip.alpha = 1
        } else {
            UIView.animate(withDuration: 0.2) {
                tooltip.alpha = 1
            }
        }

        SeelA11y.announceScreenChange(focusing: tooltip.contentLabel)

        // 8 秒对读屏用户读不完这段说明，开了 VoiceOver 就交给用户自己关。
        guard !SeelA11y.isVoiceOverRunning else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak tooltip] in
            tooltip?.dismissTooltip()
        }
    }

    private static func buildTooltipText(from quoteResponse: QuotesResponse?) -> NSAttributedString {
        let reasons = [
            seelText(.ineligibleReasonShipping),
            seelText(.ineligibleReasonCurrency),
            seelText(.ineligibleReasonValue),
            seelText(.ineligibleReasonItems),
            seelText(.ineligibleReasonSystem),
        ]

        let textColor = seelTheme.primaryText
        let font = SeelFont.scaled(12, weight: .regular)

        // 标点不进 key：后端文案库里的原文不带结尾的 : 和 .，
        // 把它们拼在这里才能命中译文。
        let intro = seelText(.ineligibleMainMessage) + ":\n\n"
        let bulletList = reasons.map { "  \u{2022}  \($0)" }.joined(separator: "\n")
        let footer = "\n\n" + seelText(.ineligibleSupportMessage) + "."

        let full = intro + bulletList + footer

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2

        return NSAttributedString(
            string: full,
            attributes: [
                .font: font,
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
        )
    }
}
