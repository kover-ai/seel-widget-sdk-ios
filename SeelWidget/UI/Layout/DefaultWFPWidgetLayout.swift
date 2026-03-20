import UIKit
import SnapKit

/// The original WFP widget layout — used when brandType is nil or unrecognized.
final class DefaultWFPWidgetLayout: WFPWidgetLayoutProvider {

    private lazy var contentSV: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .vertical
        sv.spacing = 6
        return sv
    }()

    private lazy var titleSV: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        return sv
    }()

    private lazy var detailSV: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .vertical
        sv.spacing = 6
        return sv
    }()

    private lazy var disclaimerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor(hex: "#808692")
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private lazy var titleView: SeelWFPTitleView = {
        let wfpView = SeelWFPTitleView()
        wfpView.showPowered = true
        wfpView.showInfo = false
        return wfpView
    }()

    private lazy var switcher: SeelSwitch = {
        let switcher = SeelSwitch()
        switcher.onTintColor = UIColor(hex: "#2121C4")
        switcher.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        switcher.isOn = true
        return switcher
    }()

    private lazy var checkbox: SeelCheckbox = {
        let checkbox = SeelCheckbox()
        checkbox.isOn = true
        return checkbox
    }()

    private var actions: WFPWidgetLayoutActions?
    private var currentToggleStyle: ToggleStyle = .switchStyle

    private func toggleView(for style: ToggleStyle) -> UIView {
        switch style {
        case .switchStyle: return switcher
        case .checkboxStyle: return checkbox
        }
    }

    // MARK: - WFPWidgetLayoutProvider

    func buildLayout(in container: UIView, actions: WFPWidgetLayoutActions) {
        self.actions = actions

        titleView.infoClicked = { actions.onInfoTapped() }

        switcher.onValueChanged = { isOn in actions.onToggleChanged(isOn) }
        checkbox.onValueChanged = { isOn in actions.onToggleChanged(isOn) }

        container.addSubview(contentSV)
        contentSV.addArrangedSubview(titleSV)
        contentSV.addArrangedSubview(detailSV)
        contentSV.addArrangedSubview(disclaimerLabel)

        titleSV.addArrangedSubview(titleView)
        titleSV.addArrangedSubview(toggleView(for: currentToggleStyle))

        contentSV.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }
    }

    func updateLayout(in container: UIView, data: WFPWidgetLayoutData) {
        let quoteResponse = data.quoteResponse
        let displayView = quoteResponse != nil

        container.isHidden = !displayView
        for subview in contentSV.arrangedSubviews {
            subview.isHidden = !displayView
        }
        contentSV.snp.remakeConstraints { make in
            if displayView {
                make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
            } else {
                make.edges.equalTo(UIEdgeInsets.zero)
            }
        }

        let isRejected = quoteResponse?.status == .rejected

        container.alpha = isRejected ? 0.9 : 1

        titleView.title = quoteResponse?.extraInfo?.widgetTitle
        titleView.price = isRejected ? nil : quoteResponse?.price
        titleView.showInfo = !isRejected && quoteResponse != nil
        titleView.loading = data.loading
        titleView.updateViews()

        // Swap toggle if style changed
        if data.toggleStyle != currentToggleStyle {
            let oldToggle = toggleView(for: currentToggleStyle)
            oldToggle.removeFromSuperview()
            currentToggleStyle = data.toggleStyle
            titleSV.addArrangedSubview(toggleView(for: currentToggleStyle))
        }

        let toggle = toggleView(for: data.toggleStyle)
        toggle.isHidden = quoteResponse == nil || isRejected

        switcher.isOn = data.toggleIsOn
        checkbox.isOn = data.toggleIsOn

        // Detail messages
        let msgs: [String] = quoteResponse?.extraInfo?.displayWidgetText ?? []
        detailSV.isHidden = msgs.isEmpty

        let deltaCount = msgs.count - detailSV.arrangedSubviews.count
        if deltaCount > 0 {
            for _ in 0..<deltaCount {
                detailSV.addArrangedSubview(LineView(frame: .zero))
            }
        }
        for (index, view) in detailSV.arrangedSubviews.enumerated() {
            if index < msgs.count {
                view.isHidden = false
                if let lineView = view as? LineView {
                    lineView.iconImage = msgs.count > 1 ? UIImage(swName: "icon_select") : nil
                    lineView.content = msgs[index]
                    lineView.updateViews()
                }
            } else {
                view.isHidden = true
            }
        }

        // Disclaimer
        if let disclaimer = quoteResponse?.extraInfo?.widgetDisclaimer, !disclaimer.isEmpty {
            disclaimerLabel.text = disclaimer
            disclaimerLabel.isHidden = false
        } else {
            disclaimerLabel.isHidden = true
        }
    }
}
