import UIKit
import SnapKit

public typealias WFPOptedIn = (_ optedIn: Bool, _ quote: QuotesResponse?) -> Void

public enum ToggleStyle {
    case switchStyle
    case checkboxStyle
}

public final class SeelWFPView: UIView {
    
    /// Opted Valid Time
    /// <=0: Never Expired
    /// Default is 365 days
    public static var optedValidTime: TimeInterval = 365 * 24 * 3600
    
    /// Toggle style: .switchStyle (default) or .checkboxStyle
    public static var toggleStyle: ToggleStyle = .switchStyle
    
    public var optedIn: WFPOptedIn?
    
    private var _normalBackgroundColor: UIColor?
    
    /// Background color for normal state. Defaults to the view's own backgroundColor.
    public var normalBackgroundColor: UIColor {
        get { _normalBackgroundColor ?? (backgroundColor ?? .clear) }
        set { _normalBackgroundColor = newValue }
    }
    
    private var _selectedBackgroundColor: UIColor?
    
    /// Background color for selected (optedIn) state. Defaults to the view's own backgroundColor.
    public var selectedBackgroundColor: UIColor {
        get { _selectedBackgroundColor ?? (backgroundColor ?? .clear) }
        set { _selectedBackgroundColor = newValue }
    }
    
    public var disabledBackgroundColor: UIColor = UIColor(hex: "#F0EFEF")
    
    private var _showDisclaimer: Bool?
    
    /// Whether to show the widget disclaimer text.
    /// If not explicitly set, uses the brand layout provider's default.
    public var showDisclaimer: Bool {
        get { _showDisclaimer ?? (layoutProvider?.defaultShowDisclaimer ?? true) }
        set { _showDisclaimer = newValue }
    }
    
    /// Corner radius for the widget. Defaults to 0 (no rounding).
    public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            clipsToBounds = cornerRadius > 0
        }
    }
    
    private var loading: Bool = false
    private var quoteResponse: QuotesResponse?
    private var toggleIsOn: Bool = true
    private var layoutProvider: WFPWidgetLayoutProvider?
    private var latestRequestToken: Int = 0
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        buildDefaultLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Build the initial layout with default provider (before quote response is available).
    private func buildDefaultLayout() {
        rebuildLayout(brandType: nil)
    }
    
    /// Tear down existing layout and rebuild with the correct provider for the given brandType.
    private func rebuildLayout(brandType: String?) {
        subviews.forEach { $0.removeFromSuperview() }
        
        let provider = WFPWidgetLayoutFactory.provider(for: brandType)
        self.layoutProvider = provider
        
        provider.buildLayout(in: self, actions: WFPWidgetLayoutActions(
            onInfoTapped: { [weak self] in self?.displayInfo() },
            onToggleChanged: { [weak self] isOn in self?.statusChanged(isOn) },
            onDisabledTapped: { [weak self] in self?.showDisabledTooltip() }
        ))
        
        refreshLayout()
    }
    
    /// Push current state to the layout provider for rendering.
    private func refreshLayout() {
        layoutProvider?.updateLayout(in: self, data: WFPWidgetLayoutData(
            quoteResponse: quoteResponse,
            loading: loading,
            toggleStyle: SeelWFPView.toggleStyle,
            toggleIsOn: toggleIsOn,
            normalBackgroundColor: normalBackgroundColor,
            selectedBackgroundColor: selectedBackgroundColor,
            disabledBackgroundColor: disabledBackgroundColor,
            showDisclaimer: showDisclaimer
        ))
    }

    private func sdkDebugLog(_ message: String) {
        guard SeelWidgetSDK.shared.environment != .production else { return }
        print("[SeelWidgetSDK] \(message)")
    }
}

// MARK: - Public API

extension SeelWFPView {
    
    public func setup(_ quote: QuotesRequest, completion: @escaping (Result<QuotesResponse, NetworkError>) -> Void) {
        createQuote(quote, isSetup: true, completion: completion)
    }

    public func updateWidgetWhenChanged(_ quote: QuotesRequest, completion: @escaping (Result<QuotesResponse, NetworkError>) -> Void) {
        createQuote(quote, isSetup: false, completion: completion)
    }

    /// Update checkbox/switch UI state immediately.
    /// This is useful for pre-request UI updates in host app debug flows.
    public func setToggleState(_ isOn: Bool) {
        toggleIsOn = isOn
        refreshLayout()
    }
}

// MARK: - Actions & Business Logic

extension SeelWFPView {
    
    func displayInfo() {
        if let viewController = self.parentViewController,
           quoteResponse != nil
        {
            let infoViewController = SeelWFPInfoViewController(quoteResponse: quoteResponse, brandType: quoteResponse?.type)
            let layoutProvider = WFPInfoLayoutFactory.provider(for: quoteResponse?.type)
            infoViewController.modalPresentationStyle = layoutProvider.preferredPresentationStyle
            infoViewController.optedInClicked = { [weak self, weak infoViewController] in
                self?.updateLocalOptedIn(true)
                _ = self?.turnOnIfNeed(true)
                infoViewController?.dismiss(animated: true)
            }
            infoViewController.noNeedClicked = { [weak self, weak infoViewController] in
                self?.updateLocalOptedIn(false)
                _ = self?.turnOnIfNeed(false)
                self?.postOptOutUserConfig()
                infoViewController?.dismiss(animated: true)
            }
            infoViewController.privacyPolicyClicked = { [weak self, weak infoViewController] in
                if let privacyPolicyURL = self?.quoteResponse?.extraInfo?.privacyPolicyURL,
                   let _url = URL.init(string: privacyPolicyURL),
                   let infoVC = infoViewController
                {
                    self?.openUrl(_url, base: infoVC)
                }
            }
            infoViewController.termsClicked = { [weak self, weak infoViewController] in
                if let termsURL = self?.quoteResponse?.extraInfo?.termsURL,
                   let _url = URL.init(string: termsURL),
                   let infoVC = infoViewController
                {
                    self?.openUrl(_url, base: infoVC)
                }
            }
            viewController.present(infoViewController, animated: true)
        }
    }
    
    func showDisabledTooltip() {
        guard let window = self.window else { return }
        SeelTooltipView.show(in: window, anchorView: self, quoteResponse: quoteResponse)
    }
    
    func statusChanged(_ isOn: Bool) {
        toggleIsOn = isOn
        updateLocalOptedIn(isOn)
        _ = optedChanged(isOn)

        if !isOn {
            postOptOutUserConfig()
        }
    }
    
    /// POST /v1/ecommerce/user-configs/{user_id} when the user opts out (unchecks).
    /// Currently only enabled for EBTH platform (type == "ebth-wfp").
    /// Requires both merchant_id and customer.customer_id from the latest quote response.
    private func postOptOutUserConfig() {
        guard quoteResponse?.type == "ebth-wfp" else { return }
        guard let merchantID = quoteResponse?.merchantID,
              let userID = quoteResponse?.customer?.customerID,
              !merchantID.isEmpty,
              !userID.isEmpty else {
            sdkDebugLog("postOptOutUserConfig skipped => missing merchant_id or customer_id")
            return
        }
        sdkDebugLog("postOptOutUserConfig => merchant_id: \(merchantID), user_id: \(userID), opted_out: true")
        NetworkManager.shared.postUserConfig(merchantID: merchantID, userID: userID, optedOut: true)
    }

    func openUrl(_ url: URL, base: UIViewController) {
        let webViewController = SeelWebViewController(url: url)
        webViewController.modalPresentationStyle = .fullScreen
        base.present(webViewController, animated: true)
    }

    func createQuote(_ quote: QuotesRequest, isSetup: Bool, completion: @escaping @Sendable (Result<QuotesResponse, NetworkError>) -> Void) {
        latestRequestToken += 1
        let requestToken = latestRequestToken
        loading = true
        refreshLayout()
        NetworkManager.shared.createQuote(quote, completion: { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if requestToken != self.latestRequestToken {
                    self.sdkDebugLog("ignore stale quote response => token: \(requestToken), latest: \(self.latestRequestToken)")
                    completion(.failure(.cancelled))
                    return
                }
                self.loading = false
                completion(result)
                switch result {
                case .success(let value):
                    let summary = "quote response => type: \(value.type ?? "nil"), status: \(value.status?.rawValue ?? "nil"), is_default_on: \(String(describing: value.isDefaultOn))"
                    self.sdkDebugLog(summary)
                    if let responseData = try? JSONEncoder().encode(value),
                       let responseJSON = String(data: responseData, encoding: .utf8) {
                        self.sdkDebugLog("quote response json => \(responseJSON)")
                    }

                    let previousType = self.quoteResponse?.type
                    self.quoteResponse = value
                    
                    if value.type != previousType {
                        self.rebuildLayout(brandType: value.type)
                    } else {
                        self.refreshLayout()
                    }

                    self.sdkDebugLog("ignore is_default_on for UI => server: \(String(describing: value.isDefaultOn)), current toggle: \(self.toggleIsOn)")
                    // Keep UI toggle as-is, but still notify host about latest optedIn/quote state.
                    _ = self.optedChanged(self.toggleIsOn)
                case .failure(_):
                    self.sdkDebugLog("quote request failed => \(result)")
                    self.quoteResponse = nil
                    self.refreshLayout()
                    _ = self.optedChanged(false)
                }
            }
        })
    }
    
    func turnOnIfNeed(_ on: Bool) -> Bool {
        let isTargetOn = optedChanged(on)
        toggleIsOn = isTargetOn
        refreshLayout()
        return isTargetOn
    }
    
    func canOptedIn() -> Bool {
        if !loading,
           quoteResponse != nil,
           quoteResponse?.status != .rejected {
            return true
        }
        return false
    }
    
    func optedChanged(_ opted: Bool) -> Bool {
        var isTargetOn = opted
        let canOptedIn = canOptedIn()
        if !canOptedIn {
            isTargetOn = false
        }
        if let _optedIn = optedIn {
            _optedIn(isTargetOn, quoteResponse)
        }
        return isTargetOn
    }
}

// MARK: - Local Opted State Persistence

extension SeelWFPView {
    
    public class func cleanLocalOpted() {
        UserDefaults.standard.removeObject(forKey: Constants.optedValueKey)
        UserDefaults.standard.removeObject(forKey: Constants.optedOperationTimeKey)
    }
    
    func updateLocalOptedIn(_ optedIn: Bool) {
        UserDefaults.standard.set(quoteResponse?.cartID, forKey: Constants.cartIdKey)
        UserDefaults.standard.set(optedIn, forKey: Constants.optedValueKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: Constants.optedOperationTimeKey)
    }
    
    func localOptedIn(_ cartID: String?) -> Bool? {
        if cartID != nil,
           let localCartID = UserDefaults.standard.value(forKey: Constants.cartIdKey) as? String,
           cartID == localCartID {
            return UserDefaults.standard.value(forKey: Constants.optedValueKey) as? Bool
        }
        if SeelWFPView.optedValidTime > 0 {
            guard let _optedOperationTime = UserDefaults.standard.value(forKey: Constants.optedOperationTimeKey) as? TimeInterval,
                  (_optedOperationTime + SeelWFPView.optedValidTime) > Date().timeIntervalSince1970 else {
                return nil
            }
        }
        return UserDefaults.standard.value(forKey: Constants.optedValueKey) as? Bool
    }
}
