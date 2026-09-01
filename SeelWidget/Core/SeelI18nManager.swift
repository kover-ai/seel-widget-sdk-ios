import Foundation

/// 多语言中心：持有后端下发的译文表，并向视图层提供查表能力。
///
/// 译文来自 `GET /v1/shopify/merchant-configs` 的 `merchants[0].i18n_config.texts`，
/// 结构是 `[{ key: 英文原文, value: 译文 }]`，这里拍平成字典按英文原文查。
/// 拿不到译文时一律回落英文原文，所以**接口失败不会导致界面空白**。
///
/// 只应在主线程访问。
public final class SeelI18nManager {

    public static let shared = SeelI18nManager()

    private init() {
        restoreCachedTexts()
    }

    // MARK: - 语言

    private var languageOverride: String?

    /// 显式指定语言（如 `"zh-CN"`）；设为 nil 表示跟随系统。
    /// 修改后需要重新拉取配置才能拿到对应语言的译文。
    public var language: String? {
        get { languageOverride }
        set {
            let normalized = newValue.flatMap { SeelLanguage.normalize($0) }
            guard normalized != languageOverride else { return }
            languageOverride = normalized
            // 语言变了，旧译文不再适用，先清空回落到英文，等新配置拉回来。
            merchantTexts = [:]
            quoteTexts = [:]
            texts = [:]
            restoreCachedTexts()
            notifyChange()
        }
    }

    /// 实际生效的语言标识，例如 `en-US`、`zh-CN`。
    public var resolvedLanguage: String {
        SeelLanguage.resolve(override: languageOverride)
    }

    // MARK: - 译文表

    private(set) var texts: [String: String] = [:]

    /// 是否已经拿到过译文。
    public var isLoaded: Bool { !texts.isEmpty }

    /// 直接注入译文表（key 为英文原文）。
    /// 适合宿主已有自己的文案管线、或离线 / 测试场景。
    /// 注入的内容与 merchant-configs 同层，仍会被报价响应里的译文覆盖。
    public func setTexts(_ texts: [String: String]) {
        merchantTexts = texts
        rebuildTexts()
    }

    /// 清空译文，回到 SDK 内置英文。
    public func reset() {
        merchantTexts = [:]
        quoteTexts = [:]
        clearCachedTexts()
        rebuildTexts()
    }

    // 译文有两路来源，分开存再合并：
    //   1. merchant-configs：进 App 就能拿到，覆盖全部界面，是基础层；
    //   2. quotes 响应的 extra_info.i18n：随每次报价下发，可能带该笔订单专属的措辞。
    // 合并时报价这一路优先——它更贴近当前上下文。
    // 分开存是为了「换一笔报价」不会把基础层洗掉。

    private var merchantTexts: [String: String] = [:]
    private var quoteTexts: [String: String] = [:]

    /// 消化一次 merchant-configs 响应。
    func apply(_ response: MerchantConfigsResponse) {
        merchantTexts = response.primaryMerchant?.i18nConfig?.textsDictionary ?? [:]
        cacheTexts(merchantTexts)
        rebuildTexts()
    }

    /// 消化一次报价响应里携带的译文。
    func apply(quoteI18n: MerchantConfigsResponse.I18nConfig?) {
        let dictionary = quoteI18n?.textsDictionary ?? [:]
        guard dictionary != quoteTexts else { return }
        quoteTexts = dictionary
        rebuildTexts()
    }

    private func rebuildTexts() {
        var merged = merchantTexts
        for (key, value) in quoteTexts {
            merged[key] = value
        }
        guard merged != texts else { return }
        texts = merged
        notifyChange()
    }

    // MARK: - 查表

    /// 查询一条内置文案。
    func t(_ key: SeelStringKey) -> String {
        texts[key.english] ?? key.english
    }

    /// 查询一条内置文案并填充 `{{占位符}}`。
    func t(_ key: SeelStringKey, _ values: [String: String]) -> String {
        interpolate(t(key), values)
    }

    /// 翻译服务端下发的英文原文（报价接口的 `widget_title`、`coverage_details_text` 等）。
    ///
    /// 与 Shopify 前端 `i18nConfigTextsJson[text] || text` 的做法一致：
    /// 这些文案本身也是英文原文，同样能在译文表里查到对应语言的版本。
    func t(_ raw: String?) -> String? {
        guard let raw = raw, !raw.isEmpty else { return raw }
        return texts[raw] ?? raw
    }

    /// 替换 `{{name}}` 形式的占位符；没有对应值的占位符原样保留。
    func interpolate(_ template: String, _ values: [String: String]) -> String {
        guard template.contains("{{") else { return template }
        var result = template
        for (name, value) in values {
            result = result.replacingOccurrences(of: "{{\(name)}}", with: value)
        }
        return result
    }

    // MARK: - 本地缓存
    //
    // 冷启动时接口还没回来，界面会先渲染一次。没有缓存的话每次启动都要闪一下英文，
    // 所以把上一次的译文按「语言」存起来，启动即可用，拿到新响应再覆盖。

    private func cacheKey(for language: String) -> String {
        "\(Constants.i18nTextsKeyPrefix)\(language)"
    }

    private func restoreCachedTexts() {
        guard merchantTexts.isEmpty else { return }
        let key = cacheKey(for: resolvedLanguage)
        guard let cached = UserDefaults.standard.dictionary(forKey: key) as? [String: String] else { return }
        merchantTexts = cached
        texts = cached
    }

    private func cacheTexts(_ texts: [String: String]) {
        let key = cacheKey(for: resolvedLanguage)
        if texts.isEmpty {
            UserDefaults.standard.removeObject(forKey: key)
        } else {
            UserDefaults.standard.set(texts, forKey: key)
        }
    }

    private func clearCachedTexts() {
        UserDefaults.standard.removeObject(forKey: cacheKey(for: resolvedLanguage))
    }

    private func notifyChange() {
        NotificationCenter.default.post(name: .SeelI18nDidChange, object: self)
    }
}

extension Notification.Name {
    /// 译文表发生变化时发出；SDK 内部视图会据此重建文案。
    public static let SeelI18nDidChange = Notification.Name("SeelI18nDidChange")
}

// MARK: - 视图层快捷入口

/// 查询内置文案。
func seelText(_ key: SeelStringKey) -> String {
    SeelI18nManager.shared.t(key)
}

/// 查询内置文案并填充占位符。
func seelText(_ key: SeelStringKey, _ values: [String: String]) -> String {
    SeelI18nManager.shared.t(key, values)
}

/// 翻译服务端下发的英文文案。
func seelServerText(_ raw: String?) -> String? {
    SeelI18nManager.shared.t(raw)
}

/// 按模板拼装富文本，各占位符可以带自己的字体 / 颜色。
///
/// 之所以不用字符串相加：`"标题" + " for " + "$3.75"` 把词序写死在了代码里，
/// 而各语言的词序不同（模板 `{{title}} for {{price}}` 在别的语言里可能是价格在前）。
/// - Parameters:
///   - key: 含 `{{占位符}}` 的文案。
///   - segments: 占位符名 → (替换内容, 该段的属性)。
///   - defaultAttributes: 模板里字面量部分的属性。
/// - Note: 未提供替换内容的占位符原样保留，便于在调试时发现漏传。
func seelComposedText(
    _ key: SeelStringKey,
    segments: [String: (text: String, attributes: [NSAttributedString.Key: Any])],
    defaultAttributes: [NSAttributedString.Key: Any]
) -> NSAttributedString {
    let template = seelText(key)
    let result = NSMutableAttributedString()
    var literal = ""

    func flushLiteral() {
        guard !literal.isEmpty else { return }
        result.append(NSAttributedString(string: literal, attributes: defaultAttributes))
        literal = ""
    }

    var index = template.startIndex
    while index < template.endIndex {
        guard let open = template.range(of: "{{", range: index..<template.endIndex),
              let close = template.range(of: "}}", range: open.upperBound..<template.endIndex) else {
            literal += String(template[index...])
            break
        }
        literal += String(template[index..<open.lowerBound])
        let name = String(template[open.upperBound..<close.lowerBound])
        if let segment = segments[name] {
            flushLiteral()
            result.append(NSAttributedString(string: segment.text, attributes: segment.attributes))
        } else {
            literal += "{{\(name)}}"
        }
        index = close.upperBound
    }
    flushLiteral()

    return result
}
