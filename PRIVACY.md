# SeelWidget SDK Privacy Disclosure

> **English** | [简体中文](PRIVACY.zh-CN.md)

This document describes every piece of data the SeelWidget SDK collects and transmits. Use it to complete your **App Privacy questionnaire** in App Store Connect. It also serves as the maintenance reference for `SeelWidget/PrivacyInfo.xcprivacy`.

> **Read this before submitting to the App Store.** Apple requires your app's privacy disclosure to cover data collected by third-party SDKs. You cannot determine what an SDK collects by inspecting its binary — this document is the authoritative source for SeelWidget.

---

## 1. Baseline: the SDK collects nothing on its own

The SDK contains **no** calls to any device-identifier or sensor API:

- No `identifierForVendor` / `advertisingIdentifier`
- No `UIDevice`-based collection
- No `CoreLocation`

All user and device identifiers (`customer_id`, `device_id`, `client_ip`, …) are **supplied by the host app as method parameters** — you control what is collected. However, because that data is transmitted to Seel's servers through the SDK, Apple still counts it as SDK data collection, so it must be disclosed.

---

## 2. Data transmitted, by endpoint

### 2.1 `POST /v1/ecommerce/quotes` — insurance quote

Triggered when the host calls `SeelWFPView.setup(_:completion:)` or `updateWidgetWhenChanged(_:completion:)`.

| Request field | Contents | Apple data type | Purpose |
|---|---|---|---|
| `customer.first_name` / `last_name` | Name | Name | App Functionality |
| `customer.email` | Email address | Email Address | App Functionality |
| `customer.phone` | Phone number | Phone Number | App Functionality |
| `customer.customer_id` | Customer identifier | User ID | App Functionality |
| `shipping_address.*` | Shipping address (address1 / city / state / zipcode / country) | Physical Address | App Functionality |
| `device_id` | Device identifier | Device ID | App Functionality |
| `client_ip` | IP address (optional, host-supplied) | **Not disclosed** — see §3.2 | Fraud prevention only |
| `line_items[]` | Product details, prices, categories, quantities | Purchase History | App Functionality |
| `session_id` / `device_category` / `device_platform` | Session and device class | Product Interaction | App Functionality |
| `extra_info` | Free-form, host-defined | **Depends on what you send** | — |

> ⚠️ `extra_info` is an open `[String: AnyCodable]` structure. **If you place personal data in it that is not listed above, you are responsible for disclosing it.**

### 2.2 `POST /v1/ecommerce/user-configs/{user_id}` — insurance opt-out

**Initiated by the SDK automatically** when the user unchecks the insurance option. The host does not call it and cannot suppress it. Currently active only for merchants where `type == "ebth-wfp"`.

| Field | Contents | Apple data type |
|---|---|---|
| `{user_id}` in the URL path | Customer identifier (taken from the quote response) | User ID |
| `merchant_id` | Merchant identifier | Not personal data |
| `opted_out` | Opt-out flag | — |

### 2.3 `POST /v1/ecommerce/events` — behavioural analytics

**The SDK never calls this on its own.** Events are sent only when the host explicitly calls `SeelWidgetSDK.shared.createEvents(_:completion:)` — if you never call it, no events are ever produced.

| Field | Contents | Apple data type |
|---|---|---|
| `customer_id` | Customer identifier | User ID |
| `device_id` | Device identifier | Device ID |
| `client_ip` | IP address | **Not disclosed** — see §3.2 |
| `event_type` | `product_page_enter` / `favorite_add` / `cart_add` / `checkout_begin` / `checkout_complete`, etc. | Product Interaction |
| `event_info` | Free-form, host-defined | **Depends on what you send** |

---

## 3. How the privacy manifest maps to the code

The 8 collected data types declared in `SeelWidget/PrivacyInfo.xcprivacy`, mapped to §2:

| Declared value | Source field |
|---|---|
| `NSPrivacyCollectedDataTypeName` | `customer.first_name` / `last_name` |
| `NSPrivacyCollectedDataTypeEmailAddress` | `customer.email` |
| `NSPrivacyCollectedDataTypePhoneNumber` | `customer.phone` |
| `NSPrivacyCollectedDataTypePhysicalAddress` | `shipping_address.*` |
| `NSPrivacyCollectedDataTypeUserID` | `customer.customer_id` |
| `NSPrivacyCollectedDataTypeDeviceID` | `device_id` |
| `NSPrivacyCollectedDataTypePurchaseHistory` | `line_items[]` |
| `NSPrivacyCollectedDataTypeProductInteraction` | `event_type` / `session_id` |

All are declared as `Linked: true` (linked to the user's identity), `Tracking: false`, purpose `App Functionality`.

### 3.1 Why `NSPrivacyTracking` is `false`

Apple's definition of tracking has two independent triggers: linking data from your app with data collected by **other companies'** apps, websites, or offline properties **for targeted advertising or advertising measurement**; or **sharing data with a data broker**.

Seel uses the collected data solely for insurance quoting, risk assessment, and claims. **No data is provided to advertising platforms or data brokers.** Neither trigger applies, so `NSPrivacyTracking = false` and `NSPrivacyTrackingDomains` is an empty array.

> 🔴 **Do not change these two fields.** If `api.seel.com` is ever listed in `NSPrivacyTrackingDomains`, iOS will **block requests to it** whenever the user has not granted ATT authorisation, disabling the SDK's quoting functionality for those users entirely. Because the quoting API and any prospective tracking domain are the same host, Seel has no viable path to a tracking-based configuration — introducing one would first require separating the advertising domain from the API domain.

### 3.2 Why `client_ip` is not disclosed

`client_ip` is optional. The SDK never assigns it; it is transmitted only when the host supplies it. Seel's servers use it **solely for risk assessment and fraud prevention — it is never used to derive geographic location, drive business logic, or serve advertising.**

Apple's data-type taxonomy has no "IP address" entry. An IP address requires disclosure as Coarse Location only when it is used to **determine the user's location**. Since no location derivation takes place, this SDK declares no location data of any kind.

> If the backend ever begins deriving geographic location from IP for business purposes, `NSPrivacyCollectedDataTypeCoarseLocation` must be added and all integrators notified to update their App Privacy questionnaires.

### 3.3 Required-reason API declarations

| Category | Reason | Notes |
|---|---|---|
| `UserDefaults` | `CA92.1` | Persists the user's insurance selection (`SeelWFPView`) |
| `SystemBootTime` | `35F9.1` | Retained declaration |
| `FileTimestamp` | `C617.1` | Retained declaration |
| `DiskSpace` | `85F4.1` | Retained declaration |

The last three have no direct call sites but are **retained deliberately** — Apple penalises under-declaration (`ITMS-91053`) but not over-declaration, and removing them would risk rejection if an indirect call is ever introduced.

`NSPrivacyAccessedAPICategoryNetworkState` was previously declared in error. It is not one of Apple's five valid categories (`FileTimestamp` / `SystemBootTime` / `DiskSpace` / `ActiveKeyboards` / `UserDefaults`) and was removed in 1.0.1.

---

## 4. What integrators need to do

1. Cross-check the tables in §2 against your app's App Privacy questionnaire and make sure every data type is covered
2. If you populate `extra_info`, evaluate and disclose those fields yourself
3. If you do not want the SDK to send behavioural events, **simply never call `createEvents`** — the SDK will not send any
4. The opt-out call (`postUserConfig`) is initiated by the SDK and cannot be disabled; contact Seel if this is a concern

---

## 5. Maintenance rule

**Whenever any of the following change, revisit this document and `PrivacyInfo.xcprivacy`:**

- `SeelWidget/Network/Models/**` — request/response model fields
- `SeelWidget/Network/NetworkManager.swift` — new or modified endpoints
- Any newly introduced `URLSession` call

**A privacy manifest is a contract that evolves with the code, not a one-time form.** Field changes that are not mirrored in the manifest cause the declaration to drift out of sync with actual behaviour.

---

## 6. Change history

| Date | Version | Change |
|---|---|---|
| 2025-10-22 | 0.1.x | Initial declaration (created with the project) |
| 2026-08-11 | 1.0.1 | Corrected `NSPrivacyAccessedAPITypes` and `NSPrivacyTrackingDomains`; added `UserID` and `PhysicalAddress`; `UsageData` → `ProductInteraction`; removed `Location` (IP used for fraud prevention only, no location derivation); fixed the podspec so the privacy manifest is packaged for CocoaPods; added this document |
