
enum Constants {
    
    static let productName = "seel-widget-sdk"
    static let version = "2.6.0"
    static let userAgent = "seel-widget-sdk-ios/\(version)"
    static let optedValueKey = "Seel.OptedValueKey"
    static let optedOperationTimeKey = "Seel.OptedOperationTimeKey"
    static let cartIdKey = "Seel.CartIdKey"
    static let sessionIdKey = "Seel.SessionIdKey"
    static let i18nTextsKeyPrefix = "Seel.I18nTexts."

    /// merchant-configs 接口的版本。
    ///
    /// 与其它接口共用的 `version` 不同：该接口的契约按 `2.1.0` 定义
    /// （见 Shopify 前端脚本的 `SEEL_API_VERSION` 分支），发别的版本号后端可能走到旧分支。
    static let merchantConfigsAPIVersion = "2.1.0"
    
}
