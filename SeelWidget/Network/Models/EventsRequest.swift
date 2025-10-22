import Foundation

public struct EventsRequest: Codable {
    
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
    public var eventInfo: EventInfo?
    
    public init(sessionID: String? = nil, eventTs: String? = nil, customerID: String? = nil, deviceID: String? = nil, clientIp: String? = nil, eventSource: String? = nil, eventType: String? = nil, eventInfo: EventInfo? = nil) {
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

public struct EventInfo: Codable {
    
    /// User email address
    public var userEmail: String?
    
    /// User phone number
    public var userPhoneNumber: String?
    
    /// Shipping address information
    public var shippingAddress: EventShippingAddress?
    
    /// initializer
    public init(
        userEmail: String? = nil,
        userPhoneNumber: String? = nil,
        shippingAddress: EventShippingAddress? = nil
    ) {
        self.userEmail = userEmail
        self.userPhoneNumber = userPhoneNumber
        self.shippingAddress = shippingAddress
    }
    
    enum CodingKeys: String, CodingKey {
        case userEmail = "user_email"
        case userPhoneNumber = "user_phone_number"
        case shippingAddress = "shipping_address"
    }
}

public struct EventShippingAddress: Codable {
    
    public var country: String?
    
    public var state: String?
    
    public var city: String?
    
    public var zipcode: String?
    
    /// initializer
    public init(
        country: String? = nil,
        state: String? = nil,
        city: String? = nil,
        zipcode: String? = nil
    ) {
        self.country = country
        self.state = state
        self.city = city
        self.zipcode = zipcode
    }
    
    enum CodingKeys: String, CodingKey {
        case country = "shipping_address_country"
        case state = "shipping_address_state"
        case city = "shipping_address_city"
        case zipcode = "shipping_address_zipcode"
    }
}
