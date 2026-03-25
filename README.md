# SeelWidget SDK

## Requirements

- iOS 12.0+
- Xcode 12.0+
- Swift 5.0+
- CocoaPods 1.10.0+

## Installation

### Swift Package Manager (Recommended)

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/kover-ai/seel-widget-sdk-ios.git`
3. Select the version you want to use
4. Click **Add Package**

Alternatively, you can add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/kover-ai/seel-widget-sdk-ios.git", exact: "0.1.16")
]
```

### CocoaPods

Add the following line to your `Podfile`:

```ruby
pod 'SeelWidget', '0.1.16'
```

Then run:

```bash
pod install
```

> **Note**: After running `pod install`, open the `.xcworkspace` file (not `.xcodeproj`) to build your project.

### Manual Installation

1. Download the SeelWidget SDK
2. Drag the `SeelWidget` folder into your project
3. Make sure to add SnapKit dependency

## Quick Start

### 1. Configure SDK

Configure the SDK in your `AppDelegate` or at app launch:

```swift
import SeelWidget

// In AppDelegate's application:didFinishLaunchingWithOptions:
SeelWidgetSDK.shared.configure(
    apiKey: "your_api_key_here",
    environment: .production // or .development
)
```

### 2. Create Quote Component

```swift
import UIKit
import SeelWidget

class ViewController: UIViewController {
    
    private lazy var wfpView = SeelWFPView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWFPView()
    }
    
    private func setupWFPView() {
        view.addSubview(wfpView)
        
        // Set constraints
        wfpView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(100)
        }
        
        // Set callback (toggle state)
        wfpView.optedIn = { [weak self] optedIn, quote in
            print("Toggle state: \(optedIn)")
            if let quote = quote {
                print("Quote info: \(quote)")
            }
        }
    }
}
```

### 3. Set/Update Quote Information

```swift
// Create quote information request
let quotesRequest = QuotesRequest(
    sessionID: "your_session_id",
    deviceCategory: "mobile",
    devicePlatform: "iOS",
    type: "seel-wfp",
    isDefaultOn: true,
    lineItems: [
        QuoteLineItem(
            lineItemID: "item_1",
            productID: "product_123",
            productTitle: "iPhone 15 Pro",
            quantity: 1,
            price: 999.0,
            allocatedDiscounts: 0.0,
            salesTax: 0.0,
            finalPrice: 999.0,
            currency: "USD",
            requiresShipping: true,
            category1: "Electronics",
            category2: "Smartphones",
            isFinalSale: false,
            condition: "new",
            variantID: "variant_456",
            variantTitle: "256GB Space Black",
            imageURLs: ["https://example.com/iphone.jpg"],
            shippingOrigin: QuoteShippingOrigin(country: "US")
        )
    ],
    shippingAddress: QuoteShippingAddress(
        address1: "123 Main St",
        city: "San Francisco",
        state: "CA",
        zipcode: "94102",
        country: "US"
    ),
    customer: QuoteCustomer(
        customerID: "customer_123",
        email: "john@example.com",
        firstName: "John",
        lastName: "Doe",
        phone: "+1234567890"
    ),
    cartID: "your_cart_id",
    merchantID: "your_merchant_id",
    deviceID: "your_device_id",
    extraInfo: ["shipping_fee": AnyCodable(10.0)]
)

// Initial setup of quote component
wfpView.setup(quotesRequest) { result in
    switch result {
    case .success(let response):
        print("Setup successful: \(response)")
    case .failure(let error):
        print("Setup failed: \(error)")
    }
}

// Update component when cart info changes
wfpView.updateWidgetWhenChanged(quotesRequest) { result in
    switch result {
    case .success(let response):
        print("Update successful: \(response)")
    case .failure(let error):
        print("Update failed: \(error)")
    }
}
```

## Detailed Usage Guide

### SDK Configuration

#### Environment Setup

```swift
// Development environment
SeelWidgetSDK.shared.configure(
    apiKey: "dev_api_key",
    environment: .development
)

// Production environment
SeelWidgetSDK.shared.configure(
    apiKey: "prod_api_key",
    environment: .production
)
```

#### Check Configuration Status

```swift
if SeelWidgetSDK.shared.isConfigured {
    print("SDK is configured")
    print("API Key: \(SeelWidgetSDK.shared.apiKey ?? "Not set")")
    print("Environment: \(SeelWidgetSDK.shared.environment)")
}
```

### SeelWFPView Component

#### Callback and Behavior

```swift
// User toggle callback
wfpView.optedIn = { optedIn, quote in
    if optedIn {
        print("User turned quote on, price: \(quote?.price ?? 0)")
    } else {
        print("User turned quote off")
    }
}
```

### SeelPDPBannerView Component

The `SeelPDPBannerView` displays a lightweight banner on the Product Detail Page (e.g. "Worry-Free Purchase® available with seel").

#### Basic Usage

```swift
import SeelWidget

let pdpBanner = SeelPDPBannerView(frame: .zero)
view.addSubview(pdpBanner)

// Configure with brand type
pdpBanner.setup(type: "ebth-wfp")
```

#### Custom Style

Use `PDPBannerStyle` to customize appearance:

```swift
pdpBanner.setup(type: "ebth-wfp", style: PDPBannerStyle(
    backgroundColor: .white,
    padding: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12),
    cornerRadius: 6,
    borderColor: UIColor(hex: "#E0E0E0"),
    borderWidth: 1
))
```

#### PDPBannerStyle Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `backgroundColor` | `UIColor` | `.white` | Background color |
| `padding` | `UIEdgeInsets` | `.zero` | Inner padding |
| `cornerRadius` | `CGFloat` | `0` | Corner radius |
| `borderColor` | `UIColor?` | `nil` | Border color |
| `borderWidth` | `CGFloat` | `0` | Border width |

### Event Tracking

#### Send Events

```swift
let eventRequest = EventsRequest(
    // Event parameters
)

SeelWidgetSDK.shared.createEvents(eventRequest) { result in
    switch result {
    case .success(let response):
        print("Event sent successfully: \(response)")
    case .failure(let error):
        print("Event sending failed: \(error)")
    }
}
```

## API Reference

### SeelWidgetSDK

#### Methods

```swift
// Configure SDK
func configure(apiKey: String, environment: SeelEnvironment = .production)

// Send events
func createEvents(_ event: EventsRequest, completion: @escaping (Result<EventsResponse, NetworkError>) -> Void)
```

#### Properties

```swift
// Singleton instance
static let shared: SeelWidgetSDK

// API Key
var apiKey: String?

// Current environment
var environment: SeelEnvironment

// Whether configured
var isConfigured: Bool
```

### SeelWFPView

#### Methods

```swift
// Set quote information
func setup(_ request: QuotesRequest, completion: @escaping (Result<QuotesResponse, NetworkError>) -> Void)

// Update component when quote information changes
func updateWidgetWhenChanged(_ request: QuotesRequest, completion: @escaping (Result<QuotesResponse, NetworkError>) -> Void)
```

#### Properties

```swift
// User choice callback
var optedIn: WFPOptedIn?
```

#### Style Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `backgroundColor` | `UIColor` | `.white` | The view's background color (inherited from UIView) |
| `normalBackgroundColor` | `UIColor` | Falls back to `backgroundColor` | Background color for normal (unchecked) state |
| `selectedBackgroundColor` | `UIColor` | Falls back to `backgroundColor` | Background color for selected (checked) state |
| `disabledBackgroundColor` | `UIColor` | `#F0EFEF` | Background color for disabled (rejected) state |
| `cornerRadius` | `CGFloat` | `0` | Corner radius for the widget |
| `showDisclaimer` | `Bool` | Per brand default | Whether to show the disclaimer text. Defaults to `false` for EBTH, `true` for others |

```swift
// Example: customize widget appearance
wfpView.backgroundColor = UIColor(hex: "#F5F5F5")
wfpView.normalBackgroundColor = UIColor(hex: "#FFFFFF")
wfpView.selectedBackgroundColor = UIColor(hex: "#E8F5E9")
wfpView.disabledBackgroundColor = UIColor(hex: "#F0EFEF")
wfpView.cornerRadius = 8
wfpView.showDisclaimer = false
```

### SeelPDPBannerView

#### Methods

```swift
// Configure the banner with brand type and optional style
func setup(type: String?, style: PDPBannerStyle = PDPBannerStyle())
```

### Request Field Reference

#### QuotesRequest

- **type** (String, required): Quote type, e.g., `seel-wfp`.
- **cart_id** (String, optional): Cart ID.
- **merchant_id** (String, optional): Merchant identifier in Seel system.
- **session_id** (String, required): Session ID.
- **device_category** (String, required): Device category: `desktop`/`mobile`/`tablet`.
- **device_platform** (String, required): Access method: `Web`/`iOS`/`Android`.
- **device_id** (String, optional): Client device ID.
- **client_ip** (String, optional): Client IP address.
- **is_default_on** (Bool, required): Whether the component is default ON.
- **line_items** ([QuoteLineItem], required): Items to be quoted.
- **shipping_address** (QuoteShippingAddress, required): Shipping address info.
- **customer** (QuoteCustomer, required): Customer info.
- **extra_info** (QuoteExtraInfo, optional): Extra info.

##### QuoteLineItem
- **line_item_id** (String, required): The ID of the item.
- **product_id** (String, required): The ID of the product.
- **product_title** (String, required): The title of the product.
- **quantity** (Int, required): The quantity of the product.
- **price** (Double, required): The price of the product.
- **allocated_discounts** (Double, required): The allocated discounts.
- **sales_tax** (Double, required): The sales tax.
- **final_price** (Double, required): The final price.
- **currency** (String, required): ISO 4217 currency code, e.g. `USD`.
- **requires_shipping** (Bool, required): Whether the item requires shipping.
- **category_1** (String, required): The main category.
- **category_2** (String, required): The sub category.
- **is_final_sale** (Bool, required): Whether the item is final sale.
- **condition** (String, required): Physical condition: `new`, `used`, or `refurbished`.
- **variant_id** (String, optional)
- **variant_title** (String, optional)
- **product_description** (String, optional)
- **sku** (String, optional)
- **seller_id** (String, optional)
- **seller_name** (String, optional)
- **brand_name** (String, optional)
- **retail_price** (Double, optional)
- **product_url** (String, optional)
- **image_urls** ([String], optional)
- **category_3** (String, optional)
- **category_4** (String, optional)
- **product_attributes** (QuoteProductAttributes, optional)
- **shipping_origin** (QuoteShippingOrigin, optional)
- **extra_info** ([String: AnyCodable], optional): Open structure for additional item data.

##### QuoteShippingOrigin
- **country** (String, required): ISO 3166-1 alpha-2 country code.
- **address_1** (String, optional)
- **address_2** (String, optional)
- **city** (String, optional)
- **state** (String, optional)
- **zipcode** (String, optional)

##### QuoteShippingAddress
- **address_1** (String, required): The first line of the address.
- **city** (String, required): The city.
- **state** (String, required): The state or province code.
- **zipcode** (String, required): The zipcode.
- **country** (String, required): ISO 3166-1 alpha-2 country code.
- **address_2** (String, optional)

##### QuoteCustomer
- **customer_id** (String, required): The unique identifier for the customer.
- **email** (String, required): The email address.
- **first_name** (String, optional)
- **last_name** (String, optional)
- **phone** (String, optional)
- **extra_info** ([String: AnyCodable], optional): Open structure for additional customer data.

##### extra_info (Quote-level)

The top-level `extra_info` is an open `[String: AnyCodable]` dictionary. You can pass any key-value pairs:

```swift
extraInfo: [
    "shipping_fee": AnyCodable(10.0),
    "shipping_method": AnyCodable("standard")
]
```

#### EventsRequest

- **session_id** (String, required): Session ID.
- **event_ts** (String, optional): Event timestamp in milliseconds.
- **customer_id** (String, required): Customer ID.
- **device_id** (String, optional): Device ID.
- **client_ip** (String, optional): Client IP address.
- **event_source** (String, required): Event source.
- **event_type** (String, required): Event type, e.g., `product_viewed`.
- **event_info** (EventInfo, optional): Event information object (schema varies by event_type).
- **shipping_address_zipcode** (String, optional)

---

> **Important**: All required fields in `QuotesRequest` (e.g. `sessionID`, `lineItems`, `shippingAddress`, `customer`) are non-optional. If the data used to construct `QuotesRequest` comes from a network API, make sure to validate the data and handle errors properly (e.g. using `do-catch`) before constructing the request object. Missing required fields will cause a decoding error or a compile-time error, depending on how the object is constructed.

**Note**: Please ensure you use the correct API Key and environment settings in production.
