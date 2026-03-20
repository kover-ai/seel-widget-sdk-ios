import UIKit

/// Style configuration for the PDP banner.
public struct PDPBannerStyle {
    public var backgroundColor: UIColor
    public var padding: UIEdgeInsets
    public var cornerRadius: CGFloat
    public var borderColor: UIColor?
    public var borderWidth: CGFloat

    public init(
        backgroundColor: UIColor = .white,
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
    ///   - style: Visual style configuration. Defaults to white background, no padding, no corner radius.
    public func setup(type: String?, style: PDPBannerStyle = PDPBannerStyle()) {
        subviews.forEach { $0.removeFromSuperview() }

        layer.cornerRadius = style.cornerRadius
        clipsToBounds = style.cornerRadius > 0
        if let borderColor = style.borderColor {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = style.borderWidth
        } else {
            layer.borderColor = nil
            layer.borderWidth = 0
        }

        layoutProvider = PDPBannerLayoutFactory.provider(
            for: type,
            backgroundColor: style.backgroundColor,
            padding: style.padding
        )
        layoutProvider?.buildLayout(in: self)
    }
}
