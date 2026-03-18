import UIKit
import ObjectiveC

/// Protocol that defines how the WFP info modal builds its UI.
/// Each brand type can provide a different implementation.
protocol WFPInfoLayoutProvider {
    var preferredPresentationStyle: UIModalPresentationStyle { get }
    
    func buildLayout(
        in viewController: UIViewController,
        quoteResponse: QuotesResponse?,
        actions: WFPInfoLayoutActions
    )
}

extension WFPInfoLayoutProvider {
    var preferredPresentationStyle: UIModalPresentationStyle { .overFullScreen }
}

struct WFPInfoLayoutActions {
    let onClose: () -> Void
    let onOptIn: () -> Void
    let onNoNeed: () -> Void
    let onPrivacyPolicy: () -> Void
    let onTerms: () -> Void
}

/// Bridges a closure to UIButton's target-action pattern (iOS 12+ compatible).
final class ClosureTarget: NSObject {
    private let handler: () -> Void
    
    init(_ handler: @escaping () -> Void) {
        self.handler = handler
    }
    
    @objc func invoke() {
        handler()
    }
}

private var closureTargetsKey: UInt8 = 0

extension UIButton {
    /// Adds a closure-based tap handler compatible with iOS 12+.
    /// Retains the target via associated objects so it stays alive with the button.
    func addTapHandler(_ handler: @escaping () -> Void) {
        let target = ClosureTarget(handler)
        addTarget(target, action: #selector(ClosureTarget.invoke), for: .touchUpInside)
        
        var targets = objc_getAssociatedObject(self, &closureTargetsKey) as? [ClosureTarget] ?? []
        targets.append(target)
        objc_setAssociatedObject(self, &closureTargetsKey, targets, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

/// Factory that returns the correct layout provider based on brandType.
/// Add new cases here as more brand types are supported.
enum WFPInfoLayoutFactory {
    static func provider(for brandType: String?) -> WFPInfoLayoutProvider {
        switch brandType {
        case "ebth-wfp":
            return EBTHWFPInfoLayout()
        default:
            return DefaultWFPInfoLayout()
        }
    }
}
