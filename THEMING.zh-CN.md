# 外观与主题使用说明

> Seel Widget SDK for iOS
> 适用于 SDK 的深色模式 / 浅色模式 / 跟随系统，以及自定义主题配色。
> English version: [THEMING.md](THEMING.md)

## 目录

- [一分钟上手](#一分钟上手)
- [外观模式](#外观模式)
- [自定义主题](#自定义主题)
- [SeelTheme 字段说明](#seeltheme-字段说明)
- [优先级与回退规则](#优先级与回退规则)
- [常见场景](#常见场景)
- [生效范围与刷新机制](#生效范围与刷新机制)
- [图标与图片](#图标与图片)
- [兼容性](#兼容性)
- [排错](#排错)

---

## 一分钟上手

```swift
import SeelWidget

// 1. 跟随系统（默认，不写这行也一样）
SeelWidgetSDK.shared.themeMode = .auto

// 2. 或者强制某一种外观
SeelWidgetSDK.shared.themeMode = .dark

// 3. 需要品牌配色时，只覆盖你关心的字段
SeelWidgetSDK.shared.setTheme(SeelTheme(
    primaryColor: UIColor(hex: "#FF5A1F"),
    cornerRadius: 12
))
```

不做任何配置时，SDK 跟随系统外观，并使用内置配色。**浅色下的内置配色与引入深色模式之前的版本逐条一致**，老接入方升级后浅色外观不会有任何变化。

---

## 外观模式

```swift
SeelWidgetSDK.shared.themeMode = .auto   // 跟随系统（默认）
SeelWidgetSDK.shared.themeMode = .light  // 强制浅色
SeelWidgetSDK.shared.themeMode = .dark   // 强制深色
```

| 模式 | 行为 |
|---|---|
| `.auto` | 跟随系统外观。用户在「设置 → 显示与亮度」里切换时，已经在屏幕上的 SDK 视图**实时跟着变**，无需重建。**默认值。** |
| `.light` | 始终浅色，即使系统或宿主 App 是深色。 |
| `.dark` | 始终深色，即使系统或宿主 App 是浅色。 |

### 几点说明

- **随时可改。** 不必在 `configure` 之前设置，也不必在创建视图之前设置。改完之后，已经创建的 widget、banner、正在展示的弹窗都会自动重新着色。
- **只影响 SDK 自己的视图。** 强制模式下 SDK 会给自己的视图设置 `overrideUserInterfaceStyle`，所以弹窗里的毛玻璃、滚动条、加载指示器等系统控件也会跟着切换；宿主 App 的其它界面**完全不受影响**。
- **`.auto` 尊重宿主的设置。** 如果宿主 App 自己给某个页面设了 `overrideUserInterfaceStyle = .light`，SDK 的视图作为子视图会继承这个 trait，跟着显示浅色——这是符合预期的行为。想让 SDK 无视宿主设置，用 `.light` / `.dark` 显式指定。
- **请在主线程调用。** SDK 的视图全部在主线程构建，主题相关的 API 也只应在主线程访问。

---

## 自定义主题

`SeelTheme` 的每一个字段都是可选的。**为 `nil` 的字段沿用 SDK 内置配色**，所以你只需要写自己关心的那几项，不用凑齐全部。

### 浅深共用一套

```swift
SeelWidgetSDK.shared.setTheme(SeelTheme(
    primaryColor: UIColor(hex: "#FF5A1F"),
    ctaBackgroundColor: UIColor(hex: "#FF5A1F"),
    ctaTextColor: .white,
    cornerRadius: 12
))
```

`for` 参数省略时默认是 `.auto`，表示浅色和深色都用这套值。注意：如果你在这里传了一个很亮的背景色，深色模式下也会是这个亮色。**只要你的配色和深浅色相关，就应该分开注入**（见下）。

### 浅色 / 深色分别注入

```swift
SeelWidgetSDK.shared.setTheme(SeelTheme(
    primaryColor: UIColor(hex: "#D9541F"),
    backgroundColor: UIColor(hex: "#FDF6EB"),
    cardBackgroundColor: UIColor(hex: "#FAEEDC"),
    ctaBackgroundColor: UIColor(hex: "#D9541F"),
    ctaTextColor: .white
), for: .light)

SeelWidgetSDK.shared.setTheme(SeelTheme(
    primaryColor: UIColor(hex: "#FF8C59"),
    backgroundColor: UIColor(hex: "#211A14"),
    cardBackgroundColor: UIColor(hex: "#33261E"),
    ctaBackgroundColor: UIColor(hex: "#FF8C59"),
    ctaTextColor: .black
), for: .dark)
```

两套配色会分别在浅色和深色外观下生效；`themeMode` 为 `.auto` 时，系统切换外观会在两套之间自动切换。

### 清除自定义

```swift
// 清除某一种外观的自定义
SeelWidgetSDK.shared.setTheme(nil, for: .dark)

// 全部清除，回到内置配色
SeelWidgetSDK.shared.resetTheme()
```

---

## SeelTheme 字段说明

下表的「内置默认值」列出的是 SDK 自带的浅色 / 深色取值，方便你判断哪些需要覆盖。

### 品牌色

| 字段 | 作用范围 | 浅色默认 | 深色默认 |
|---|---|---|---|
| `primaryColor` | 开关打开时的轨道色、详情页「Seel」强调字、WebView 进度条 | `#2121C4` | `#6C6CF0` |
| `onPrimaryColor` | 画在 `primaryColor` 之上的文字 / 图标 | `#FFFFFF` | `#FFFFFF` |
| `accentColor` | 商详 banner 里的 `seel` 字样 | `#635BFF` | `#8F88FF` |

### 背景

| 字段 | 作用范围 | 浅色默认 | 深色默认 |
|---|---|---|---|
| `backgroundColor` | widget 与详情页的整体背景 | `#FFFFFF` | `#1C1C1E` |
| `selectedBackgroundColor` | 用户已勾选时的 widget 背景 | 同背景色 | 同背景色 |
| `disabledBackgroundColor` | 报价被拒（rejected）时的 widget 背景 | `#F0EFEF` | `#2C2C2E` |
| `cardBackgroundColor` | 详情弹窗内的卡片（What's Covered、功能卡） | `#F8F9FF` | `#2C2C2E` |
| `elevatedBackgroundColor` | 浮层：弹窗容器、tooltip 卡片、导航栏 | `#FFFFFF` | `#1C1C1E` |

### 文本

| 字段 | 作用范围 | 浅色默认 | 深色默认 |
|---|---|---|---|
| `primaryTextColor` | 标题、主要文字 | `#000000` | `#FFFFFF` |
| `secondaryTextColor` | 次要说明文字、「No Need」按钮 | `#565656` | `#AEAEB2` |
| `tertiaryTextColor` | 副标题、banner 正文 | `#676667` | `#AEAEB2` |
| `disclaimerTextColor` | 免责声明、「Continue Without Protection」 | `#808692` | `#8E8E93` |
| `linkTextColor` | Privacy Policy / Terms of Service 链接 | `#5C5F62` | `#A1A1A6` |

### 按钮

| 字段 | 作用范围 | 浅色默认 | 深色默认 |
|---|---|---|---|
| `ctaBackgroundColor` | 主行动按钮背景（两种版式的按钮都会跟着变） | `#333333` / `#000000` | `#F2F2F7` |
| `ctaTextColor` | 主行动按钮文字 | `#FFFFFF` | `#000000` |

> 深色默认是「浅底深字」的按钮，这是深色界面里 CTA 的常见做法。如果你的品牌要求深色下仍是深底按钮，显式覆盖这两项即可。

### 装饰与度量

| 字段 | 作用范围 | 浅色默认 | 深色默认 |
|---|---|---|---|
| `borderColor` | 边框、弹窗内分割线 | `#E0E0E0` | `#48484A` |
| `separatorColor` | 导航栏底部细线、进度条底槽 | `#EEEEEE` | `#38383A` |
| `iconTintColor` | **深色模式下**单色图标的着色（浅色下图标保持原样） | `#000000` | `#FFFFFF` |
| `borderWidth` | widget 边框宽度 | `0` | `0` |
| `cornerRadius` | widget 圆角 | `0` | `0` |

---

## 优先级与回退规则

### 三级优先级

```
视图上直接设置的值   >   自定义主题   >   SDK 内置默认
```

也就是说下面这些「视图级」属性一旦你设过，主题就不会去动它：

```swift
wfpView.backgroundColor = .white          // 主题切换不会覆盖
wfpView.normalBackgroundColor = ...
wfpView.selectedBackgroundColor = ...
wfpView.disabledBackgroundColor = ...
wfpView.cornerRadius = 8
pdpBanner.setup(type: type, style: PDPBannerStyle(backgroundColor: .white))
```

> ⚠️ 这一条也是个坑：如果你在宿主里写死了 `wfpView.backgroundColor = .white`，深色模式下这个 widget 会**保持白底**。想让它跟随主题，把这行删掉即可。

### 两条便利回退

为了避免「只改了一个字段却显得配色割裂」，有两处会连带生效：

| 你覆盖了 | 连带影响 | 想避免的话 |
|---|---|---|
| `backgroundColor` | `selectedBackgroundColor` 和 `elevatedBackgroundColor` 一起跟随 | 显式指定这两项 |
| `ctaBackgroundColor` | 两种版式的 CTA 按钮都用这个色 | 无（这是刻意统一的） |

---

## 常见场景

### 场景 1：宿主 App 有自己的「浅色 / 深色 / 跟随系统」设置项

把用户的选择透传给 SDK 即可：

```swift
func applyAppearance(_ setting: AppAppearance) {
    switch setting {
    case .light:  SeelWidgetSDK.shared.themeMode = .light
    case .dark:   SeelWidgetSDK.shared.themeMode = .dark
    case .system: SeelWidgetSDK.shared.themeMode = .auto
    }
}
```

不需要重建任何 SDK 视图，也不需要重新请求报价。

### 场景 2：宿主 App 整体不支持深色，希望 SDK 也别变

```swift
SeelWidgetSDK.shared.themeMode = .light
```

一行搞定，且不受系统设置影响。

### 场景 3：只想换品牌主色

```swift
SeelWidgetSDK.shared.setTheme(SeelTheme(
    primaryColor: UIColor(hex: "#00A87E"),
    accentColor: UIColor(hex: "#00A87E")
))
```

其余颜色继续用 SDK 的浅深两套默认值，深色模式照常工作。

### 场景 4：widget 要有圆角和边框

```swift
SeelWidgetSDK.shared.setTheme(SeelTheme(
    borderColor: UIColor(hex: "#E5E5E5"),
    borderWidth: 1,
    cornerRadius: 12
))
```

也可以只对单个视图设置：`wfpView.cornerRadius = 12`（优先级更高）。

### 场景 5：在设置页做一个实时预览

主题相关的 API 都是即时生效的，直接在 `valueChanged` 里改就行：

```swift
@objc private func modeChanged(_ sender: UISegmentedControl) {
    SeelWidgetSDK.shared.themeMode = [.light, .dark, .auto][sender.selectedSegmentIndex]
}
```

Example 工程的 `ViewController` 里有一个可运行的完整示例（Theme 分段控件 + Custom theme 开关）。

---

## 生效范围与刷新机制

### 覆盖的界面

| 界面 | 说明 |
|---|---|
| `SeelWFPView` | 购物车 / 结算页的保障 widget（含正常、已选、禁用三态） |
| `SeelPDPBannerView` | 商详页 banner |
| 保障详情弹窗 | 默认版式（全屏）与 EBTH 版式（底部卡片）均已适配 |
| 拒保提示 tooltip | 点击禁用态 widget 弹出的说明浮层 |
| 内置 WebView | 打开隐私政策 / 服务条款的页面（导航栏、进度条、背景） |

### 刷新是怎么发生的

- **系统外观切换（`.auto`）**：内部颜色是 iOS 13 的动态色，由 UIKit 在 trait 变化时自动重新解析，SDK 不做任何重建，也没有闪烁。
- **调用 `themeMode` / `setTheme` / `resetTheme`**：SDK 内部广播一次通知，widget、banner 重建自己的子视图，正在展示的详情弹窗重建内容。这个过程不会丢失用户已勾选的状态，也不会重新发请求。

如果你有自定义的界面需要跟着一起刷新，可以监听同一个通知：

```swift
NotificationCenter.default.addObserver(
    forName: .SeelThemeDidChange, object: nil, queue: .main
) { _ in
    // 你自己的刷新逻辑
}
```

---

## 图标与图片

深色模式下的图片按两类处理：

**会重新着色的**——纯单色带透明通道的图标：勾选框边框、info 图标、对勾、闪电、耳机、盾牌、购物袋等。它们在深色下换成 `iconTintColor`（或更柔和的次级灰）。**浅色下原样返回资源包里的原图**，所以浅色外观不会有任何改变。

**保持原样的**——双色或彩色图片：带白色对勾的实心勾选框、Seel 品牌图标与文字标、弹窗顶部的头图。这类图片强行重着色会糊成一块色块，因此维持原样。它们在深色背景上依然清晰可辨。

如果你的品牌需要替换这些图片资源，目前需要联系 Seel 侧调整资源包，SDK 暂未开放图片替换接口。

---

## 兼容性

### 系统版本

| 系统 | 行为 |
|---|---|
| iOS 13+ | 三种模式全部可用，`.auto` 实时跟随系统。 |
| iOS 12 | 系统本身没有深色模式，`.auto` 等同于 `.light`。`.dark` **仍然可用**（颜色与图标都会切换），只是无法联动系统控件的外观。 |

### 从旧版本升级

浅色外观**零变化**，不做任何配置即可直接升级。以下三处 API 有调整，都保持了原有的调用形态，已有代码无需修改：

| API | 变化 | 影响 |
|---|---|---|
| `PDPBannerStyle.backgroundColor` | `UIColor` → `UIColor?`，默认 `nil`（跟随主题） | 仍可直接传 `UIColor`；只有**读取**这个属性的代码需要处理可选值 |
| `SeelWFPView.disabledBackgroundColor` | 默认值从写死的 `#F0EFEF` 改为读主题 | 显式赋值的行为不变 |
| `SeelWFPView.cornerRadius` | 默认值从写死的 `0` 改为读主题（主题默认仍是 `0`） | 显式赋值的行为不变 |

---

## 排错

**设了 `.dark` 但 widget 还是白的**
检查宿主里有没有写死 `wfpView.backgroundColor = .white`——视图级设置优先级高于主题。删掉这行即可。

**`.auto` 下切系统外观没反应**
确认宿主没有在上层视图或 window 上设 `overrideUserInterfaceStyle`；`.auto` 会继承宿主的 trait。要无视宿主设置就改用 `.dark` / `.light`。

**只改了 `backgroundColor`，但弹窗里的卡片还是默认色**
`backgroundColor` 只会连带 `selectedBackgroundColor` 和 `elevatedBackgroundColor`，卡片是独立的 `cardBackgroundColor`，需要另外指定。

**自定义主题在深色下颜色不对**
确认你是不是用了默认的 `for: .auto` 把同一套颜色同时套给了浅色和深色。需要区分时请分两次调用 `setTheme(_:for:)`。

**深色下某个按钮变成了浅底深字**
这是 CTA 按钮的深色默认样式。覆盖 `ctaBackgroundColor` 和 `ctaTextColor` 即可改回深底浅字。

**主题改了但没生效**
确认调用发生在主线程。

---

## API 速查

```swift
// 外观模式（可读可写，默认 .auto）
SeelWidgetSDK.shared.themeMode: SeelThemeMode

// 注入自定义主题；mode 省略时为 .auto（浅深共用）
SeelWidgetSDK.shared.setTheme(_ theme: SeelTheme?, for mode: SeelThemeMode = .auto)

// 清除全部自定义主题
SeelWidgetSDK.shared.resetTheme()

// 主题变更通知
Notification.Name.SeelThemeDidChange
```
