import UIKit

/// Protocol that defines how the PDP banner builds its UI.
/// Each brand type can provide a different implementation.
protocol PDPBannerLayoutProvider {
    func buildLayout(in container: UIView)
}

/// Factory that returns the correct PDP banner layout provider based on brandType.
enum PDPBannerLayoutFactory {
    static func provider(
        for brandType: String?,
        backgroundColor: UIColor = .white,
        padding: UIEdgeInsets = .zero
    ) -> PDPBannerLayoutProvider {
        switch brandType {
        case "ebth-wfp":
            return EBTHPDPBanner(backgroundColor: backgroundColor, padding: padding)
        default:
            return DefaultPDPBanner(backgroundColor: backgroundColor, padding: padding)
        }
    }
}
