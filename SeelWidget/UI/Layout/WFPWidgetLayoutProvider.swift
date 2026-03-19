import UIKit

/// Data model passed to widget layout providers for rendering.
struct WFPWidgetLayoutData {
    let quoteResponse: QuotesResponse?
    let loading: Bool
    let toggleStyle: ToggleStyle
    let toggleIsOn: Bool
}

/// Callbacks the widget layout can trigger back to SeelWFPView.
struct WFPWidgetLayoutActions {
    let onInfoTapped: () -> Void
    let onToggleChanged: (_ isOn: Bool) -> Void
    let onDisabledTapped: () -> Void
}

/// Protocol that defines how the WFP widget builds its UI.
/// Each brand type can provide a different implementation.
protocol WFPWidgetLayoutProvider {

    /// Called once to create and add subviews into the container.
    func buildLayout(
        in container: UIView,
        actions: WFPWidgetLayoutActions
    )

    /// Called whenever data changes (quote loaded, toggle state, loading, etc.).
    func updateLayout(
        in container: UIView,
        data: WFPWidgetLayoutData
    )
}

/// Factory that returns the correct widget layout provider based on brandType.
enum WFPWidgetLayoutFactory {
    static func provider(for brandType: String?) -> WFPWidgetLayoutProvider {
        switch brandType {
        case "ebth-wfp":
            return EBTHWFPWidgetLayout()
        default:
            return DefaultWFPWidgetLayout()
        }
    }
}
