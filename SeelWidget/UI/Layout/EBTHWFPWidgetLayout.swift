import UIKit
import SnapKit

/// EBTH-specific WFP widget layout.
/// Checkbox on the left, title + subtitle + disclaimer on the right.
/// Three visual states: normal (unchecked), selected (checked), disabled (rejected).
final class EBTHWFPWidgetLayout: WFPWidgetLayoutProvider {

    private var actions: WFPWidgetLayoutActions?

    // MARK: - Checkbox

    private lazy var checkboxButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(swName: "ebth_checkbox_normal"), for: .normal)
        btn.setImage(UIImage(swName: "ebth_checkbox_selected"), for: .selected)
        btn.setImage(UIImage(swName: "ebth_checkbox_disabled"), for: .disabled)
        btn.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        btn.isAccessibilityElement = true
        btn.accessibilityTraits = .button
        return btn
    }()

    // MARK: - Title Row

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private lazy var infoButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(swName: "ebth_info"), for: .normal)
        return btn
    }()

    private lazy var pricePrefixLabel: UILabel = {
        let label = UILabel()
        label.text = "for"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(hex: "#292728")
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
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(hex: "#676667")
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
        checkboxButton.accessibilityLabel = isChecked ? "Selected" : "Unselected"

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
        let titleColor = isRejected ? UIColor(hex: "#676667") : UIColor(hex: "#292728")
        if isRejected {
            titleLabel.text = quoteResponse?.extraInfo?.widgetTitle
            titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
            titleLabel.textColor = titleColor
            pricePrefixLabel.isHidden = true
            priceLoadingView.isHidden = true
            priceLoadingView.stopAnimating()
        } else {
            let title = quoteResponse?.extraInfo?.widgetTitle ?? ""
            pricePrefixLabel.textColor = titleColor
            if isLoading {
                let attr = NSMutableAttributedString(
                    string: title,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                        .foregroundColor: titleColor
                    ]
                )
                titleLabel.attributedText = attr
                pricePrefixLabel.isHidden = false
                priceLoadingView.isHidden = false
                priceLoadingView.startAnimating()
            } else {
                let priceText = " for \(formatMoney(quoteResponse?.price, currency: quoteResponse?.currency))"
                let full = title + priceText
                let attr = NSMutableAttributedString(string: full)
                
                let titleUTF16Len = (title as NSString).length
                let priceUTF16Len = (priceText as NSString).length
                
                attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: NSRange(location: 0, length: titleUTF16Len))
                attr.addAttribute(.foregroundColor, value: titleColor, range: NSRange(location: 0, length: titleUTF16Len))
                
                attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: NSRange(location: titleUTF16Len, length: priceUTF16Len))
                attr.addAttribute(.foregroundColor, value: titleColor, range: NSRange(location: titleUTF16Len, length: priceUTF16Len))
                
                titleLabel.attributedText = attr
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
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = 16
            paragraphStyle.maximumLineHeight = 16
            subtitleLabel.attributedText = NSAttributedString(
                string: msgs.joined(separator: "\n"),
                attributes: [
                    .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                    .foregroundColor: UIColor(hex: "#676667"),
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
           let disclaimer = quoteResponse?.extraInfo?.widgetDisclaimer,
           !disclaimer.isEmpty {
            disclaimerLabel.text = disclaimer
            disclaimerLabel.isHidden = false
        } else {
            disclaimerLabel.isHidden = true
        }

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
