import UIKit

/// SDK 的外观模式。
///
/// - `light` / `dark`：强制使用浅色或深色，忽略系统设置。
/// - `auto`：跟随系统（iOS 13+）。iOS 12 没有系统深色模式，`auto` 等同于 `light`。
public enum SeelThemeMode: String {
    case light = "light"
    case dark = "dark"
    case auto = "auto"
}

/// 自定义主题。
///
/// 所有字段都是可选的：为 nil 的字段沿用 SDK 内置配色，
/// 因此接入方只需覆盖自己关心的那几项。
///
/// 通过 `SeelWidgetSDK.shared.setTheme(_:for:)` 分别为浅色 / 深色注入，
/// 或用 `.auto` 一次性作用于两种外观。
public struct SeelTheme {
    public var primaryColor: UIColor?             // 品牌主色调（如开关 On 状态、强调文字等）
    public var onPrimaryColor: UIColor?           // 主色调之上的文字/图标颜色
    public var accentColor: UIColor?              // 次级品牌色（如 PDP banner 中的 "seel" 字样）
    public var backgroundColor: UIColor?          // Widget / 页面默认背景色
    public var selectedBackgroundColor: UIColor?  // 选中状态下的背景色
    public var disabledBackgroundColor: UIColor?  // 禁用/拒绝状态下的背景色
    public var cardBackgroundColor: UIColor?      // 卡片（如 What's Covered）背景色
    public var elevatedBackgroundColor: UIColor?  // 浮层背景色（弹窗、tooltip、导航栏）
    public var primaryTextColor: UIColor?         // 主文本颜色
    public var secondaryTextColor: UIColor?       // 次要/辅助文本颜色
    public var tertiaryTextColor: UIColor?        // 三级文本颜色（副标题、说明文字）
    public var disclaimerTextColor: UIColor?      // 免责声明文本颜色
    public var linkTextColor: UIColor?            // 链接文本颜色（隐私政策、服务条款）
    public var ctaBackgroundColor: UIColor?       // 主行动按钮背景色
    public var ctaTextColor: UIColor?             // 主行动按钮文字颜色
    public var borderColor: UIColor?              // 边框颜色
    public var separatorColor: UIColor?           // 分割线颜色
    public var iconTintColor: UIColor?            // 单色图标着色
    public var borderWidth: CGFloat?              // 边框宽度
    public var cornerRadius: CGFloat?             // 圆角半径

    public init(
        primaryColor: UIColor? = nil,
        onPrimaryColor: UIColor? = nil,
        accentColor: UIColor? = nil,
        backgroundColor: UIColor? = nil,
        selectedBackgroundColor: UIColor? = nil,
        disabledBackgroundColor: UIColor? = nil,
        cardBackgroundColor: UIColor? = nil,
        elevatedBackgroundColor: UIColor? = nil,
        primaryTextColor: UIColor? = nil,
        secondaryTextColor: UIColor? = nil,
        tertiaryTextColor: UIColor? = nil,
        disclaimerTextColor: UIColor? = nil,
        linkTextColor: UIColor? = nil,
        ctaBackgroundColor: UIColor? = nil,
        ctaTextColor: UIColor? = nil,
        borderColor: UIColor? = nil,
        separatorColor: UIColor? = nil,
        iconTintColor: UIColor? = nil,
        borderWidth: CGFloat? = nil,
        cornerRadius: CGFloat? = nil
    ) {
        self.primaryColor = primaryColor
        self.onPrimaryColor = onPrimaryColor
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.disabledBackgroundColor = disabledBackgroundColor
        self.cardBackgroundColor = cardBackgroundColor
        self.elevatedBackgroundColor = elevatedBackgroundColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.tertiaryTextColor = tertiaryTextColor
        self.disclaimerTextColor = disclaimerTextColor
        self.linkTextColor = linkTextColor
        self.ctaBackgroundColor = ctaBackgroundColor
        self.ctaTextColor = ctaTextColor
        self.borderColor = borderColor
        self.separatorColor = separatorColor
        self.iconTintColor = iconTintColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
    }
}

extension Notification.Name {
    /// 主题模式或自定义主题发生变化时发出。
    /// SDK 内部的视图会监听该通知并重新着色，接入方一般无需关心。
    public static let SeelThemeDidChange = Notification.Name("SeelThemeDidChange")
}
