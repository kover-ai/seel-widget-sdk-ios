import Foundation

/// 把设备语言归一成后端 `lang` 参数认识的标识。
///
/// 映射表与 Shopify 前端脚本的 `LANG_LIST` 保持一致，
/// 否则同一个商户在 Web 与 App 上会拿到不同粒度的语言，译文覆盖度对不上。
enum SeelLanguage {

    /// 兜底语言：后端文案库以英文原文为 key，取不到译文时展示的就是它。
    static let fallback = "en-US"

    /// 后端认识的完整标识（`语言-地区`）。命中即原样使用。
    private static let supportedTags: Set<String> = [
        "en-US", "es-ES", "es-MX", "pl-PL", "pt-PT", "it-IT", "de-DE", "de-CH",
        "cs-CZ", "fr-FR", "nl-NL", "ar-SA", "bg-BG", "ca-ES", "da-DK", "el-GR",
        "et-EE", "fi-FI", "is-IS", "he-IL", "hi-IN", "hr-HR", "hu-HU", "id-ID",
        "ja-JP", "ko-KR", "lt-LT", "lv-LV", "nb-NO", "ro-RO", "ru-RU", "sk-SK",
        "sl-SI", "sv-SE", "th-TH", "tr-TR", "uk-UA", "vi-VN",
        "zh-CN", "zh-TW", "zh-HK", "zh-SG", "zh-MO",
    ]

    /// 只有语言码时的默认地区。
    private static let defaultRegionByLanguage: [String: String] = [
        "en": "en-US", "es": "es-ES", "pl": "pl-PL", "pt": "pt-PT", "it": "it-IT",
        "de": "de-DE", "cs": "cs-CZ", "fr": "fr-FR", "nl": "nl-NL", "ar": "ar-SA",
        "bg": "bg-BG", "ca": "ca-ES", "da": "da-DK", "el": "el-GR", "et": "et-EE",
        "fi": "fi-FI", "is": "is-IS", "he": "he-IL", "hi": "hi-IN", "hr": "hr-HR",
        "hu": "hu-HU", "id": "id-ID", "ja": "ja-JP", "ko": "ko-KR", "lt": "lt-LT",
        "lv": "lv-LV", "nb": "nb-NO", "no": "nb-NO", "nn": "nb-NO", "ro": "ro-RO",
        "ru": "ru-RU", "sk": "sk-SK", "sl": "sl-SI", "sv": "sv-SE", "th": "th-TH",
        "tr": "tr-TR", "uk": "uk-UA", "vi": "vi-VN", "zh": "zh-CN",
    ]

    /// 中文按书写系统区分：iOS 给的是 `zh-Hans-CN` / `zh-Hant-TW` 这种带 script 的标识，
    /// 后端只认 `zh-CN` / `zh-TW` 一类，必须显式转换。
    private static let chineseByScriptAndRegion: [String: String] = [
        "hans": "zh-CN",
        "hans-cn": "zh-CN",
        "hans-sg": "zh-SG",
        "hant": "zh-TW",
        "hant-tw": "zh-TW",
        "hant-hk": "zh-HK",
        "hant-mo": "zh-MO",
    ]

    /// 当前应使用的语言标识。
    /// - Parameter override: 宿主显式指定的语言；为 nil 时跟随系统。
    static func resolve(override: String?) -> String {
        if let override = override, !override.trimmingCharacters(in: .whitespaces).isEmpty {
            return normalize(override) ?? fallback
        }
        for preferred in Locale.preferredLanguages {
            if let normalized = normalize(preferred) {
                return normalized
            }
        }
        return fallback
    }

    /// 把任意 BCP-47 标识归一成后端认识的形式；无法归一时返回 nil。
    static func normalize(_ identifier: String) -> String? {
        let raw = identifier.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "_", with: "-")
        guard !raw.isEmpty else { return nil }

        let parts = raw.split(separator: "-").map(String.init)
        guard let language = parts.first?.lowercased() else { return nil }

        if language == "zh" {
            let suffix = parts.dropFirst().map { $0.lowercased() }.joined(separator: "-")
            if let mapped = chineseByScriptAndRegion[suffix] { return mapped }
            // 没带 script 时按地区判断繁简，例如 zh-TW / zh-HK / zh-MO 用繁体。
            if let region = parts.dropFirst().first?.uppercased() {
                let tag = "zh-\(region)"
                if supportedTags.contains(tag) { return tag }
            }
            return "zh-CN"
        }

        if parts.count >= 2, let region = parts.last?.uppercased() {
            let tag = "\(language)-\(region)"
            if supportedTags.contains(tag) { return tag }
        }

        return defaultRegionByLanguage[language]
    }
}
