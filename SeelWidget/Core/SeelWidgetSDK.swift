import Foundation

// MARK: - Environment Enum
public enum SeelEnvironment: String {
    case development = "development"
    case production = "production"
}

@MainActor
public class SeelWidgetSDK {
    
    // MARK: - Singleton Instance
    public static let shared = SeelWidgetSDK()
    
    // MARK: - Properties
    private var _apiKey: String?
    private var _environment: SeelEnvironment = .production
    private var _adminDomain: String?
    
    // MARK: - Public Methods
    
    /// Configure SeelWidgetSDK
    /// - Parameters:
    ///   - apiKey: API key
    ///   - environment: Environment (optional, defaults to production)
    ///   - adminDomain: The merchant's myshopify domain. When provided, the SDK fetches
    ///     the merchant config right away and applies its `i18n_config` translations.
    public func configure(
        apiKey: String,
        environment: SeelEnvironment = .production,
        adminDomain: String? = nil
    ) {
        self._apiKey = apiKey
        self._environment = environment
        self._adminDomain = adminDomain

        if adminDomain != nil {
            loadMerchantConfigs()
        }
    }

    /// The merchant's myshopify domain, if configured.
    public var adminDomain: String? {
        return _adminDomain
    }
    
    /// Get current API Key
    public var apiKey: String? {
        return _apiKey
    }
    
    /// Get current environment
    public var environment: SeelEnvironment {
        return _environment
    }
    
    /// Check if configured (apiKey must be non-nil and non-empty)
    public var isConfigured: Bool {
        guard let key = _apiKey else { return false }
        return !key.isEmpty
    }
    
    // MARK: - Localization

    /// Language override, e.g. `"zh-CN"`. `nil` (default) follows the device language.
    /// Changing it re-fetches the merchant config so the new language's copy is applied.
    public var language: String? {
        get { SeelI18nManager.shared.language }
        set {
            SeelI18nManager.shared.language = newValue
            if _adminDomain != nil {
                loadMerchantConfigs()
            }
        }
    }

    /// The language actually in effect, e.g. `en-US` / `zh-CN`.
    public var resolvedLanguage: String {
        return SeelI18nManager.shared.resolvedLanguage
    }

    /// Fetch `GET /v1/shopify/merchant-configs` and apply the `i18n_config` translations.
    ///
    /// Called automatically by `configure(apiKey:environment:adminDomain:)` when an
    /// `adminDomain` is supplied; call it directly to refresh or to supply the domain later.
    /// On failure the SDK keeps whatever copy it already has (cached translations, or
    /// its built-in English), so a failed request never leaves the UI blank.
    /// - Parameters:
    ///   - adminDomain: Overrides the configured domain for this call.
    ///   - completion: Optional; receives the raw response.
    public func loadMerchantConfigs(
        adminDomain: String? = nil,
        completion: (@Sendable (Result<MerchantConfigsResponse, NetworkError>) -> Void)? = nil
    ) {
        let domain = adminDomain ?? _adminDomain
        guard let domain = domain, !domain.isEmpty else {
            sdkDebugLog("loadMerchantConfigs skipped => adminDomain is not configured")
            completion?(.failure(.invalidURL))
            return
        }
        if adminDomain != nil {
            _adminDomain = adminDomain
        }

        let lang = SeelI18nManager.shared.resolvedLanguage
        NetworkManager.shared.fetchMerchantConfigs(
            adminDomain: domain,
            sessionID: SeelWidgetSDK.sessionID(),
            lang: lang
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let count = response.primaryMerchant?.i18nConfig?.textsDictionary.count ?? 0
                    SeelWidgetSDK.shared.sdkDebugLog("merchant-configs loaded => lang: \(lang), texts: \(count)")
                    SeelI18nManager.shared.apply(response)
                case .failure(let error):
                    // 保留已有译文/内置英文，不清空。
                    SeelWidgetSDK.shared.sdkDebugLog("merchant-configs failed => \(error)")
                }
                completion?(result)
            }
        }
    }

    /// Device-scoped session id, mirroring the web script's `getOrCreateUserId()`.
    private static func sessionID() -> String {
        if let existing = UserDefaults.standard.string(forKey: Constants.sessionIdKey), !existing.isEmpty {
            return existing
        }
        let generated = UUID().uuidString
        UserDefaults.standard.set(generated, forKey: Constants.sessionIdKey)
        return generated
    }

    private func sdkDebugLog(_ message: String) {
        guard environment != .production else { return }
        print("[SeelWidgetSDK] \(message)")
    }

    // MARK: - Theme

    /// Appearance mode: `.light`, `.dark`, or `.auto` (follow the system, default).
    /// On iOS 12 `.auto` falls back to light, since the system has no dark mode.
    public var themeMode: SeelThemeMode {
        get { SeelThemeManager.shared.mode }
        set { SeelThemeManager.shared.mode = newValue }
    }

    /// Inject a custom theme. Fields left nil keep the SDK's built-in colors.
    /// - Parameters:
    ///   - theme: The custom palette, or nil to drop the override for that appearance.
    ///   - mode: `.light` / `.dark` target one appearance; `.auto` (default) applies to both.
    public func setTheme(_ theme: SeelTheme?, for mode: SeelThemeMode = .auto) {
        SeelThemeManager.shared.setTheme(theme, for: mode)
    }

    /// Drop every custom theme and go back to the built-in colors.
    public func resetTheme() {
        SeelThemeManager.shared.resetTheme()
    }

    public func createEvents(_ event: EventsRequest, completion: @escaping @Sendable (Result<EventsResponse, NetworkError>) -> Void) {
        var _event = event
        _event.eventID = UUID().uuidString
        NetworkManager.shared.createEvents(_event, completion: completion)
    }
}
