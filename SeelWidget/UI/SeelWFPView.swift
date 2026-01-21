import UIKit
import SnapKit

public typealias WFPOptedIn = (_ optedIn: Bool, _ quote: QuotesResponse?) -> Void

public final class SeelWFPView: UIView {
    
    /// Opted Valid Time
    /// <=0: Never Expired
    /// Default is 365 days
    public static var optedValidTime: TimeInterval = 365 * 24 * 3600
    
    public var optedIn: WFPOptedIn?
    
    private var loading: Bool = false
    private var quoteResponse: QuotesResponse?
    
    private lazy var contentSV: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .vertical
        sv.spacing = 6
        return sv
    }()
    
    private lazy var titleSV: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        return sv
    }()
    
    private lazy var detailSV: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .vertical
        sv.spacing = 6
        return sv
    }()
    
    private lazy var titleView: SeelWFPTitleView = {
        let wfpView = SeelWFPTitleView()
        wfpView.infoClicked = { [weak self] in
            self?.displayInfo()
        }
        wfpView.showPowered = true
        wfpView.showInfo = false
        return wfpView
    }()
    
    private lazy var switcher: SeelSwitch = {
        let switcher = SeelSwitch()
        switcher.onTintColor = UIColor(hex: "#2121C4")
        switcher.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        switcher.isOn = true
        switcher.onValueChanged = { [weak self] isOn in
            self?.statusChanged(isOn)
        }
        return switcher
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        configViews()
        updateViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createViews() {
        addSubview(contentSV)
        contentSV.addArrangedSubview(titleSV)
        contentSV.addArrangedSubview(detailSV)
        
        titleSV.addArrangedSubview(titleView)
        titleSV.addArrangedSubview(switcher)
    }
    
    func configViews() {
        backgroundColor = .white
        
        contentSV.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }
    }
    
    func updateViews() {
        let displayView = quoteResponse != nil
        
        isHidden = !displayView
        for subviews in contentSV.arrangedSubviews {
            subviews.isHidden = !displayView
        }
        contentSV.snp.remakeConstraints({ make in
            if displayView {
                make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
            } else {
                make.edges.equalTo(UIEdgeInsets.zero)
            }
        })
        
        let isRejected = quoteResponse?.status == .rejected
        
        alpha = isRejected ? 0.9 : 1
        
        titleView.title = quoteResponse?.extraInfo?.widgetTitle
        titleView.price = isRejected ? nil : quoteResponse?.price
        titleView.showInfo = !isRejected && quoteResponse != nil
        titleView.loading = loading
        titleView.updateViews()
        
        // Use enum convenience methods for status checking
        switcher.isHidden = quoteResponse == nil || isRejected
        
        detailSV.isHidden = quoteResponse == nil || !isRejected
        
        let msgs: [String] = quoteResponse?.extraInfo?.displayWidgetText ?? []
        
        detailSV.isHidden = msgs.count <= 0
        
        let deltaCount = msgs.count - detailSV.arrangedSubviews.count
        if deltaCount > 0 {
            for _ in 0...deltaCount {
                detailSV.addArrangedSubview(LineView(frame: .zero))
            }
        }
        for (index, view) in detailSV.arrangedSubviews.enumerated() {
            if index < msgs.count {
                view.isHidden = false
                if let lineView = view as? LineView {
                    lineView.iconImage = msgs.count > 1 ? UIImage(swName: "icon_select") : nil
                    lineView.content = msgs[index]
                    lineView.updateViews()
                }
            } else {
                view.isHidden = true
            }
        }
    }
    
}

extension SeelWFPView {
    
    public func setup(_ quote: QuotesRequest, completion: @escaping (Result<QuotesResponse, NetworkError>) -> Void) {
        createQuote(quote, isSetup: true, completion: completion)
    }

    public func updateWidgetWhenChanged(_ quote: QuotesRequest, completion: @escaping (Result<QuotesResponse, NetworkError>) -> Void) {
        createQuote(quote, isSetup: false, completion: completion)
    }

}

extension SeelWFPView {
    
    func displayInfo() {
        if let viewController = self.parentViewController,
           quoteResponse != nil
        {
            let infoViewController = SeelWFPInfoViewController(quoteResponse: quoteResponse)
            infoViewController.modalPresentationStyle = .overFullScreen
            infoViewController.optedInClicked = { [weak self] in
                self?.updateLocalOptedIn(true)
                _ = self?.turnOnIfNeed(true)
                infoViewController.dismiss(animated: true)
            }
            infoViewController.noNeedClicked = { [weak self] in
                self?.updateLocalOptedIn(false)
                _ = self?.turnOnIfNeed(false)
                infoViewController.dismiss(animated: true)
            }
            infoViewController.privacyPolicyClicked = { [weak self] in
                if let privacyPolicyURL = self?.quoteResponse?.extraInfo?.privacyPolicyURL,
                   let _url = URL.init(string: privacyPolicyURL)
                {
                    self?.openUrl(_url, base: infoViewController)
                }
            }
            infoViewController.termsClicked = { [weak self] in
                if let termsURL = self?.quoteResponse?.extraInfo?.termsURL,
                   let _url = URL.init(string: termsURL)
                {
                    self?.openUrl(_url, base: infoViewController)
                }
            }
            viewController.present(infoViewController, animated: true)
        }
    }
    
    func statusChanged(_ isOn: Bool) {
        updateLocalOptedIn(isOn)
        _ = optedChanged(isOn)
    }
    
    func openUrl(_ url: URL, base: UIViewController) {
        let webViewController = SeelWebViewController(url: url)
        webViewController.modalPresentationStyle = .fullScreen
        base.present(webViewController, animated: true)
    }

    func createQuote(_ quote: QuotesRequest, isSetup: Bool, completion: @escaping @Sendable (Result<QuotesResponse, NetworkError>) -> Void) {
        loading = true
        updateViews()
        NetworkManager.shared.createQuote(quote, completion: { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.loading = false
                completion(result)
                switch result {
                case .success(let value):
                    self.quoteResponse = value
                    self.updateViews()

                    var finalOptedIn = value.isDefaultOn ?? false
                    if let localOptValue = self.localOptedIn(value.cartID) {
                        finalOptedIn = localOptValue
                    }

                    _ = self.turnOnIfNeed(finalOptedIn)
                case .failure(_):
                    self.quoteResponse = nil
                    self.updateViews()
                    _ = self.optedChanged(false)
                }
            }
        })
    }
    
    func turnOnIfNeed(_ on: Bool) -> Bool {
        let isTargetOn = optedChanged(on)
        switcher.isOn = isTargetOn
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
