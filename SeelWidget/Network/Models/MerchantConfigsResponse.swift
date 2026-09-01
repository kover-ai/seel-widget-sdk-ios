import Foundation

/// `GET /v1/shopify/merchant-configs` 的响应。
///
/// 该接口同时承载商户开关、样式、多语言等配置；iOS SDK 目前只消费 `i18n_config`，
/// 其余字段（`seel_services` 等）刻意不解析，避免后端扩字段时解码失败。
public struct MerchantConfigsResponse: Codable, Sendable {

    public let merchants: [Merchant]?

    /// 前端约定只取首个商户（与 Shopify 侧 `merchants[0]` 的取法保持一致）。
    public var primaryMerchant: Merchant? { merchants?.first }

    public struct Merchant: Codable, Sendable {
        public let merchantID: String?
        public let adminDomain: String?
        public let merchantCurrency: String?
        public let i18nConfig: I18nConfig?

        enum CodingKeys: String, CodingKey {
            case merchantID = "merchant_id"
            case adminDomain = "admin_domain"
            case merchantCurrency = "merchant_currency"
            case i18nConfig = "i18n_config"
        }
    }

    /// 多语言配置容器。
    public struct I18nConfig: Codable, Sendable {
        /// 后端回给的语言标识。
        public let lang: String?
        /// 文案键值对；`key` 是英文原文，`value` 是该语言下的译文。
        public let texts: [Text]?

        public struct Text: Codable, Sendable {
            public let key: String?
            public let value: String?
        }

        /// 拍平成字典，丢弃 key 或 value 为空的条目。
        public var textsDictionary: [String: String] {
            var result: [String: String] = [:]
            for item in texts ?? [] {
                guard let key = item.key, !key.isEmpty,
                      let value = item.value, !value.isEmpty else { continue }
                result[key] = value
            }
            return result
        }
    }
}

/// `GET /v1/shopify/merchant-configs` 的查询参数。
struct MerchantConfigsRequest: Codable {
    /// 店铺的 myshopify 域名。
    let adminDomain: String
    /// 会话 id，与 Shopify 侧 `getOrCreateUserId()` 同语义。
    let sessionID: String
    /// 语言标识，如 `en-US` / `zh-CN`。
    let lang: String

    enum CodingKeys: String, CodingKey {
        case adminDomain = "admin_domain"
        case sessionID = "session_id"
        case lang
    }
}
