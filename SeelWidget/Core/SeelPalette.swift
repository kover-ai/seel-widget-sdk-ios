import UIKit

/// SDK 内部使用的完整配色表。
///
/// 与 `SeelTheme` 的区别：`SeelTheme` 是接入方的「部分覆盖」，字段可选；
/// `SeelPalette` 是最终生效的配色，字段全部有值，视图层只读它。
struct SeelPalette {

    // MARK: - 品牌色
    var primary: UIColor
    var onPrimary: UIColor
    var accent: UIColor
    var success: UIColor

    // MARK: - 背景
    var background: UIColor
    var selectedBackground: UIColor
    var disabledBackground: UIColor
    var cardBackground: UIColor
    var elevatedBackground: UIColor
    /// 反色区块（浅色下是深色块 + 白字）
    var invertedBackground: UIColor
    /// 弹窗遮罩
    var scrim: UIColor

    // MARK: - 文本
    var primaryText: UIColor
    var secondaryText: UIColor
    var tertiaryText: UIColor
    var disclaimerText: UIColor
    var invertedText: UIColor
    var linkText: UIColor

    // MARK: - 按钮
    var ctaBackground: UIColor
    /// 更强调的 CTA（EBTH 弹窗底部按钮）
    var emphasisCTABackground: UIColor
    var onCTAText: UIColor

    // MARK: - 装饰
    var border: UIColor
    var separator: UIColor
    var iconTint: UIColor
    var iconMutedTint: UIColor
    var skeletonBase: UIColor
    var skeletonHighlight: UIColor
    var toggleTrack: UIColor
    var toggleThumb: UIColor

    // MARK: - 度量
    var borderWidth: CGFloat
    var cornerRadius: CGFloat
}

// MARK: - 内置配色

extension SeelPalette {

    /// 浅色默认值。这里的每一个色值都与引入深色模式之前的硬编码值保持一致，
    /// 确保未开启深色模式的接入方升级后浅色外观零变化。
    static let lightDefaults = SeelPalette(
        primary: UIColor(hex: "#2121C4"),
        onPrimary: UIColor(hex: "#FFFFFF"),
        accent: UIColor(hex: "#635BFF"),
        success: UIColor(hex: "#34C759"),

        background: UIColor(hex: "#FFFFFF"),
        selectedBackground: UIColor(hex: "#FFFFFF"),
        disabledBackground: UIColor(hex: "#F0EFEF"),
        cardBackground: UIColor(hex: "#F8F9FF"),
        elevatedBackground: UIColor(hex: "#FFFFFF"),
        invertedBackground: UIColor(hex: "#333333"),
        scrim: UIColor.black.withAlphaComponent(0.4),

        primaryText: UIColor(hex: "#000000"),
        secondaryText: UIColor(hex: "#565656"),
        tertiaryText: UIColor(hex: "#676667"),
        disclaimerText: UIColor(hex: "#808692"),
        invertedText: UIColor(hex: "#FFFFFF"),
        linkText: UIColor(hex: "#5C5F62"),

        ctaBackground: UIColor(hex: "#333333"),
        emphasisCTABackground: UIColor(hex: "#000000"),
        onCTAText: UIColor(hex: "#FFFFFF"),

        border: UIColor(hex: "#E0E0E0"),
        separator: UIColor(hex: "#EEEEEE"),
        iconTint: UIColor(hex: "#000000"),
        iconMutedTint: UIColor(hex: "#676667"),
        skeletonBase: UIColor(hex: "#F0F0F0"),
        skeletonHighlight: UIColor(hex: "#E0E0E0"),
        toggleTrack: UIColor.lightGray,
        toggleThumb: UIColor(hex: "#FFFFFF"),

        borderWidth: 0,
        cornerRadius: 0
    )

    /// 深色默认值。
    static let darkDefaults = SeelPalette(
        primary: UIColor(hex: "#6C6CF0"),
        onPrimary: UIColor(hex: "#FFFFFF"),
        accent: UIColor(hex: "#8F88FF"),
        success: UIColor(hex: "#30D158"),

        background: UIColor(hex: "#1C1C1E"),
        selectedBackground: UIColor(hex: "#1C1C1E"),
        disabledBackground: UIColor(hex: "#2C2C2E"),
        cardBackground: UIColor(hex: "#2C2C2E"),
        elevatedBackground: UIColor(hex: "#1C1C1E"),
        invertedBackground: UIColor(hex: "#2C2C2E"),
        scrim: UIColor.black.withAlphaComponent(0.6),

        primaryText: UIColor(hex: "#FFFFFF"),
        secondaryText: UIColor(hex: "#AEAEB2"),
        tertiaryText: UIColor(hex: "#AEAEB2"),
        disclaimerText: UIColor(hex: "#8E8E93"),
        invertedText: UIColor(hex: "#FFFFFF"),
        linkText: UIColor(hex: "#A1A1A6"),

        ctaBackground: UIColor(hex: "#F2F2F7"),
        emphasisCTABackground: UIColor(hex: "#F2F2F7"),
        onCTAText: UIColor(hex: "#000000"),

        border: UIColor(hex: "#48484A"),
        separator: UIColor(hex: "#38383A"),
        iconTint: UIColor(hex: "#FFFFFF"),
        iconMutedTint: UIColor(hex: "#AEAEB2"),
        skeletonBase: UIColor(hex: "#3A3A3C"),
        skeletonHighlight: UIColor(hex: "#48484A"),
        toggleTrack: UIColor(hex: "#48484A"),
        toggleThumb: UIColor(hex: "#F2F2F7"),

        borderWidth: 0,
        cornerRadius: 0
    )
}

// MARK: - 覆盖

extension SeelPalette {

    /// 把接入方的自定义主题叠加到内置配色上，未指定的字段保持不变。
    func applying(_ overrides: SeelTheme?) -> SeelPalette {
        guard let overrides = overrides else { return self }
        var palette = self

        if let value = overrides.primaryColor { palette.primary = value }
        if let value = overrides.onPrimaryColor { palette.onPrimary = value }
        if let value = overrides.accentColor { palette.accent = value }

        if let value = overrides.backgroundColor {
            palette.background = value
            // 未单独指定这两项时跟随背景色：
            // 否则「只改了背景色」的接入方会看到选中态和弹窗退回内置配色，显得割裂。
            palette.selectedBackground = value
            palette.elevatedBackground = value
        }
        if let value = overrides.selectedBackgroundColor { palette.selectedBackground = value }
        if let value = overrides.disabledBackgroundColor { palette.disabledBackground = value }
        if let value = overrides.cardBackgroundColor { palette.cardBackground = value }
        if let value = overrides.elevatedBackgroundColor { palette.elevatedBackground = value }

        if let value = overrides.primaryTextColor { palette.primaryText = value }
        if let value = overrides.secondaryTextColor { palette.secondaryText = value }
        if let value = overrides.tertiaryTextColor { palette.tertiaryText = value }
        if let value = overrides.disclaimerTextColor { palette.disclaimerText = value }
        if let value = overrides.linkTextColor { palette.linkText = value }

        if let value = overrides.ctaBackgroundColor {
            palette.ctaBackground = value
            palette.emphasisCTABackground = value
        }
        if let value = overrides.ctaTextColor { palette.onCTAText = value }

        if let value = overrides.borderColor { palette.border = value }
        if let value = overrides.separatorColor { palette.separator = value }
        if let value = overrides.iconTintColor { palette.iconTint = value }

        if let value = overrides.borderWidth { palette.borderWidth = value }
        if let value = overrides.cornerRadius { palette.cornerRadius = value }

        return palette
    }

    /// 把浅色 / 深色两套配色合成为最终生效的配色。
    ///
    /// `auto` 模式下每个色值都是 iOS 13 的动态色，系统外观切换时由 UIKit 自动重新解析；
    /// 强制 `light` / `dark` 时返回静态色，保证 CGColor 等场景也能拿到确定的值。
    static func resolve(light: SeelPalette, dark: SeelPalette, mode: SeelThemeMode) -> SeelPalette {
        func c(_ keyPath: KeyPath<SeelPalette, UIColor>) -> UIColor {
            SeelPalette.dynamicColor(light: light[keyPath: keyPath], dark: dark[keyPath: keyPath], mode: mode)
        }

        return SeelPalette(
            primary: c(\.primary),
            onPrimary: c(\.onPrimary),
            accent: c(\.accent),
            success: c(\.success),

            background: c(\.background),
            selectedBackground: c(\.selectedBackground),
            disabledBackground: c(\.disabledBackground),
            cardBackground: c(\.cardBackground),
            elevatedBackground: c(\.elevatedBackground),
            invertedBackground: c(\.invertedBackground),
            scrim: c(\.scrim),

            primaryText: c(\.primaryText),
            secondaryText: c(\.secondaryText),
            tertiaryText: c(\.tertiaryText),
            disclaimerText: c(\.disclaimerText),
            invertedText: c(\.invertedText),
            linkText: c(\.linkText),

            ctaBackground: c(\.ctaBackground),
            emphasisCTABackground: c(\.emphasisCTABackground),
            onCTAText: c(\.onCTAText),

            border: c(\.border),
            separator: c(\.separator),
            iconTint: c(\.iconTint),
            iconMutedTint: c(\.iconMutedTint),
            skeletonBase: c(\.skeletonBase),
            skeletonHighlight: c(\.skeletonHighlight),
            toggleTrack: c(\.toggleTrack),
            toggleThumb: c(\.toggleThumb),

            // 度量没有深浅色之分，深色配色里的值只在深色模式下有意义。
            borderWidth: mode == .dark ? dark.borderWidth : light.borderWidth,
            cornerRadius: mode == .dark ? dark.cornerRadius : light.cornerRadius
        )
    }

    static func dynamicColor(light: UIColor, dark: UIColor, mode: SeelThemeMode) -> UIColor {
        switch mode {
        case .light:
            return light
        case .dark:
            return dark
        case .auto:
            if #available(iOS 13.0, *) {
                return UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ? dark : light
                }
            }
            // iOS 12 没有系统深色模式，auto 退化为浅色。
            return light
        }
    }
}
