import UIKit

/// 无障碍相关的统一入口：动态字体、系统开关、以及朗读顺序的辅助方法。
enum SeelA11y {

    // MARK: - 系统开关

    /// 用户开了「减弱动态效果」。骨架屏、开关滑动、浮层淡入都应跳过动画。
    static var isReduceMotionEnabled: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    /// 用户开了「增强对比度」。
    static var isIncreaseContrastEnabled: Bool {
        UIAccessibility.isDarkerSystemColorsEnabled
    }

    /// VoiceOver 正在运行。用于放宽自动消失这类对读屏用户不友好的时序。
    static var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }

    // MARK: - 通知

    /// 焦点移到新出现的界面上，并让 VoiceOver 重新扫描。
    static func announceScreenChange(focusing view: UIView?) {
        UIAccessibility.post(notification: .screenChanged, argument: view)
    }

    /// 界面局部更新后提示读屏重新读取。
    static func announceLayoutChange(focusing view: UIView? = nil) {
        UIAccessibility.post(notification: .layoutChanged, argument: view)
    }
}

// MARK: - 动态字体

/// SDK 的字体入口：在系统字号基础上跟随用户的「文字大小」设置缩放。
///
/// 与直接用 `UIFont.systemFont(ofSize:)` 的区别是它响应动态字体；
/// 与直接用 `UIFont.preferredFont(forTextStyle:)` 的区别是 SDK 的视觉稿是按具体磅值给的，
/// 这里保留原磅值作为基准，只做等比缩放。
enum SeelFont {

    /// 放大上限。
    ///
    /// 不设上限的话，辅助功能档位（AX1–AX5）能把 12pt 放到 40pt 以上，
    /// widget 嵌在宿主的购物车里，撑破的是宿主的布局。
    /// 2.0 倍已经覆盖到 `accessibilityLarge` 一档，够用且不至于失控。
    private static let maximumScale: CGFloat = 2.0

    static func scaled(
        _ size: CGFloat,
        weight: UIFont.Weight = .regular,
        textStyle: UIFont.TextStyle = .body
    ) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        return UIFontMetrics(forTextStyle: textStyle)
            .scaledFont(for: base, maximumPointSize: size * maximumScale)
    }
}

extension UILabel {
    /// 让标签跟随「文字大小」实时变化。
    /// 字体必须来自 `SeelFont.scaled`，否则这个开关不起作用。
    func enableSeelDynamicType() {
        adjustsFontForContentSizeCategory = true
    }
}

extension UIButton {
    func enableSeelDynamicType() {
        titleLabel?.adjustsFontForContentSizeCategory = true
    }
}

// MARK: - 触达区

/// 视觉上很小、但可点区域需要满足 44pt 最小尺寸的按钮。
///
/// 图标按钮（如 16pt 的 ⓘ）直接放大会撑开所在的 stack，
/// 所以保持 bounds 不变，只把命中测试和读屏焦点框向外扩。
final class SeelExpandedTouchButton: UIButton {

    /// HIG 要求的最小可点尺寸。
    var minimumTouchSize: CGSize = CGSize(width: 44, height: 44)

    private var expandedBounds: CGRect {
        let dx = min(0, (bounds.width - minimumTouchSize.width) / 2)
        let dy = min(0, (bounds.height - minimumTouchSize.height) / 2)
        return bounds.insetBy(dx: dx, dy: dy)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        expandedBounds.contains(point)
    }

    override var accessibilityFrame: CGRect {
        get { UIAccessibility.convertToScreenCoordinates(expandedBounds, in: self) }
        set { super.accessibilityFrame = newValue }
    }
}

// MARK: - 语义标注

extension UIView {

    /// 把一组子视图合并成一个朗读单元，避免 VoiceOver 把标题、价格、副标题拆成三次朗读。
    /// - Parameters:
    ///   - label: 合并后的朗读内容。
    ///   - traits: 附加特征。
    func markAsSeelA11yGroup(label: String, traits: UIAccessibilityTraits = .staticText) {
        isAccessibilityElement = true
        accessibilityLabel = label
        accessibilityTraits = traits
    }

    /// 标为装饰性元素，读屏直接跳过。
    func markAsSeelDecoration() {
        isAccessibilityElement = false
        accessibilityElementsHidden = true
    }
}
