import UIKit

#if SWIFT_PACKAGE
/// 仅用于定位当前二进制所在的 bundle，不承担其它职责。
private final class SeelBundleToken {}

/// SwiftPM 分发时的资源包。
///
/// 刻意**不使用** SwiftPM 生成的 `Bundle.module`：后者在找不到资源包时会 `fatalError`，
/// 而本 SDK 嵌在第三方 App 内，崩溃宿主 App 的代价远高于图标降级为空白。
/// 这里复刻 `Bundle.module` 的候选路径顺序，找不到时返回 nil，失败行为与修复前保持一致。
///
/// 硬编码的包名由 `UIImageSWNameTests.testBundleNameMatchesSwiftPMConvention`
/// 断言与 `Bundle.module` 指向同一个包，命名规则一旦变化会被测试拦下。
/// 注意：这里是 internal 而非 private，以便 `@testable import` 断言包名未漂移。
/// internal 不会出现在 SDK 的公开 API 中。
let seelResourceBundle: Bundle? = {
    let bundleName = "SeelWidget_SeelWidget.bundle"
    let candidates: [URL?] = [
        Bundle.main.resourceURL,                        // 包被静态链接进 App
        Bundle(for: SeelBundleToken.self).resourceURL,  // 包被链接成 framework
        Bundle.main.bundleURL,                          // 命令行工具
    ]
    for candidate in candidates {
        if let url = candidate?.appendingPathComponent(bundleName),
           let bundle = Bundle(url: url) {
            return bundle
        }
    }
    return nil
}()
#endif

extension UIImage {
    /// 从 SDK 自带的资源包加载图片。
    ///
    /// 两条分发链路的资源包名不同，必须分开处理：
    /// - SwiftPM：`<PackageName>_<TargetName>.bundle`，即 `SeelWidget_SeelWidget.bundle`
    /// - CocoaPods：`s.resource_bundles` 声明的 `SeelWidget.bundle`
    ///
    /// 此前只实现了 CocoaPods 分支，导致 SPM 集成时查找的名字对不上、
    /// 一律走到 `return nil`，widget 内所有图标静默变为空白。
    convenience init?(swName: String) {
        #if SWIFT_PACKAGE
        guard let resourceBundle = seelResourceBundle else {
            return nil
        }
        #else
        let bundle = Bundle(for: SeelWidgetSDK.self)
        guard let bundleURL = bundle.url(forResource: "SeelWidget", withExtension: "bundle"),
              let resourceBundle = Bundle(url: bundleURL) else {
            return nil
        }
        #endif
        self.init(named: swName, in: resourceBundle, compatibleWith: nil)
    }
}
