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
    .package(url: "https://github.com/kover-ai/seel-widget-sdk-ios.git", from: "0.1.4")
]
```

### CocoaPods

Add the following line to your `Podfile`:

```ruby
pod 'SeelWidget'
```

Then run:

```bash
pod install
```

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
    type: "seel-wfp",
    cartID: "your_cart_id",
    sessionID: "your_session_id",
    merchantID: "your_merchant_id",
    deviceID: "your_device_id",
    deviceCategory: "mobile",
    devicePlatform: "ios",
    isDefaultOn: true,
    lineItems: [
        QuotesRequest.LineItem(
            lineItemID: "item_1",
            productID: "product_123",
            variantID: "variant_456",
            productTitle: "iPhone 15 Pro",
            variantTitle: "256GB Space Black",
            price: 999.0,
            quantity: 1,
            currency: "USD",
            salesTax: 0.0,
            requiresShipping: true,
            finalPrice: "999.00",
            isFinalSale: false,
            allocatedDiscounts: 0.0,
            category1: "Electronics",
            category2: "Smartphones",
            imageURLs: ["https://example.com/iphone.jpg"],
            shippingOrigin: QuotesRequest.ShippingOrigin(country: "US")
        )
    ],
    shippingAddress: QuotesRequest.ShippingAddress(
        address1: "123 Main St",
        city: "San Francisco",
        state: "CA",
        zipcode: "94102",
        country: "US"
    ),
    customer: QuotesRequest.Customer(
        customerID: "customer_123",
        firstName: "John",
        lastName: "Doe",
        email: "john@example.com",
        phone: "+1234567890"
    ),
    extraInfo: QuotesRequest.ExtraInfo(shippingFee: 10.0)
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

```

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
- **line_item_id** (String, optional)
- **product_id** (String, optional)
- **variant_id** (String, optional)
- **product_title** (String, optional)
- **variant_title** (String, optional)
- **price** (Double, optional)
- **quantity** (Int, optional)
- **currency** (String, optional)
- **sales_tax** (Double, optional)
- **requires_shipping** (Bool, optional)
- **final_price** (String, optional)
- **is_final_sale** (Bool, optional)
- **allocated_discounts** (Double, optional)
- **category_1** (String, optional)
- **category_2** (String, optional)
- **image_urls** ([String], optional)
- **shipping_origin** (QuoteShippingOrigin, optional)

##### QuoteShippingOrigin
- **country** (String, optional)

##### QuoteShippingAddress
- **address_1** (String, optional)
- **city** (String, optional)
- **state** (String, optional)
- **zipcode** (String, optional)
- **country** (String, optional)

##### QuoteCustomer
- **customer_id** (String, required)
- **first_name** (String, optional)
- **last_name** (String, optional)
- **email** (String, required)
- **phone** (String, optional)

##### QuoteExtraInfo
- **shipping_fee** (Double, optional)

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

**Note**: Please ensure you use the correct API Key and environment settings in production.
