import Foundation

public struct EventsRequest: Codable {
    
    /// Event ID
    var eventID: String?
    
    /// Session ID
    public var sessionID: String?
    
    /// Event created timestamp in milliseconds
    public var eventTs: String?
    
    /// Customer ID
    public var customerID: String?
    
    /// Device ID
    public var deviceID: String?
    
    /// Browser IP address
    public var clientIp: String?
    
    /// Event source
    public var eventSource: String?
    
    /// Event type
    /// product_page_enter / product_page_exit / product_share / favorite_add / favorite_remove / cart_add / cart_remove / ra_checked / ra_unchecked / checkout_begin / checkout_complete
    public var eventType: String?
    
    /// Event information object
    /// Each event_type has its own unique schema. For specific details, please refer to the custom pixel guide.
    public var eventInfo: [String: AnyCodable]?
    
    public init(sessionID: String? = nil, eventTs: String? = nil, customerID: String? = nil, deviceID: String? = nil, clientIp: String? = nil, eventSource: String? = nil, eventType: String? = nil, eventInfo: [String: AnyCodable]? = nil) {
        self.sessionID = sessionID
        self.eventTs = eventTs
        self.customerID = customerID
        self.deviceID = deviceID
        self.clientIp = clientIp
        self.eventSource = eventSource
        self.eventType = eventType
        self.eventInfo = eventInfo
    }
    
    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case eventTs = "event_ts"
        case customerID = "customer_id"
        case deviceID = "device_id"
        case clientIp = "client_ip"
        case eventSource = "event_source"
        case eventType = "event_type"
        case eventInfo = "event_info"
    }
}
