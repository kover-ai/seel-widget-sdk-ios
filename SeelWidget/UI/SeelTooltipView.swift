import UIKit
import SnapKit

final class SeelTooltipView: UIView {

    private static weak var currentTooltip: SeelTooltipView?

    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(hex: "#202223")
        return label
    }()

    private lazy var cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
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
        addSubview(dismissOverlay)
        addSubview(cardView)
        cardView.addSubview(contentLabel)

        dismissOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentLabel.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }
    }

    @objc private func dismissTooltip() {
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

        UIView.animate(withDuration: 0.2) {
            tooltip.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak tooltip] in
            tooltip?.dismissTooltip()
        }
    }

    private static func buildTooltipText(from quoteResponse: QuotesResponse?) -> NSAttributedString {
        let reasons = [
            "Shipping destination not supported",
            "Checkout currency not accepted",
            "Order value exceeds our coverage limit",
            "Item(s) not eligible for this service",
            "Our system has flagged this order as ineligible"
        ]

        let textColor = UIColor(hex: "#202223")
        let font = UIFont.systemFont(ofSize: 12, weight: .regular)

        let intro = "We're unable to offer Worry-Free Purchase\u{00AE} Protection for this order. This could be due to one or more of the following reasons:\n\n"
        let bulletList = reasons.map { "  \u{2022}  \($0)" }.joined(separator: "\n")
        let footer = "\n\nIf you have any questions, please contact our customer support team for assistance."

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
