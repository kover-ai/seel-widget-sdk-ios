# SeelWidget SDK

[![CI Status](https://img.shields.io/travis/seel/SeelWidget.svg?style=flat)](https://travis-ci.org/seel/SeelWidget)
[![Version](https://img.shields.io/cocoapods/v/SeelWidget.svg?style=flat)](https://cocoapods.org/pods/SeelWidget)
[![License](https://img.shields.io/cocoapods/l/SeelWidget.svg?style=flat)](https://cocoapods.org/pods/SeelWidget)
[![Platform](https://img.shields.io/cocoapods/p/SeelWidget.svg?style=flat)](https://cocoapods.org/pods/SeelWidget)

SeelWidget 是一个为 iOS 应用提供保修和保险服务的 SDK，让您的应用能够轻松集成 Seel 的保修产品。

## 功能特性

- 🛡️ **保修服务集成** - 为商品提供保修和保险服务
- 📱 **原生 iOS 组件** - 完全原生的 iOS 用户界面
- 🎨 **可定制样式** - 支持自定义外观和主题
- 📊 **实时报价** - 基于商品信息实时计算保修价格
- 🔄 **事件追踪** - 完整的用户行为追踪和分析
- 📋 **详细信息展示** - 详细的保修条款和覆盖范围说明

## 系统要求

- iOS 12.0+
- Xcode 12.0+
- Swift 5.0+
- CocoaPods 1.10.0+

## 隐私信息

SeelWidget SDK 包含一个 `PrivacyInfo.xcprivacy` 文件，声明了 SDK 收集的隐私数据类型。此文件是 iOS 17+ 应用必需的，有助于 App Store 合规。

### 收集的数据类型

SDK 为保修服务功能收集以下数据类型：

- **姓名** - 用于保修注册的客户姓名
- **邮箱地址** - 客户联系信息
- **电话号码** - 客户联系信息
- **设备 ID** - 用于服务跟踪的设备标识
- **位置信息** - 用于保修覆盖范围的配送地址
- **购买历史** - 用于保修计算的商品信息
- **使用数据** - SDK 使用分析

所有数据收集都与用户身份关联，仅用于应用功能（保修服务提供）。SDK 不会跨应用或网站跟踪用户。

## 安装

### Swift Package Manager (推荐)

1. 在 Xcode 中，选择 **File** → **Add Package Dependencies**
2. 输入仓库 URL: `https://github.com/seel/SeelWidget.git`
3. 选择您要使用的版本
4. 点击 **Add Package**

或者，您可以直接在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/seel/SeelWidget.git", from: "0.1.0")
]
```

### CocoaPods

在您的 `Podfile` 中添加以下行：

```ruby
pod 'SeelWidget'
```

然后运行：

```bash
pod install
```

### 手动安装

1. 下载 SeelWidget SDK
2. 将 `SeelWidget` 文件夹拖拽到您的项目中
3. 确保添加了 SnapKit 依赖

## 快速开始

### 1. 配置 SDK

在您的 `AppDelegate` 或应用启动时配置 SDK：

```swift
import SeelWidget

// 在 AppDelegate 的 application:didFinishLaunchingWithOptions: 中
SeelWidgetSDK.shared.configure(
    apiKey: "your_api_key_here",
    environment: .production // 或 .development
)
```

### 2. 创建报价组件

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
        
        // 设置约束
        wfpView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(100)
        }
        
        // 设置回调（开启状态）
        wfpView.optedIn = { [weak self] optedIn, quote in
            print("开启状态: \(optedIn)")
            if let quote = quote {
                print("报价信息: \(quote)")
            }
        }
    }
}
```

### 3. 设置/更新报价信息

```swift
// 创建报价信息请求
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
            variantTitle: "256GB 深空黑色",
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

// 首次设置报价组件
wfpView.setup(quotesRequest) { result in
    switch result {
    case .success(let response):
        print("设置成功: \(response)")
    case .failure(let error):
        print("设置失败: \(error)")
    }
}

// 购物车信息发生变化时，更新组件
wfpView.updateWidgetWhenChanged(quotesRequest) { result in
    switch result {
    case .success(let response):
        print("更新成功: \(response)")
    case .failure(let error):
        print("更新失败: \(error)")
    }
}
```

## 详细使用指南

### SDK 配置

#### 环境设置

```swift
// 开发环境
SeelWidgetSDK.shared.configure(
    apiKey: "dev_api_key",
    environment: .development
)

// 生产环境
SeelWidgetSDK.shared.configure(
    apiKey: "prod_api_key",
    environment: .production
)
```

#### 检查配置状态

```swift
if SeelWidgetSDK.shared.isConfigured {
    print("SDK 已配置")
    print("API Key: \(SeelWidgetSDK.shared.apiKey ?? "未设置")")
    print("环境: \(SeelWidgetSDK.shared.environment)")
}
```

### SeelWFPView 组件

#### 回调与行为

```swift
// 用户选择回调
wfpView.optedIn = { optedIn, quote in
    if optedIn {
        print("用户开启了报价，价格: \(quote?.price ?? 0)")
    } else {
        print("用户关闭了报价服务")
    }
}
```

```

### 事件追踪

#### 发送事件

```swift
let eventRequest = EventsRequest(
    // 事件参数
)

SeelWidgetSDK.shared.createEvents(eventRequest) { result in
    switch result {
    case .success(let response):
        print("事件发送成功: \(response)")
    case .failure(let error):
        print("事件发送失败: \(error)")
    }
}
```

## API 参考

### SeelWidgetSDK

#### 方法

```swift
// 配置 SDK
func configure(apiKey: String, environment: SeelEnvironment = .production)

// 发送事件
func createEvents(_ event: EventsRequest, completion: @escaping (Result<EventsResponse, NetworkError>) -> Void)
```

#### 属性

```swift
// 单例实例
static let shared: SeelWidgetSDK

// API Key
var apiKey: String?

// 当前环境
var environment: SeelEnvironment

// 是否已配置
var isConfigured: Bool
```

### SeelWFPView

#### 方法

```swift
// 设置报价信息
func setup(_ request: QuotesRequest, completion: @escaping (Result<QuotesResponse, NetworkError>) -> Void)

// 报价信息变化时更新组件
func updateWidgetWhenChanged(_ request: QuotesRequest, completion: @escaping (Result<QuotesResponse, NetworkError>) -> Void)
```

#### 属性

```swift
// 用户选择回调
var optedIn: WFPOptedIn?
```

### 请求字段说明

#### QuotesRequest

- **type** (String, 必填): 报价类型，例如 `seel-wfp`。
- **cart_id** (String, 可选): 购物车 ID。
- **merchant_id** (String, 可选): 商户在 Seel 系统中的唯一标识。
- **session_id** (String, 必填): 会话 ID。
- **device_category** (String, 必填): 设备类别，`desktop`/`mobile`/`tablet`。
- **device_platform** (String, 必填): 访问方式，`Web`/`iOS`/`Android`。
- **device_id** (String, 可选): 客户端设备 ID。
- **client_ip** (String, 可选): 客户端 IP 地址。
- **is_default_on** (Bool, 必填): 组件默认开关是否打开。
- **line_items** ([QuoteLineItem], 必填): 报价包含的条目列表。
- **shipping_address** (QuoteShippingAddress, 必填): 配送地址信息。
- **customer** (QuoteCustomer, 必填): 客户信息。
- **extra_info** (QuoteExtraInfo, 可选): 额外信息。

##### QuoteLineItem
- **line_item_id** (String, 可选)
- **product_id** (String, 可选)
- **variant_id** (String, 可选)
- **product_title** (String, 可选)
- **variant_title** (String, 可选)
- **price** (Double, 可选)
- **quantity** (Int, 可选)
- **currency** (String, 可选)
- **sales_tax** (Double, 可选)
- **requires_shipping** (Bool, 可选)
- **final_price** (String, 可选)
- **is_final_sale** (Bool, 可选)
- **allocated_discounts** (Double, 可选)
- **category_1** (String, 可选)
- **category_2** (String, 可选)
- **image_urls** ([String], 可选)
- **shipping_origin** (QuoteShippingOrigin, 可选)

##### QuoteShippingOrigin
- **country** (String, 可选)

##### QuoteShippingAddress
- **address_1** (String, 可选)
- **city** (String, 可选)
- **state** (String, 可选)
- **zipcode** (String, 可选)
- **country** (String, 可选)

##### QuoteCustomer
- **customer_id** (String, 必填)
- **first_name** (String, 可选)
- **last_name** (String, 可选)
- **email** (String, 必填)
- **phone** (String, 可选)

##### QuoteExtraInfo
- **shipping_fee** (Double, 可选)

#### EventsRequest

- **session_id** (String, 必填): 会话 ID。
- **event_ts** (String, 可选): 事件时间戳（毫秒）。
- **customer_id** (String, 必填): 客户 ID。
- **device_id** (String, 可选): 设备 ID。
- **client_ip** (String, 可选): 客户端 IP 地址。
- **event_source** (String, 必填): 事件来源。
- **event_type** (String, 必填): 事件类型，例如 `product_page_enter`、`cart_add`、`checkout_complete` 等。
- **event_info** (EventInfo, 可选): 事件信息对象（不同类型字段不同）。

##### EventInfo
- **user_email** (String, 可选)
- **user_phone_number** (String, 可选)
- **shipping_address** (EventShippingAddress, 可选)

##### EventShippingAddress
- **shipping_address_country** (String, 可选)
- **shipping_address_state** (String, 可选)
- **shipping_address_city** (String, 可选)
- **shipping_address_zipcode** (String, 可选)

## 示例项目

运行示例项目：

1. 克隆仓库
2. 进入 Example 目录
3. 运行 `pod install`
4. 打开 `SeelWidget.xcworkspace`
5. 运行项目

示例项目展示了：
- SDK 基本配置
- 保修组件集成
- 事件追踪
- 回调处理

## 故障排除

### 常见问题

#### 1. 网络请求失败

```swift
// 检查网络连接
// 确认 API Key 正确
// 检查环境设置
```

#### 2. 组件不显示

```swift
// 确认已添加到视图层次
// 检查约束设置
// 确认数据已正确设置
```

#### 3. 回调不触发

```swift
// 确认回调已正确设置
// 检查数据格式是否正确
```

### 调试模式

在开发环境中启用详细日志：

```swift
// 在开发环境中，SDK 会输出详细的调试信息
SeelWidgetSDK.shared.configure(
    apiKey: "your_dev_key",
    environment: .development
)
```

## 更新日志

### v0.1.0
- 初始版本发布
- 基本报价组件功能
- 支持埋点事件

## 许可证

SeelWidget 使用 MIT 许可证。详情请查看 [LICENSE](LICENSE) 文件。

## 支持

如有问题或建议，请联系：

- 邮箱: seel@seel.com
- GitHub Issues: [提交问题](https://github.com/seel/SeelWidget/issues)

## 贡献

欢迎提交 Pull Request 和 Issue！

---

**注意**: 请确保在生产环境中使用正确的 API Key 和环境设置。
