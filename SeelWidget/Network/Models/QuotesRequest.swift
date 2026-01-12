import Foundation

public struct QuotesRequest: Codable {
    /// The ID of a cart
    public var cartID: String?
    
    /// The unique identifier for the merchant within Seel's system
    public var merchantID: String?
    
    /// The ID of the shopping session
    public var sessionID: String?
    
    /// The type of device from which user activity originated
    /// desktop, mobile or tablet
    public var deviceCategory: String?
    
    /// The method by which users accessed your website or application
    /// Web, iOS or Android
    public var devicePlatform: String?
    
    /// The ID of the client device
    public var deviceID: String?
    
    /// The IP address of the client
    public var clientIp: String?
    
    /// The type of the quote
    public var type: String?
    
    /// The default opt-in setting for the quote
    public var isDefaultOn: Bool?
    
    /// The list of items included in the quote
    public var lineItems: [QuoteLineItem]?
    
    /// Shipping address information
    public var shippingAddress: QuoteShippingAddress?
    
    /// Customer information
    public var customer: QuoteCustomer?
    
    /// Additional information for the quote
    public var extraInfo: QuoteExtraInfo?
    
    public init(
        cartID: String? = nil,
        merchantID: String? = nil,
        sessionID: String? = nil,
        deviceCategory: String? = nil,
        devicePlatform: String? = nil,
        deviceID: String? = nil,
        clientIp: String? = nil,
        type: String? = nil,
        isDefaultOn: Bool? = nil,
        lineItems: [QuoteLineItem]? = nil,
        shippingAddress: QuoteShippingAddress? = nil,
        customer: QuoteCustomer? = nil,
        extraInfo: QuoteExtraInfo? = nil
    ) {
        self.cartID = cartID
        self.merchantID = merchantID
        self.sessionID = sessionID
        self.deviceCategory = deviceCategory
        self.devicePlatform = devicePlatform
        self.deviceID = deviceID
        self.clientIp = clientIp
        self.type = type
        self.isDefaultOn = isDefaultOn
        self.lineItems = lineItems
        self.shippingAddress = shippingAddress
        self.customer = customer
        self.extraInfo = extraInfo
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case cartID = "cart_id"
        case sessionID = "session_id"
        case merchantID = "merchant_id"
        case deviceID = "device_id"
        case deviceCategory = "device_category"
        case devicePlatform = "device_platform"
        case isDefaultOn = "is_default_on"
        case lineItems = "line_items"
        case shippingAddress = "shipping_address"
        case customer
        case extraInfo = "extra_info"
    }
}

public struct QuoteLineItem: Codable {
    public var lineItemID: String?
    public var productID: String?
    public var variantID: String?
    public var productTitle: String?
    public var variantTitle: String?
    public var price: Double?
    public var quantity: Int?
    public var currency: String?
    public var salesTax: Double?
    public var requiresShipping: Bool?
    public var finalPrice: String?
    public var isFinalSale: Bool?
    public var allocatedDiscounts: Double?
    public var category1: String?
    public var category2: String?
    public var imageURLs: [String]?
    public var brandName: String?
    public var shippingOrigin: QuoteShippingOrigin?
    
    public init(lineItemID: String? = nil, productID: String? = nil, variantID: String? = nil, productTitle: String? = nil, variantTitle: String? = nil, price: Double? = nil, quantity: Int? = nil, currency: String? = nil, salesTax: Double? = nil, requiresShipping: Bool? = nil, finalPrice: String? = nil, isFinalSale: Bool? = nil, allocatedDiscounts: Double? = nil, category1: String? = nil, category2: String? = nil, imageURLs: [String]? = nil, brandName: String? = nil, shippingOrigin: QuoteShippingOrigin? = nil) {
        self.lineItemID = lineItemID
        self.productID = productID
        self.variantID = variantID
        self.productTitle = productTitle
        self.variantTitle = variantTitle
        self.price = price
        self.quantity = quantity
        self.currency = currency
        self.salesTax = salesTax
        self.requiresShipping = requiresShipping
        self.finalPrice = finalPrice
        self.isFinalSale = isFinalSale
        self.allocatedDiscounts = allocatedDiscounts
        self.category1 = category1
        self.category2 = category2
        self.imageURLs = imageURLs
        self.brandName = brandName
        self.shippingOrigin = shippingOrigin
    }

    enum CodingKeys: String, CodingKey {
        case lineItemID = "line_item_id"
        case productID = "product_id"
        case variantID = "variant_id"
        case productTitle = "product_title"
        case variantTitle = "variant_title"
        case price, quantity, currency
        case salesTax = "sales_tax"
        case requiresShipping = "requires_shipping"
        case finalPrice = "final_price"
        case isFinalSale = "is_final_sale"
        case allocatedDiscounts = "allocated_discounts"
        case category1 = "category_1"
        case category2 = "category_2"
        case imageURLs = "image_urls"
        case brandName = "brand_name"
        case shippingOrigin = "shipping_origin"
    }
}

public struct QuoteShippingOrigin: Codable {
    public var country: String?
    
    public init(country: String? = nil) {
        self.country = country
    }
}

public struct QuoteShippingAddress: Codable {
    public var address1: String?
    public var city: String?
    public var state: String?
    public var zipcode: String?
    public var country: String?
    
    public init(address1: String? = nil, city: String? = nil, state: String? = nil, zipcode: String? = nil, country: String? = nil) {
        self.address1 = address1
        self.city = city
        self.state = state
        self.zipcode = zipcode
        self.country = country
    }

    enum CodingKeys: String, CodingKey {
        case address1 = "address_1"
        case city, state, zipcode, country
    }
}

public struct QuoteCustomer: Codable {
    public var customerID: String?
    public var firstName: String?
    public var lastName: String?
    public var email: String?
    public var phone: String?
    
    public init(customerID: String? = nil, firstName: String? = nil, lastName: String? = nil, email: String? = nil, phone: String? = nil) {
        self.customerID = customerID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
    }

    enum CodingKeys: String, CodingKey {
        case customerID = "customer_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email, phone
    }
}

public struct QuoteExtraInfo: Codable {
    public var shippingFee: Double?
    
    public init(shippingFee: Double? = nil) {
        self.shippingFee = shippingFee
    }

    enum CodingKeys: String, CodingKey {
        case shippingFee = "shipping_fee"
    }
}
