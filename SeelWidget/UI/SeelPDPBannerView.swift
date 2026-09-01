import UIKit

/// Style configuration for the PDP banner.
public struct PDPBannerStyle {
    /// Background color. `nil` (default) follows the current theme.
    public var backgroundColor: UIColor?
    public var padding: UIEdgeInsets
    public var cornerRadius: CGFloat
    public var borderColor: UIColor?
    public var borderWidth: CGFloat

    public init(
        backgroundColor: UIColor? = nil,
        padding: UIEdgeInsets = .zero,
        cornerRadius: CGFloat = 0,
        borderColor: UIColor? = nil,
        borderWidth: CGFloat = 0
    ) {
        self.backgroundColor = backgroundColor
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}

/// A lightweight banner view for the Product Detail Page.
/// Displays brand-specific messaging (e.g. "Worry-Free Purchase® available with seel").
/// Hidden by default; shows content when a matching brand type is provided.
public final class SeelPDPBannerView: UIView {

    private var layoutProvider: PDPBannerLayoutProvider?
    private var themeObserver: SeelUIRefreshObserver?
    private var currentType: String?
    private var currentStyle = PDPBannerStyle()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Configure the banner for a specific brand type.
    /// - Parameters:
    ///   - type: The brand identifier (e.g. "ebth-wfp"). Pass nil to hide.
    ///   - style: Visual style configuration. Defaults to the themed background, no padding, no corner radius.
    public func setup(type: String?, style: PDPBannerStyle = PDPBannerStyle()) {
        currentType = type
        currentStyle = style
        rebuild()

        if themeObserver == nil {
            themeObserver = SeelUIRefreshObserver { [weak self] in self?.rebuild() }
        }
    }

    private func rebuild() {
        subviews.forEach { $0.removeFromSuperview() }

        applySeelUserInterfaceStyle()

        layer.cornerRadius = currentStyle.cornerRadius
        clipsToBounds = currentStyle.cornerRadius > 0
        applyBorder()

        layoutProvider = PDPBannerLayoutFactory.provider(
            for: currentType,
            backgroundColor: currentStyle.backgroundColor,
            padding: currentStyle.padding
        )
        layoutProvider?.buildLayout(in: self)
    }

    private func applyBorder() {
        if let borderColor = currentStyle.borderColor {
            // CGColor 不会随外观自动更新，必须先按当前 trait 解析。
            layer.borderColor = borderColor.resolvedSeelColor(for: traitCollection).cgColor
            layer.borderWidth = currentStyle.borderWidth
        } else {
            layer.borderColor = nil
            layer.borderWidth = 0
        }
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyBorder()
    }
}
