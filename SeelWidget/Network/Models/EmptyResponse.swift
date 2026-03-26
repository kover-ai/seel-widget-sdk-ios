import Foundation

/// A response type for fire-and-forget API calls where the response body is irrelevant.
/// Accepts any valid JSON (object, array, string, number, bool, null) without failing.
struct EmptyResponse: Codable, Sendable {
    init() {}

    init(from decoder: Decoder) throws {
        // Accept any JSON structure without extracting values
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
