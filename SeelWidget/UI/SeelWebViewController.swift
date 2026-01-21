import UIKit
import WebKit
import SnapKit

final class SeelWebViewController: UIViewController {
    
    private var webView: WKWebView!
    private var url: URL
    
    // Navigation bar
    private lazy var navigationBar: UIView = {
        let navBar = UIView()
        navBar.backgroundColor = .white
        navBar.layer.shadowColor = UIColor.black.cgColor
        navBar.layer.shadowOffset = CGSize(width: 0, height: 1)
        navBar.layer.shadowOpacity = 0.1
        navBar.layer.shadowRadius = 2
        return navBar
    }()
    
    // Back button
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("←", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Title label
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    // Close button
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Progress bar
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColor(hex: "#2121C4")
        progressView.trackTintColor = UIColor.lightGray
        progressView.progress = 0.0
        return progressView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.hidesWhenStopped = true
            indicator.startAnimating()
            return indicator
        } else {
            let indicator = UIActivityIndicatorView(style: .gray)
            indicator.hidesWhenStopped = true
            indicator.startAnimating()
            return indicator
        }
    }()
    
    public init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupUI()
        loadURL()
        addProgressObserver()
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "title")
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .clear
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add navigation bar
        view.addSubview(navigationBar)
        navigationBar.addSubview(backButton)
        navigationBar.addSubview(titleLabel)
        navigationBar.addSubview(closeButton)
        navigationBar.addSubview(progressView)
        
        // Add WebView and loading indicator
        view.addSubview(loadingIndicator)
        
        // Setup constraints
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualTo(backButton.snp.right).offset(8)
            make.right.lessThanOrEqualTo(closeButton.snp.left).offset(-8)
        }
        
        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        progressView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(2)
        }
        
        webView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // Initial state: hide back button
        backButton.isHidden = true
    }
    
    private func loadURL() {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func addProgressObserver() {
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let progress = Float(self.webView.estimatedProgress)
                self.progressView.setProgress(progress, animated: true)
            }
        } else if keyPath == "title" {
            DispatchQueue.main.async { [weak self] in
                self?.updateTitle()
            }
        }
    }
    
    @objc private func backButtonTapped() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension SeelWebViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingIndicator.startAnimating()
        progressView.progress = 0.0
        progressView.isHidden = false
        
        // Show default title
        titleLabel.text = "Loading..."
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
        progressView.progress = 1.0
        
        // Delay hiding progress bar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.progressView.isHidden = true
        }
        
        // Update back button state
        updateBackButtonState()
        
        // Delay updating title to ensure title is loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateTitle()
        }
    }
    
    private func updateTitle() {
        if let title = webView.title, !title.isEmpty {
            titleLabel.text = title
        } else {
            // If no title, show URL host part
            if let host = webView.url?.host {
                titleLabel.text = host
            } else {
                titleLabel.text = ""
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        progressView.isHidden = true
        print("WebView failed to load: \(error.localizedDescription)")
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // Update back button state
        updateBackButtonState()
        
        // Try to update title
        updateTitle()
    }
    
    private func updateBackButtonState() {
        if webView.canGoBack {
            backButton.isHidden = false
            backButton.isEnabled = true
            backButton.alpha = 1.0
        } else {
            backButton.isHidden = true
        }
    }
}
