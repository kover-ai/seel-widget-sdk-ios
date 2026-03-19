import Foundation

public struct QuotesRequest: Codable, Sendable {
    /// The ID of a cart
    public var cartID: String?
    
    /// The unique identifier for the merchant within Seel's system
    public var merchantID: String?
    
    /// [Required] The ID of the shopping session
    public var sessionID: String?
    
    /// [Required] The type of device from which user activity originated
    /// desktop, mobile or tablet
    public var deviceCategory: String?
    
    /// [Required] The method by which users accessed your website or application
    /// Web, iOS or Android
    public var devicePlatform: String?
    
    /// The ID of the client device
    public var deviceID: String?
    
    /// The IP address of the client
    public var clientIp: String?
    
    /// [Required] The type of the quote, e.g. "seel-wfp"
    public var type: String?
    
    /// [Required] The default opt-in setting for the quote
    public var isDefaultOn: Bool?
    
    /// [Required] The list of items included in the quote
    public var lineItems: [QuoteLineItem]?
    
    /// [Required] Shipping address information
    public var shippingAddress: QuoteShippingAddress?
    
    /// [Required] Customer information
    public var customer: QuoteCustomer?
    
    /// Additional information for the quote (open structure, accepts any key-value pairs)
    public var extraInfo: [String: AnyCodable]?
    
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
        extraInfo: [String: AnyCodable]? = nil
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
        case clientIp = "client_ip"
        case isDefaultOn = "is_default_on"
        case lineItems = "line_items"
        case shippingAddress = "shipping_address"
        case customer
        case extraInfo = "extra_info"
    }
}

public struct QuoteLineItem: Codable, Sendable {
    /// [Required] The ID of the item
    public var lineItemID: String?
    /// [Required] The ID of the product
    public var productID: String?
    /// The ID of the product variant
    public var variantID: String?
    /// [Required] The title of the product
    public var productTitle: String?
    /// The description of the product
    public var productDescription: String?
    /// The title of the product variant
    public var variantTitle: String?
    /// The sku of the product variant
    public var sku: String?
    /// The ID of the seller
    public var sellerID: String?
    /// The name of the seller
    public var sellerName: String?
    /// The brand name of the product
    public var brandName: String?
    /// [Required] The quantity of the product
    public var quantity: Int?
    /// [Required] The price of the product
    public var price: Double?
    /// [Required] The allocated discounts of the product
    public var allocatedDiscounts: Double?
    /// [Required] The sales tax of the product
    public var salesTax: Double?
    /// The retail price of the product
    public var retailPrice: Double?
    /// [Required] The final price of the product
    public var finalPrice: Double?
    /// [Required] The currency of the price (ISO 4217), e.g. "USD"
    public var currency: String?
    /// [Required] Whether the item requires shipping or not
    public var requiresShipping: Bool?
    /// The URL of the product
    public var productURL: String?
    /// The URLs of the product images
    public var imageURLs: [String]?
    /// [Required] The main category of the product
    public var category1: String?
    /// [Required] The sub category of the product
    public var category2: String?
    /// The sub category 3 of the product
    public var category3: String?
    /// The sub category 4 of the product
    public var category4: String?
    /// [Required] Whether the item is final sale or not
    public var isFinalSale: Bool?
    /// [Required] The physical condition of the item: "new", "used", or "refurbished"
    public var condition: String?
    /// Product attributes (e.g. color, size)
    public var productAttributes: QuoteProductAttributes?
    /// Shipping origin information
    public var shippingOrigin: QuoteShippingOrigin?
    /// Extra information about the item (open structure, accepts any key-value pairs)
    public var extraInfo: [String: AnyCodable]?
    
    public init(
        lineItemID: String? = nil,
        productID: String? = nil,
        variantID: String? = nil,
        productTitle: String? = nil,
        productDescription: String? = nil,
        variantTitle: String? = nil,
        sku: String? = nil,
        sellerID: String? = nil,
        sellerName: String? = nil,
        brandName: String? = nil,
        quantity: Int? = nil,
        price: Double? = nil,
        allocatedDiscounts: Double? = nil,
        salesTax: Double? = nil,
        retailPrice: Double? = nil,
        finalPrice: Double? = nil,
        currency: String? = nil,
        requiresShipping: Bool? = nil,
        productURL: String? = nil,
        imageURLs: [String]? = nil,
        category1: String? = nil,
        category2: String? = nil,
        category3: String? = nil,
        category4: String? = nil,
        isFinalSale: Bool? = nil,
        condition: String? = nil,
        productAttributes: QuoteProductAttributes? = nil,
        shippingOrigin: QuoteShippingOrigin? = nil,
        extraInfo: [String: AnyCodable]? = nil
    ) {
        self.lineItemID = lineItemID
        self.productID = productID
        self.variantID = variantID
        self.productTitle = productTitle
        self.productDescription = productDescription
        self.variantTitle = variantTitle
        self.sku = sku
        self.sellerID = sellerID
        self.sellerName = sellerName
        self.brandName = brandName
        self.quantity = quantity
        self.price = price
        self.allocatedDiscounts = allocatedDiscounts
        self.salesTax = salesTax
        self.retailPrice = retailPrice
        self.finalPrice = finalPrice
        self.currency = currency
        self.requiresShipping = requiresShipping
        self.productURL = productURL
        self.imageURLs = imageURLs
        self.category1 = category1
        self.category2 = category2
        self.category3 = category3
        self.category4 = category4
        self.isFinalSale = isFinalSale
        self.condition = condition
        self.productAttributes = productAttributes
        self.shippingOrigin = shippingOrigin
        self.extraInfo = extraInfo
    }

    enum CodingKeys: String, CodingKey {
        case lineItemID = "line_item_id"
        case productID = "product_id"
        case variantID = "variant_id"
        case productTitle = "product_title"
        case productDescription = "product_description"
        case variantTitle = "variant_title"
        case sku
        case sellerID = "seller_id"
        case sellerName = "seller_name"
        case brandName = "brand_name"
        case quantity, price
        case allocatedDiscounts = "allocated_discounts"
        case salesTax = "sales_tax"
        case retailPrice = "retail_price"
        case finalPrice = "final_price"
        case currency
        case requiresShipping = "requires_shipping"
        case productURL = "product_url"
        case imageURLs = "image_urls"
        case category1 = "category_1"
        case category2 = "category_2"
        case category3 = "category_3"
        case category4 = "category_4"
        case isFinalSale = "is_final_sale"
        case condition
        case productAttributes = "product_attributes"
        case shippingOrigin = "shipping_origin"
        case extraInfo = "extra_info"
    }
}

public struct QuoteProductAttributes: Codable, Sendable {
    /// The color of the product
    public var color: String?
    /// The size of the product
    public var size: String?
    
    public init(color: String? = nil, size: String? = nil) {
        self.color = color
        self.size = size
    }
}

public struct QuoteShippingOrigin: Codable, Sendable {
    /// [Required] ISO 3166-1 alpha-2 country code
    public var country: String?
    public var address1: String?
    public var address2: String?
    public var city: String?
    public var state: String?
    public var zipcode: String?
    
    public init(
        country: String? = nil,
        address1: String? = nil,
        address2: String? = nil,
        city: String? = nil,
        state: String? = nil,
        zipcode: String? = nil
    ) {
        self.country = country
        self.address1 = address1
        self.address2 = address2
        self.city = city
        self.state = state
        self.zipcode = zipcode
    }
    
    enum CodingKeys: String, CodingKey {
        case country
        case address1 = "address_1"
        case address2 = "address_2"
        case city, state, zipcode
    }
}

public struct QuoteShippingAddress: Codable, Sendable {
    /// [Required] The first line of the shipping address
    public var address1: String?
    /// The second line of the shipping address
    public var address2: String?
    /// [Required] The city of the shipping address
    public var city: String?
    /// [Required] The state or province code of the shipping address
    public var state: String?
    /// [Required] The zipcode of the shipping address
    public var zipcode: String?
    /// [Required] ISO 3166-1 alpha-2 country code
    public var country: String?
    
    public init(
        address1: String? = nil,
        address2: String? = nil,
        city: String? = nil,
        state: String? = nil,
        zipcode: String? = nil,
        country: String? = nil
    ) {
        self.address1 = address1
        self.address2 = address2
        self.city = city
        self.state = state
        self.zipcode = zipcode
        self.country = country
    }

    enum CodingKeys: String, CodingKey {
        case address1 = "address_1"
        case address2 = "address_2"
        case city, state, zipcode, country
    }
}

public struct QuoteCustomer: Codable, Sendable {
    /// [Required] The unique identifier for the customer
    public var customerID: String?
    /// The first name of the customer
    public var firstName: String?
    /// The last name of the customer
    public var lastName: String?
    /// [Required] The email address of the customer
    public var email: String?
    /// The phone number of the customer
    public var phone: String?
    /// Extra information about the customer (open structure, accepts any key-value pairs)
    public var extraInfo: [String: AnyCodable]?
    
    public init(
        customerID: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        extraInfo: [String: AnyCodable]? = nil
    ) {
        self.customerID = customerID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.extraInfo = extraInfo
    }

    enum CodingKeys: String, CodingKey {
        case customerID = "customer_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email, phone
        case extraInfo = "extra_info"
    }
}
