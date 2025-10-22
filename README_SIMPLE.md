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

## 更新日志

### v0.1.0
- 初始版本发布
- 基本报价组件功能
- 支持埋点事件

**注意**: 请确保在生产环境中使用正确的 API Key 和环境设置。
