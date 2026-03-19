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

        isOn = isChecked
        isDisabled = isRejected
        checkboxButton.isSelected = isChecked
        checkboxButton.isEnabled = !isRejected
        checkboxButton.accessibilityLabel = isChecked ? "Selected" : "Unselected"

        disabledTapGesture.isEnabled = isRejected

        container.backgroundColor = isRejected ? UIColor(hex: "#F0EFEF") : .white
        container.alpha = 1.0

        // Title: "Worry-Free Purchase® for $3.75"
        let titleColor = isRejected ? UIColor(hex: "#676667") : UIColor(hex: "#292728")
        if isRejected {
            titleLabel.text = quoteResponse?.extraInfo?.widgetTitle
            titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
            titleLabel.textColor = titleColor
        } else {
            let title = quoteResponse?.extraInfo?.widgetTitle ?? ""
            let priceText = " for $\(quoteResponse?.price ?? 0)"
            let full = title + priceText
            let attr = NSMutableAttributedString(
                string: full,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                    .foregroundColor: titleColor
                ]
            )
            titleLabel.attributedText = attr
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

        // Disclaimer: hidden when rejected
        if !isRejected,
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
