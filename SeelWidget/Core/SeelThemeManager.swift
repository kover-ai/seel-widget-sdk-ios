import UIKit

/// 主题中心：持有当前外观模式与接入方注入的自定义配色，并向视图层提供最终配色表。
///
/// 只应在主线程访问（SDK 的视图全部在主线程构建）。
public final class SeelThemeManager {

    public static let shared = SeelThemeManager()

    private init() {}

    // MARK: - 外观模式

    /// 当前外观模式，默认跟随系统。
    public var mode: SeelThemeMode = .auto {
        didSet {
            guard oldValue != mode else { return }
            invalidate()
        }
    }

    // MARK: - 自定义主题

    private var lightOverrides: SeelTheme?
    private var darkOverrides: SeelTheme?

    /// 注入自定义主题。
    /// - Parameters:
    ///   - theme: 自定义配色；传 nil 表示清除该外观下的自定义、回到内置配色。
    ///   - mode: 作用的外观。`.light` / `.dark` 只作用于对应外观，
    ///           `.auto`（默认）表示浅色与深色同时使用这套配色。
    public func setTheme(_ theme: SeelTheme?, for mode: SeelThemeMode = .auto) {
        switch mode {
        case .light:
            lightOverrides = theme
        case .dark:
            darkOverrides = theme
        case .auto:
            lightOverrides = theme
            darkOverrides = theme
        }
        invalidate()
    }

    /// 取回此前注入的自定义主题。
    public func theme(for mode: SeelThemeMode) -> SeelTheme? {
        switch mode {
        case .light, .auto: return lightOverrides
        case .dark: return darkOverrides
        }
    }

    /// 清除所有自定义主题，回到 SDK 内置配色。
    public func resetTheme() {
        lightOverrides = nil
        darkOverrides = nil
        invalidate()
    }

    // MARK: - 配色表

    private var cachedPalette: SeelPalette?

    /// 当前生效的配色。`auto` 模式下其中的颜色为动态色，随系统外观自动解析。
    var palette: SeelPalette {
        if let cached = cachedPalette { return cached }
        let resolved = SeelPalette.resolve(light: lightPalette, dark: darkPalette, mode: mode)
        cachedPalette = resolved
        return resolved
    }

    /// 叠加自定义主题后的浅色配色（静态色）。
    var lightPalette: SeelPalette {
        SeelPalette.lightDefaults.applying(lightOverrides)
    }

    /// 叠加自定义主题后的深色配色（静态色）。
    var darkPalette: SeelPalette {
        SeelPalette.darkDefaults.applying(darkOverrides)
    }

    /// 强制模式下 SDK 根视图应使用的 `overrideUserInterfaceStyle`。
    @available(iOS 12.0, *)
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch mode {
        case .light: return .light
        case .dark: return .dark
        case .auto: return .unspecified
        }
    }

    private func invalidate() {
        cachedPalette = nil
        iconCache.removeAll()
        NotificationCenter.default.post(name: .SeelThemeDidChange, object: self)
    }

    // MARK: - 图标缓存

    /// 重新着色的图标按 `名称 + 着色 token` 缓存：
    /// 既省掉重复的离屏绘制，也保证 `UIImageAsset` 被持有（否则动态图片无法随外观切换）。
    private var iconCache: [String: UIImage] = [:]

    func cachedIcon(_ name: String, darkTint: KeyPath<SeelPalette, UIColor>, build: () -> UIImage?) -> UIImage? {
        let key = "\(name)#\(darkTint.hashValue)"
        if let cached = iconCache[key] { return cached }
        guard let image = build() else { return nil }
        iconCache[key] = image
        return image
    }
}

/// 视图层读取配色的快捷入口。
var seelTheme: SeelPalette {
    SeelThemeManager.shared.palette
}

// MARK: - 主题变更订阅

/// 主题变更订阅句柄：持有者释放时自动注销。
final class SeelThemeObserver {

    private var token: NSObjectProtocol?

    /// - Parameter handler: 主题变化时在主线程回调，内部请使用 `[weak self]`。
    init(_ handler: @escaping () -> Void) {
        token = NotificationCenter.default.addObserver(
            forName: .SeelThemeDidChange,
            object: nil,
            queue: .main
        ) { _ in
            handler()
        }
    }

    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

// MARK: - 外观模式下发

extension UIView {
    /// 把 SDK 的外观模式作用到该视图子树上。
    /// 强制浅色/深色时，连系统控件（毛玻璃、滚动条、指示器）也会一起切换。
    func applySeelUserInterfaceStyle() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = SeelThemeManager.shared.userInterfaceStyle
        }
    }
}

extension UIViewController {
    func applySeelUserInterfaceStyle() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = SeelThemeManager.shared.userInterfaceStyle
        }
    }
}

// MARK: - 单色图标着色

/// 加载单色图标，并在深色模式下换成 `darkTint` 指定的颜色。
///
/// 浅色下**原样返回**资源包里的图片，因此不会改变引入深色模式之前的外观；
/// 只有深色模式才做重新着色。
/// 仅适用于纯单色（带透明通道）的图标；双色图标（如带白色对勾的实心方块）
/// 重新着色会糊成一块，应继续用 `UIImage(swName:)`。
func seelThemedIcon(_ name: String, darkTint: KeyPath<SeelPalette, UIColor> = \.iconTint) -> UIImage? {
    let manager = SeelThemeManager.shared
    return manager.cachedIcon(name, darkTint: darkTint) {
        guard let original = UIImage(swName: name) else { return nil }

        let darkColor = manager.darkPalette[keyPath: darkTint]

        switch manager.mode {
        case .light:
            return original
        case .dark:
            // 重新着色本身不依赖 iOS 13，强制深色在 iOS 12 上同样要换色，
            // 否则会出现深色背景配黑色图标。
            return original.seelTinted(with: darkColor) ?? original
        case .auto:
            // 只有「随 trait 自动切换」这一步需要 iOS 13；
            // iOS 12 没有系统深色模式，auto 等同浅色，直接用原图。
            guard #available(iOS 13.0, *) else { return original }
            guard let tinted = original.seelTinted(with: darkColor) else { return original }
            let asset = UIImageAsset()
            asset.register(original, with: UITraitCollection(userInterfaceStyle: .light))
            asset.register(tinted, with: UITraitCollection(userInterfaceStyle: .dark))
            return asset.image(with: UITraitCollection(userInterfaceStyle: .light))
        }
    }
}

extension UIColor {
    /// 取出动态色在指定 trait 下的实际颜色。
    /// 需要 CGColor（边框、阴影、CAGradientLayer）时必须先解析，
    /// 因为 CGColor 不会随外观变化自动更新。
    func resolvedSeelColor(for traitCollection: UITraitCollection) -> UIColor {
        if #available(iOS 13.0, *) {
            return resolvedColor(with: traitCollection)
        }
        return self
    }
}

extension UIImage {
    /// 保留透明通道，把不透明像素整体换成指定颜色。
    func seelTinted(with color: UIColor) -> UIImage? {
        guard size.width > 0, size.height > 0 else { return nil }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return nil }

        let rect = CGRect(origin: .zero, size: size)
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        context.setBlendMode(.normal)
        context.clip(to: rect, mask: cgImage)
        color.setFill()
        context.fill(rect)

        return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(renderingMode)
    }
}
