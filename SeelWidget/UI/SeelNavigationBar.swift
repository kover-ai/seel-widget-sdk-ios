import UIKit
import SnapKit

final class SeelNavigationBar: UIView {

    public var title: String? {
        didSet { titleLabel.text = title }
    }
    
    private lazy var lineView = UIView(frame: .zero)

    public var titleTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(hex: "#333333"),
        .font: UIFont.systemFont(ofSize: 17, weight: .medium)
    ] {
        didSet { applyTitleTextAttributes() }
    }

    public var leftBarButtonItems: [UIButton]? {
        didSet { updateStack(leftStack, with: leftBarButtonItems) }
    }

    public var rightBarButtonItems: [UIButton]? {
        didSet { updateStack(rightStack, with: rightBarButtonItems) }
    }

    private let containerView = UIView()
    private let navigationView = UIView()
    private let leftStack = UIStackView()
    private let rightStack = UIStackView()

    private let titleLabel = UILabel()

    // MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        configViews()
        applyTitleTextAttributes()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createViews()
        configViews()
        applyTitleTextAttributes()
    }

    // MARK: - Layout
    public override var intrinsicContentSize: CGSize {
        // Default UINavigationBar height without large title: 44
        CGSize(width: UIView.noIntrinsicMetric, height: 44)
    }

    // MARK: - Public helpers
    public func setLeftBarButtonItems(_ items: [UIButton]?, animated: Bool = false) {
        replaceStack(leftStack, with: items, animated: animated)
        leftBarButtonItems = items
    }

    public func setRightBarButtonItems(_ items: [UIButton]?, animated: Bool = false) {
        replaceStack(rightStack, with: items, animated: animated)
        rightBarButtonItems = items
    }

    // MARK: - Private setup
    private func createViews() {
        clipsToBounds = true
        
        backgroundColor = .white

        addSubview(containerView)
        addSubview(lineView)
        
        lineView.backgroundColor = UIColor(hex: "#EEEEEE")

        leftStack.axis = .horizontal
        leftStack.alignment = .center
        leftStack.spacing = 4

        rightStack.axis = .horizontal
        rightStack.alignment = .center
        rightStack.spacing = 4

        titleLabel.textAlignment = .center
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        containerView.addSubview(navigationView)
        navigationView.addSubview(leftStack)
        navigationView.addSubview(titleLabel)
        navigationView.addSubview(rightStack)
    }

    private func configViews() {
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
        }
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(1)
        }
        navigationView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
            make.height.greaterThanOrEqualTo(44)
        }
        leftStack.snp.makeConstraints { make in
            make.left.equalTo(containerView.snp.left).offset(8)
            make.top.bottom.equalTo(containerView)
        }
        rightStack.snp.makeConstraints { make in
            make.right.equalTo(containerView.snp.right).offset(-8)
            make.top.bottom.equalTo(containerView)
        }
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualTo(leftStack.snp.right)
            make.right.lessThanOrEqualTo(rightStack.snp.left)
        }
    }

    // MARK: - Updates
    private func applyTitleTextAttributes() {
        if let color = titleTextAttributes[.foregroundColor] as? UIColor {
            titleLabel.textColor = color
        }
        if let font = titleTextAttributes[.font] as? UIFont {
            titleLabel.font = font
        }
    }

    private func updateStack(_ stack: UIStackView, with items: [UIButton]?) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let items = items, !items.isEmpty else { return }
        for button in items {
            configureButtonAppearance(button)
            stack.addArrangedSubview(button)
        }
    }

    private func replaceStack(_ stack: UIStackView, with items: [UIButton]?, animated: Bool) {
        if animated {
            UIView.transition(with: stack, duration: 0.25, options: .transitionCrossDissolve, animations: {
                self.updateStack(stack, with: items)
            })
        } else {
            updateStack(stack, with: items)
        }
    }

    private func configureButtonAppearance(_ button: UIButton) {
        if button.constraints.isEmpty {
            button.snp.makeConstraints { make in
                make.width.greaterThanOrEqualTo(32)
                make.height.equalTo(32)
            }
        }
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        // Add default tint to match title color if not customized
        button.tintColor = (titleTextAttributes[.foregroundColor] as? UIColor) ?? .black
        if button.titleColor(for: .normal) == nil {
            button.setTitleColor(button.tintColor, for: .normal)
        }
    }
}
