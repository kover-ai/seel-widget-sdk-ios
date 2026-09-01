import UIKit
import SnapKit

/// EBTH-specific WFP widget layout.
/// Checkbox on the left, title + subtitle + disclaimer on the right.
/// Three visual states: normal (unchecked), selected (checked), disabled (rejected).
final class EBTHWFPWidgetLayout: WFPWidgetLayoutProvider {

    var defaultShowDisclaimer: Bool { false }

    private var actions: WFPWidgetLayoutActions?

    // MARK: - Checkbox

    private lazy var checkboxButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(seelThemedIcon("ebth_checkbox_normal", darkTint: \.iconMutedTint), for: .normal)
        btn.setImage(UIImage(swName: "ebth_checkbox_selected"), for: .selected)
        btn.setImage(seelThemedIcon("ebth_checkbox_disabled", darkTint: \.iconMutedTint), for: .disabled)
        btn.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        btn.isAccessibilityElement = true
        btn.accessibilityTraits = .button
        return btn
    }()

    // MARK: - Title Row

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        // 行数由 applyTitleLineBreaking 按当前字号切换，见那里的说明。
        label.numberOfLines = 1
        label.enableSeelDynamicType()
        return label
    }()



    private lazy var infoButton: UIButton = {
        // 图标只有 16pt，用扩展命中区的按钮把可点范围补到 44pt。
        let btn = SeelExpandedTouchButton(type: .custom)
        btn.setImage(seelThemedIcon("ebth_info", darkTint: \.iconMutedTint), for: .normal)
        return btn
    }()

    private lazy var pricePrefixLabel: UILabel = {
        let label = UILabel()
        label.font = SeelFont.scaled(15, weight: .regular)
        label.textColor = seelTheme.primaryText
        label.isHidden = true
        return label
    }()

    private lazy var priceLoadingView: LoadingAnimationView = {
        let v = LoadingAnimationView(frame: .init(x: 0, y: 0, width: 36, height: 12))
        v.isHidden = true
        return v
    }()

    private lazy var titleRow: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 4
        sv.isHidden = true
        return sv
    }()

    // MARK: - Subtitle

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Disclaimer

    private lazy var disclaimerLabel: UILabel = {
        let label = UILabel()
        label.font = SeelFont.scaled(12, weight: .regular)
        label.textColor = seelTheme.tertiaryText
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Containers

    private lazy var textContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 2
        sv.isHidden = true
        return sv
    }()

    private lazy var rootContainer: UIView = {
        let v = UIView()
        return v
    }()

    private var isOn: Bool = false
    private var isDisabled: Bool = false

    private lazy var disabledTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(disabledAreaTapped))
        return tap
    }()

    // MARK: - WFPWidgetLayoutProvider

    func buildLayout(in container: UIView, actions: WFPWidgetLayoutActions) {
        self.actions = actions

        infoButton.addTapHandler { actions.onInfoTapped() }
        container.addGestureRecognizer(disabledTapGesture)
        disabledTapGesture.isEnabled = false

        container.addSubview(rootContainer)

        rootContainer.addSubview(checkboxButton)
        rootContainer.addSubview(textContainer)

        titleRow.addArrangedSubview(titleLabel)
        titleRow.addArrangedSubview(pricePrefixLabel)
        titleRow.addArrangedSubview(priceLoadingView)
        titleRow.addArrangedSubview(infoButton)
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleRow.addArrangedSubview(spacer)

        textContainer.addArrangedSubview(titleRow)
        textContainer.addArrangedSubview(subtitleLabel)

        rootContainer.addSubview(disclaimerLabel)

        // Constraints
        rootContainer.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }

        checkboxButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-13)
            make.centerY.equalTo(titleRow)
            make.width.height.equalTo(44)
        }
        checkboxButton.imageView?.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        textContainer.snp.makeConstraints { make in
            make.left.equalTo(checkboxButton.snp.right).offset(-3)
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }

        infoButton.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }



        priceLoadingView.snp.makeConstraints { make in
            make.width.equalTo(36)
            make.height.equalTo(12)
        }

        disclaimerLabel.snp.makeConstraints { make in
            make.top.equalTo(textContainer.snp.bottom).offset(10)
            make.left.equalTo(textContainer)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func updateLayout(in container: UIView, data: WFPWidgetLayoutData) {
        let quoteResponse = data.quoteResponse
        let displayView = quoteResponse != nil

        container.isHidden = !displayView
        rootContainer.snp.remakeConstraints { make in
            if displayView {
                make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
            } else {
                make.edges.equalTo(UIEdgeInsets.zero)
            }
        }

        guard displayView else {
            textContainer.isHidden = true
            titleRow.isHidden = true
            checkboxButton.isHidden = true
            disclaimerLabel.isHidden = true
            return
        }

        textContainer.isHidden = false
        titleRow.isHidden = false
        checkboxButton.isHidden = false

        let isRejected = quoteResponse?.status == .rejected
        let isChecked = data.toggleIsOn && !isRejected
        let isLoading = data.loading

        isOn = isChecked
        isDisabled = isRejected
        checkboxButton.isSelected = isChecked
        checkboxButton.isEnabled = !isRejected

        disabledTapGesture.isEnabled = isRejected

        if isRejected {
            container.backgroundColor = data.disabledBackgroundColor
        } else if data.toggleIsOn {
            container.backgroundColor = data.selectedBackgroundColor
        } else {
            container.backgroundColor = data.normalBackgroundColor
        }
        container.alpha = 1.0

        // Title: "Worry-Free Purchase® for $3.75"
        let titleColor = isRejected ? seelTheme.tertiaryText : seelTheme.primaryText
        let title = seelServerText(quoteResponse?.extraInfo?.widgetTitle) ?? ""
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: SeelFont.scaled(15, weight: .semibold),
            .foregroundColor: titleColor,
        ]
        let priceAttributes: [NSAttributedString.Key: Any] = [
            .font: SeelFont.scaled(15, weight: .regular),
            .foregroundColor: titleColor,
        ]

        if isRejected {
            titleLabel.attributedText = NSAttributedString(string: title, attributes: titleAttributes)
            pricePrefixLabel.isHidden = true
            priceLoadingView.isHidden = true
            priceLoadingView.stopAnimating()
        } else {
            pricePrefixLabel.textColor = titleColor
            if isLoading {
                titleLabel.attributedText = NSAttributedString(string: title, attributes: titleAttributes)
                // 价格还在路上：连接词单独占一格，后面接骨架动画。
                pricePrefixLabel.text = seelText(.wfpTitle, ["title": "", "price": ""])
                    .trimmingCharacters(in: .whitespaces)
                pricePrefixLabel.isHidden = false
                priceLoadingView.isHidden = false
                priceLoadingView.startAnimating()
            } else {
                // 词序由模板决定，不再硬拼 title + " for " + price。
                titleLabel.attributedText = seelComposedText(
                    .wfpTitle,
                    segments: [
                        "title": (title, titleAttributes),
                        "price": (formatMoney(quoteResponse?.price, currency: quoteResponse?.currency), priceAttributes),
                    ],
                    defaultAttributes: priceAttributes
                )
                pricePrefixLabel.isHidden = true
                priceLoadingView.isHidden = true
                priceLoadingView.stopAnimating()
            }
        }

        // Info button: hidden when rejected
        infoButton.isHidden = isRejected

        // Subtitle
        let msgs = quoteResponse?.extraInfo?.displayWidgetText ?? []
        if !msgs.isEmpty {
            let font = SeelFont.scaled(12, weight: .regular)
            let paragraphStyle = NSMutableParagraphStyle()
            // 行高跟着字号一起放大。写死 16 的话，字号一放大字形就会被行高裁掉。
            let lineHeight = 16 * (font.pointSize / 12)
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            subtitleLabel.attributedText = NSAttributedString(
                string: msgs.compactMap { seelServerText($0) }.joined(separator: "\n"),
                attributes: [
                    .font: font,
                    .foregroundColor: seelTheme.tertiaryText,
                    .paragraphStyle: paragraphStyle
                ]
            )
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }

        // Disclaimer: hidden when rejected or showDisclaimer is false
        if data.showDisclaimer,
           !isRejected,
           let disclaimer = seelServerText(quoteResponse?.extraInfo?.widgetDisclaimer),
           !disclaimer.isEmpty {
            disclaimerLabel.text = disclaimer
            disclaimerLabel.isHidden = false
        } else {
            disclaimerLabel.isHidden = true
        }

        applyTitleLineBreaking(in: container)
        configureAccessibility(container: container, isRejected: isRejected, isChecked: isChecked)

        // Adjust bottom constraint based on disclaimer visibility
        disclaimerLabel.snp.remakeConstraints { make in
            if disclaimerLabel.isHidden {
                make.top.equalTo(textContainer.snp.bottom)
                make.height.equalTo(0)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            } else {
                make.top.equalTo(textContainer.snp.bottom).offset(10)
                make.left.equalTo(textContainer)
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
    }

    /// 辅助功能字号下把标题行改为纵向排列。
    ///
    /// 多行 label 塞在横向 stack 里拿不到确定宽度：它会画两行、却只按单行高度
    /// 参与布局，副标题于是压在标题第二行上。给 label 加宽度约束也没用——
    /// stack 自身的约束是 required，会把它挤掉。
    ///
    /// 改成纵向排列后每个元素都能拿到整行宽度，高度自然算对；
    /// 这也是系统 App 在辅助功能字号下的通用做法。常规字号维持原来的横向排版。
    private func applyTitleLineBreaking(in container: UIView) {
        let isAccessibilitySize = container.traitCollection
            .preferredContentSizeCategory
            .isAccessibilityCategory

        titleLabel.numberOfLines = isAccessibilitySize ? 0 : 1
        titleRow.axis = isAccessibilitySize ? .vertical : .horizontal
        titleRow.alignment = isAccessibilitySize ? .leading : .center
    }

    // MARK: - Accessibility

    /// 勾选框读「勾的是什么」，标题不重复朗读，info 按钮保持可达。
    private func configureAccessibility(container: UIView, isRejected: Bool, isChecked: Bool) {
        let title = titleLabel.attributedText?.string ?? titleLabel.text ?? ""
        let spokenTitle = title.isEmpty ? seelText(.productName) : title

        // 标题已经由勾选框念出，标题 label 本身不再作为独立元素，避免读两遍。
        titleLabel.markAsSeelDecoration()

        infoButton.accessibilityLabel = seelText(.a11yInfoButtonLabel)
        infoButton.accessibilityTraits = .button

        if isRejected {
            // 被拒时整块可点，点了弹出原因说明。勾选框此时不可用，
            // 所以把这块合成一个元素来承载「为什么不可用」这个交互，
            // 否则读屏用户根本发现不了还能点。
            checkboxButton.markAsSeelDecoration()
            let details = [
                subtitleLabel.isHidden ? nil : (subtitleLabel.attributedText?.string ?? subtitleLabel.text),
                disclaimerLabel.isHidden ? nil : disclaimerLabel.text,
            ].compactMap { $0 }.filter { !$0.isEmpty }
            container.markAsSeelA11yGroup(
                label: ([spokenTitle] + details).joined(separator: ", "),
                traits: .button
            )
            container.accessibilityHint = seelText(.a11yUnavailableHint)
            return
        }

        container.isAccessibilityElement = false
        container.accessibilityHint = nil
        container.accessibilityElementsHidden = false

        checkboxButton.isAccessibilityElement = true
        checkboxButton.accessibilityElementsHidden = false
        checkboxButton.accessibilityLabel = spokenTitle
        checkboxButton.accessibilityValue = isChecked ? seelText(.a11yOn) : seelText(.a11yOff)
        checkboxButton.accessibilityHint = seelText(.a11yToggleHint)
        checkboxButton.accessibilityTraits = isChecked ? [.button, .selected] : .button

        // 副标题与免责声明保持各自独立的 label，按视觉顺序被读到即可；
        // 刻意不把它们并进 textContainer —— info 按钮就在这棵子树里，
        // 一旦父容器变成 a11y 元素，按钮就不可达了。
        textContainer.isAccessibilityElement = false
        textContainer.accessibilityElements = nil
    }

    // MARK: - Actions

    @objc private func checkboxTapped() {
        isOn.toggle()
        checkboxButton.isSelected = isOn
        actions?.onToggleChanged(isOn)
    }

    @objc private func disabledAreaTapped() {
        actions?.onDisabledTapped()
    }
}
