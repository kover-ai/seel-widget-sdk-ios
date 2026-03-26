import Foundation

struct UserConfigRequest: Codable, Sendable {
    let merchantID: String
    let optedOut: Bool

    enum CodingKeys: String, CodingKey {
        case merchantID = "merchant_id"
        case optedOut = "opted_out"
    }
}
