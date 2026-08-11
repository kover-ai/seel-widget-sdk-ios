# SeelWidget SDK 隐私说明

> [English](PRIVACY.md) | **简体中文**

本文档说明 SeelWidget SDK 采集与传输哪些数据，供接入方填写 App Store Connect 的 **App Privacy 问卷**时参照，同时作为 `SeelWidget/PrivacyInfo.xcprivacy` 的维护依据。

> **接入方请先读**：SDK 传输的数据必须体现在你们 App 的隐私标签中。Apple 要求 App 的隐私申报**涵盖第三方 SDK 采集的数据**，而你们无法从二进制里看出 SDK 采集了什么 —— 本文档就是为此提供的依据。

---

## 1. 一个前提：SDK 不主动采集任何设备信息

SDK 内部**没有**调用任何设备标识或传感器 API：

- 无 `identifierForVendor` / `advertisingIdentifier`
- 无 `UIDevice` 相关采集
- 无 `CoreLocation`

所有用户与设备标识（`customer_id` / `device_id` / `client_ip` 等）**由宿主 App 通过接口参数传入**，采集决定权在接入方手上。但这些数据经由 SDK 传输至 Seel 服务端，在 Apple 的口径中仍计入 SDK 的数据采集，因此必须申报。

---

## 2. 数据传输清单（按接口）

### 2.1 `POST /v1/ecommerce/quotes` —— 保险报价

由宿主调用 `SeelWFPView.setup(_:completion:)` 或 `updateWidgetWhenChanged(_:completion:)` 触发。

| 请求字段 | 内容 | Apple 数据类型 | 用途 |
|---|---|---|---|
| `customer.first_name` / `last_name` | 姓名 | Name | App Functionality |
| `customer.email` | 邮箱 | Email Address | App Functionality |
| `customer.phone` | 电话 | Phone Number | App Functionality |
| `customer.customer_id` | 顾客标识 | User ID | App Functionality |
| `shipping_address.*` | 收货地址（address1 / city / state / zipcode / country） | Physical Address | App Functionality |
| `device_id` | 设备标识 | Device ID | App Functionality |
| `client_ip` | IP 地址（可选，宿主传入） | **不申报**，见 §3.2 | 仅用于风控 / 欺诈防范 |
| `line_items[]` | 商品明细、价格、类目、数量 | Purchase History | App Functionality |
| `session_id` / `device_category` / `device_platform` | 会话与设备类别 | Product Interaction | App Functionality |
| `extra_info` | 开放结构，由宿主自定义 | **取决于宿主传入内容** | — |

> ⚠️ `extra_info` 是 `[String: AnyCodable]` 的自由结构。**宿主若在其中传入未在本表列出的个人数据，需自行申报。**

### 2.2 `POST /v1/ecommerce/user-configs/{user_id}` —— 退出投保

**由 SDK 自动发起**（用户取消勾选保险时），宿主无需调用、也无法阻止。当前仅对 `type == "ebth-wfp"` 的商户生效。

| 字段 | 内容 | Apple 数据类型 |
|---|---|---|
| URL 路径中的 `{user_id}` | 顾客标识（取自报价响应） | User ID |
| `merchant_id` | 商户标识 | 非个人数据 |
| `opted_out` | 退出标记 | — |

### 2.3 `POST /v1/ecommerce/events` —— 行为埋点

**SDK 从不主动调用。** 仅在宿主显式调用 `SeelWidgetSDK.shared.createEvents(_:completion:)` 时发送 —— 宿主不调用则一个事件都不会产生。

| 字段 | 内容 | Apple 数据类型 |
|---|---|---|
| `customer_id` | 顾客标识 | User ID |
| `device_id` | 设备标识 | Device ID |
| `client_ip` | IP 地址 | **不申报**，见 §3.2 |
| `event_type` | `product_page_enter` / `favorite_add` / `cart_add` / `checkout_begin` / `checkout_complete` 等 | Product Interaction |
| `event_info` | 开放结构，由宿主自定义 | **取决于宿主传入内容** |

---

## 3. 隐私清单声明与代码的对应关系

`SeelWidget/PrivacyInfo.xcprivacy` 当前声明的 8 项采集类型，与 §2 的对应关系：

| 声明值 | 来源字段 |
|---|---|
| `NSPrivacyCollectedDataTypeName` | `customer.first_name` / `last_name` |
| `NSPrivacyCollectedDataTypeEmailAddress` | `customer.email` |
| `NSPrivacyCollectedDataTypePhoneNumber` | `customer.phone` |
| `NSPrivacyCollectedDataTypePhysicalAddress` | `shipping_address.*` |
| `NSPrivacyCollectedDataTypeUserID` | `customer.customer_id` |
| `NSPrivacyCollectedDataTypeDeviceID` | `device_id` |
| `NSPrivacyCollectedDataTypePurchaseHistory` | `line_items[]` |
| `NSPrivacyCollectedDataTypeProductInteraction` | `event_type` / `session_id` |

全部标记为 `Linked: true`（与用户身份关联）、`Tracking: false`、用途 `App Functionality`。

### 3.1 `NSPrivacyTracking` 为何是 `false`

Apple 对 tracking 的定义有两个并列触发条件：把本 App 数据与**其他公司**的 App/网站/线下数据关联**用于定向广告或广告效果衡量**；或**共享给 data broker**。

Seel 采集的数据仅用于保险报价、风控与理赔，**不向广告平台或 data broker 提供任何数据**，两个触发条件均不成立。因此 `NSPrivacyTracking = false`、`NSPrivacyTrackingDomains` 为空数组。

> 🔴 **这两个字段不要修改。** `api.seel.com` 一旦被列入 `NSPrivacyTrackingDomains`，在用户拒绝 ATT 授权时会被系统**直接阻断**，SDK 的报价功能将对这部分用户完全失效。由于 SDK 的报价 API 与潜在的追踪域名是同一个域名，Seel 在业务上没有走 tracking 路线的空间 —— 若将来确有广告用途需求，前置条件是先把广告域名与 API 域名分离。

### 3.2 `client_ip` 为何不申报

`client_ip` 是可选字段，SDK 内部从不为其赋值，仅在宿主主动传入时随请求发送。服务端**仅将其用于风控与欺诈防范，不推导地理位置、不用于业务逻辑、不用于广告**。

Apple 的数据类型体系中没有「IP 地址」这一项；IP 只有在被用于**判定用户位置**时才需要申报为 Coarse Location。由于不存在位置推导环节，本 SDK 不申报任何位置类数据。

> 若后端将来对 IP 做地理位置推导并用于业务，须同步补充 `NSPrivacyCollectedDataTypeCoarseLocation`，并通知全部接入方更新其 App Privacy 问卷。

### 3.3 required-reason API 声明

| Category | Reason | 说明 |
|---|---|---|
| `UserDefaults` | `CA92.1` | 存储投保选择状态（`SeelWFPView`） |
| `SystemBootTime` | `35F9.1` | 保留声明 |
| `FileTimestamp` | `C617.1` | 保留声明 |
| `DiskSpace` | `85F4.1` | 保留声明 |

后三项当前无直接调用，但**刻意保留** —— Apple 只惩罚漏声明（`ITMS-91053`），不惩罚多声明；删除后一旦有间接调用即被拦截。

`NSPrivacyAccessedAPICategoryNetworkState` 曾被错误声明，该值不属于 Apple 的 5 个合法 category（`FileTimestamp` / `SystemBootTime` / `DiskSpace` / `ActiveKeyboards` / `UserDefaults`），已于 1.0.1 移除（触发过 `ITMS-91054`）。

---

## 4. 给接入方的操作指引

1. 对照 §2 的表格，确认你们 App 的 App Privacy 问卷已涵盖全部数据类型
2. 若你们传入了 `extra_info`，其中的字段需自行评估并申报
3. 若不希望 SDK 发送行为埋点，**不要调用 `createEvents`** —— SDK 不会自行发送
4. `postUserConfig`（退出投保）是 SDK 自动发起的，无法关闭；如有顾虑请联系 Seel

---

## 5. 维护规则

**改动以下路径时，必须回头检查本文档与 `PrivacyInfo.xcprivacy`：**

- `SeelWidget/Network/Models/**` —— 请求/响应模型字段变更
- `SeelWidget/Network/NetworkManager.swift` —— 新增或修改接口
- 任何新增的 `URLSession` 调用

**隐私清单是随代码演进的契约，不是一次性表单。** 字段变更未同步至清单，会导致声明与实际行为脱节。

---

## 6. 变更历史

| 日期 | 版本 | 变更 |
|---|---|---|
| 2025-10-22 | 0.1.x | 初始声明（随项目初始化创建） |
| 2026-08-11 | 1.0.1 | 修正 `NSPrivacyAccessedAPITypes` 与 `NSPrivacyTrackingDomains`；补充 `UserID`、`PhysicalAddress`；`UsageData` → `ProductInteraction`；移除 `Location`（IP 仅用于风控，无位置推导）；修复 CocoaPods 未打包隐私清单的问题；新增本文档 |
