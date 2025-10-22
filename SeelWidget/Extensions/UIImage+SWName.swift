import UIKit

extension UIImage {
    convenience init?(swName: String) {
        let bundle = Bundle(for: SeelWidgetSDK.self)
        guard let bundleURL = bundle.url(forResource: "SeelWidget", withExtension: "bundle"),
              let resourceBundle = Bundle(url: bundleURL) else {
            return nil
        }
        self.init(named: swName, in: resourceBundle, compatibleWith: nil)
    }
}
