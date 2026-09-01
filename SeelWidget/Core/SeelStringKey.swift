import Foundation

/// 一条可翻译文案。
///
/// `english` 既是没有译文时的兜底显示内容，**也是查询后端译文表的 key**——
/// 后端下发的 `texts[].key` 就是英文原文（Shopify 前端脚本与 RN SDK 都是这个约定，
/// 见 `react-native-seel-widget` 的 `src/constants/key_value.ts`：
/// `dictionary[KeyValue.privacy_policy] ?? 'Privacy Policy'`）。
///
/// 因此这里的英文必须与后端文案库里的原文**逐字符一致**，改动前请先确认后端有对应条目。
struct SeelStringKey: Hashable {
    let english: String

    init(_ english: String) {
        self.english = english
    }
}

// MARK: - SDK 内置文案表
//
// 命名与取值对齐 `react-native-seel-widget` 的 `KeyValue`，
// 缺失的条目再从 Shopify 前端脚本的 `language/en.json` 补齐，
// 保证三端查的是同一批 key，后端配一次译文三端同时生效。
//
// 注意标点：文案库里的原文结尾不带 `:` / `.`，这里保持一致，
// 具体标点在使用处拼接，否则 key 对不上就永远拿不到译文。
extension SeelStringKey {

    // MARK: 与 RN SDK 的 KeyValue 一一对应

    /// `wfp_title`
    static let wfpTitle = SeelStringKey("{{title}} for {{price}}")
    /// `powered_by`
    static let poweredBy = SeelStringKey("Powered by {{seel}}")
    /// `product_name`
    static let productName = SeelStringKey("Worry-Free Purchase®")

    /// `ineligible_main_message`
    static let ineligibleMainMessage = SeelStringKey("We're unable to offer Worry-Free Purchase® for this order. This could be due to one or more of the following reasons")
    /// `ineligible_reason_shipping`
    static let ineligibleReasonShipping = SeelStringKey("Shipping destination not supported")
    /// `ineligible_reason_currency`
    static let ineligibleReasonCurrency = SeelStringKey("Checkout currency not accepted")
    /// `ineligible_reason_value`
    static let ineligibleReasonValue = SeelStringKey("Order value exceeds our coverage limit")
    /// `ineligible_reason_items`
    static let ineligibleReasonItems = SeelStringKey("Item(s) not eligible for this service")
    /// `ineligible_reason_system`
    static let ineligibleReasonSystem = SeelStringKey("Our system has flagged this order as ineligible")
    /// `ineligible_support_message`
    static let ineligibleSupportMessage = SeelStringKey("If you have any questions, please contact our customer support team for assistance")

    /// `coverage_title`
    static let coverageTitle = SeelStringKey("We've Got You Covered")
    /// `pricing_message`
    static let pricingMessage = SeelStringKey("Only {{price}} for Complete Peace of Mind")
    /// `whats_covered_title`
    static let whatsCoveredTitle = SeelStringKey("What's Covered")
    /// `get_full_refund`
    static let getFullRefund = SeelStringKey("Get a Full Refund, No Questions Asked")

    /// `privacy_policy`
    static let privacyPolicy = SeelStringKey("Privacy Policy")
    /// `terms_of_service`
    static let termsOfService = SeelStringKey("Terms of Service")
    /// `cta_secure_purchase`
    static let ctaSecurePurchase = SeelStringKey("Secure Your Purchase Now")
    /// `cta_continue_without`
    static let ctaContinueWithout = SeelStringKey("Continue Without Protection")

    /// `easy_resolution`
    static let easyResolution = SeelStringKey("Easy Resolution")
    /// `resolve_with_clicks`
    static let resolveWithClicks = SeelStringKey("Resolve your issues with just a few clicks")
    /// `complete_peace_of_mind`
    static let completePeaceOfMind = SeelStringKey("Complete Peace of Mind")
    /// `zero_risk`
    static let zeroRisk = SeelStringKey("Zero-risk on your order with our protection")
    /// `get_refund_promptly`
    static let getRefundPromptly = SeelStringKey("Get your refund promptly")

    // MARK: 取自 Shopify 前端脚本的 en.json

    static let instantResolutionTitle = SeelStringKey("Instant Resolution")
    static let instantResolutionDescription = SeelStringKey("Quick resolution in just a few clicks")
    static let supportDescription = SeelStringKey("Get help anytime with fast response")

    // MARK: iOS 独有
    //
    // RN 的 KeyValue 与 Shopify 的 en.json 里都没有对应条目。
    // 后端文案库若未收录这些英文原文，它们会一直显示英文；
    // 需要翻译时要先让后端把这些 key 加进去。

    static let optInNowForFullProtection = SeelStringKey("Opt-In Now for Full Protection")
    static let noNeed = SeelStringKey("No Need")
    static let close = SeelStringKey("Close")
    static let whatsCoveredBySeel = SeelStringKey("What's Covered by Seel")
    static let supportTitle = SeelStringKey("24/7 Support by Seel")
    static let wfpAvailableWith = SeelStringKey("Worry-Free Purchase® available with")
    static let loading = SeelStringKey("Loading...")
    static let selected = SeelStringKey("Selected")
    static let unselected = SeelStringKey("Unselected")

    // MARK: 无障碍（仅供 VoiceOver 朗读，不出现在视觉界面上）

    static let a11yOn = SeelStringKey("On")
    static let a11yOff = SeelStringKey("Off")
    static let a11yToggleHint = SeelStringKey("Double-tap to add or remove this protection")
    static let a11yInfoButtonLabel = SeelStringKey("About this protection")
    static let a11yCloseLabel = SeelStringKey("Close")
    static let a11yBackLabel = SeelStringKey("Back")
    static let a11yUnavailableHint = SeelStringKey("Double-tap to learn why this protection is unavailable")
}

extension SeelStringKey {
    /// `{{seel}}` 占位符的取值：品牌名。
    static let brandName = "Seel"
}
