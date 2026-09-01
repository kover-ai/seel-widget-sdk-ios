import UIKit

extension UIView {

    @discardableResult
    func pinEdges(to view: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    func pinEdges(to guide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            topAnchor.constraint(equalTo: guide.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: insets.left),
            bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -insets.bottom),
            trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -insets.right)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    func centerIn(_ view: UIView) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    func constrainSize(width: CGFloat? = nil, height: CGFloat? = nil) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints: [NSLayoutConstraint] = []
        if let w = width {
            constraints.append(widthAnchor.constraint(equalToConstant: w))
        }
        if let h = height {
            constraints.append(heightAnchor.constraint(equalToConstant: h))
        }
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    func prepareForAutoLayout() {
        translatesAutoresizingMaskIntoConstraints = false
    }
}
