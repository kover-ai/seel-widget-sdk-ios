import UIKit
import SnapKit

/// EBTH-specific PDP banner layout.
/// Displays a single-line banner: [shopping_bag icon] "Worry-Free Purchase® available with" [seel]
final class EBTHPDPBanner: PDPBannerLayoutProvider {

    private let bgColor: UIColor?
    private let padding: UIEdgeInsets

    init(backgroundColor: UIColor? = nil, padding: UIEdgeInsets = .zero) {
        self.bgColor = backgroundColor
        self.padding = padding
    }

    func buildLayout(in container: UIView) {
        container.isHidden = false
        container.backgroundColor = bgColor ?? seelTheme.background

        let iconView = UIImageView()
        iconView.image = seelThemedIcon("shopping_bag", darkTint: \.iconMutedTint)
        iconView.contentMode = .scaleAspectFit
        container.addSubview(iconView)

        let textLabel = UILabel()
        textLabel.text = seelText(.wfpAvailableWith)
        // 大字号下单行放不下，允许换行而不是截断。
        textLabel.numberOfLines = 0
        textLabel.font = SeelFont.scaled(16, weight: .regular)
        textLabel.textColor = seelTheme.tertiaryText
        textLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        container.addSubview(textLabel)

        let seelLabel = UILabel()
        seelLabel.text = "seel"
        seelLabel.font = SeelFont.scaled(16, weight: .semibold)
        seelLabel.textColor = seelTheme.accent
        seelLabel.setContentHuggingPriority(.required, for: .horizontal)
        seelLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        container.addSubview(seelLabel)

        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(padding.left)
            make.top.greaterThanOrEqualToSuperview().offset(padding.top)
            make.bottom.lessThanOrEqualToSuperview().offset(-padding.bottom)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(23)
        }

        textLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(4)
            make.centerY.equalToSuperview()
            // 让换行后的文字把 banner 撑高，而不是被裁掉。
            make.top.greaterThanOrEqualToSuperview().offset(padding.top)
            make.bottom.lessThanOrEqualToSuperview().offset(-padding.bottom)
        }

        seelLabel.snp.makeConstraints { make in
            make.left.equalTo(textLabel.snp.right).offset(4)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview().offset(-padding.right)
            make.top.equalToSuperview().offset(padding.top)
            make.bottom.equalToSuperview().offset(-padding.bottom)
        }
    }
}
