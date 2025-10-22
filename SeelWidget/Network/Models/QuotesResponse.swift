import Foundation

public enum QuoteStatus: String, Codable {
    case accepted = "accepted"
    case rejected = "rejected"
}

public struct QuotesResponse: Codable {
    public let quoteID: String?
    public let cartID: String?
    public let merchantID: String?
    public let sessionID: String?
    public let deviceID: String?
    public let deviceCategory: String?
    public let devicePlatform: String?
    public let clientIP: String?
    public let type: String?
    public let price: Double?
    public let salesTax: Double?
    public let currency: String?
    public let status: QuoteStatus?
    public let isDefaultOn: Bool?
    public let createdTS: String?
    public let lineItems: [LineItem]?
    public let eligibleItems: [EligibleItem]?
    public let shippingAddress: ShippingAddress?
    public let customer: Customer?
    public let extraInfo: ExtraInfo?

    enum CodingKeys: String, CodingKey {
        case quoteID = "quote_id"
        case cartID = "cart_id"
        case merchantID = "merchant_id"
        case sessionID = "session_id"
        case deviceID = "device_id"
        case deviceCategory = "device_category"
        case devicePlatform = "device_platform"
        case clientIP = "client_ip"
        case type, price
        case salesTax = "sales_tax"
        case currency, status
        case isDefaultOn = "is_default_on"
        case createdTS = "created_ts"
        case lineItems = "line_items"
        case eligibleItems = "eligible_items"
        case shippingAddress = "shipping_address"
        case customer
        case extraInfo = "extra_info"
    }
    
    public struct LineItem: Codable {
        public let lineItemID: String?
        public let productID: String?
        public let productTitle: String?
        public let productAttributes: String?
        public let productDescription: String?
        public let variantID: String?
        public let variantTitle: String?
        public let sku: String?
        public let sellerID: String?
        public let sellerName: String?
        public let brandName: String?
        public let quantity: Int?
        public let price: Double?
        public let allocatedDiscounts: Double?
        public let salesTax: Double?
        public let finalPrice: Double?
        public let retailPrice: Double?
        public let shippingFee: Double?
        public let currency: String?
        public let requiresShipping: Bool?
        public let imageURL: String?
        public let productURL: String?
        public let isFinalSale: Bool?
        public let shippingOrigin: ShippingOrigin?
        public let category1: String?
        public let category2: String?
        public let category3: String?
        public let category4: String?
        public let condition: String?
        public let extraInfo: String?

        enum CodingKeys: String, CodingKey {
            case lineItemID = "line_item_id"
            case productID = "product_id"
            case productTitle = "product_title"
            case productAttributes = "product_attributes"
            case productDescription = "product_description"
            case variantID = "variant_id"
            case variantTitle = "variant_title"
            case sku
            case sellerID = "seller_id"
            case sellerName = "seller_name"
            case brandName = "brand_name"
            case quantity, price
            case allocatedDiscounts = "allocated_discounts"
            case salesTax = "sales_tax"
            case finalPrice = "final_price"
            case retailPrice = "retail_price"
            case shippingFee = "shipping_fee"
            case currency
            case requiresShipping = "requires_shipping"
            case imageURL = "image_url"
            case productURL = "product_url"
            case isFinalSale = "is_final_sale"
            case shippingOrigin = "shipping_origin"
            case category1 = "category_1"
            case category2 = "category_2"
            case category3 = "category_3"
            case category4 = "category_4"
            case condition
            case extraInfo = "extra_info"
        }
    }

    public struct ShippingOrigin: Codable {
        public let address1: String?
        public let address2: String?
        public let city: String?
        public let state: String?
        public let zipcode: String?
        public let country: String?

        enum CodingKeys: String, CodingKey {
            case address1 = "address_1"
            case address2 = "address_2"
            case city, state, zipcode, country
        }
    }

    public struct EligibleItem: Codable {
        public let lineItemID: String?
        public let productID: String?
        public let variantID: String?
        public let coverages: [Coverage]?

        enum CodingKeys: String, CodingKey {
            case lineItemID = "line_item_id"
            case productID = "product_id"
            case variantID = "variant_id"
            case coverages
        }
    }

    public struct Coverage: Codable {
        public let coverageType: String?
        public let description: String?

        enum CodingKeys: String, CodingKey {
            case coverageType = "coverage_type"
            case description
        }
    }

    public struct ShippingAddress: Codable {
        public let address1: String?
        public let address2: String?
        public let city: String?
        public let state: String?
        public let zipcode: String?
        public let country: String?

        enum CodingKeys: String, CodingKey {
            case address1 = "address_1"
            case address2 = "address_2"
            case city, state, zipcode, country
        }
    }

    public struct Customer: Codable {
        public let customerID: String?
        public let firstName: String?
        public let lastName: String?
        public let email: String?
        public let phone: String?
        public let extraInfo: String?

        enum CodingKeys: String, CodingKey {
            case customerID = "customer_id"
            case firstName = "first_name"
            case lastName = "last_name"
            case email, phone
            case extraInfo = "extra_info"
        }
    }

    public struct ExtraInfo: Codable {
        public let shippingFee: Double?
        public let termsURL: String?
        public let privacyPolicyURL: String?
        public let displayWidgetText: [String]?
        public let coverageDetailsText: [String]?
        public let optOutWarningText: String?
        public let widgetTitle: String?

        enum CodingKeys: String, CodingKey {
            case shippingFee = "shipping_fee"
            case termsURL = "terms_url"
            case privacyPolicyURL = "privacy_policy_url"
            case displayWidgetText = "display_widget_text"
            case coverageDetailsText = "coverage_details_text"
            case optOutWarningText = "opt_out_warning_text"
            case widgetTitle = "widget_title"
        }
    }
    
}
