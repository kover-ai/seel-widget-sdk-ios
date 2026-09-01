# Appearance & Theming Guide

> Seel Widget SDK for iOS
> Dark mode, light mode, follow-the-system, and custom brand palettes.
> 中文版：[THEMING.zh-CN.md](THEMING.zh-CN.md)

## Contents

- [Quick start](#quick-start)
- [Appearance modes](#appearance-modes)
- [Custom themes](#custom-themes)
- [SeelTheme reference](#seeltheme-reference)
- [Precedence and fallbacks](#precedence-and-fallbacks)
- [Recipes](#recipes)
- [Scope and refresh behavior](#scope-and-refresh-behavior)
- [Icons and images](#icons-and-images)
- [Compatibility](#compatibility)
- [Troubleshooting](#troubleshooting)

---

## Quick start

```swift
import SeelWidget

// 1. Follow the system (this is the default — you can omit it)
SeelWidgetSDK.shared.themeMode = .auto

// 2. Or pin one appearance
SeelWidgetSDK.shared.themeMode = .dark

// 3. Brand colors: override only the fields you care about
SeelWidgetSDK.shared.setTheme(SeelTheme(
    primaryColor: UIColor(hex: "#FF5A1F"),
    cornerRadius: 12
))
```

With no configuration the SDK follows the system appearance and uses its built-in palette. **The light palette matches the pre-dark-mode release value for value**, so existing integrations see no visual change after upgrading.

---

## Appearance modes

```swift
SeelWidgetSDK.shared.themeMode = .auto   // follow the system (default)
SeelWidgetSDK.shared.themeMode = .light  // always light
SeelWidgetSDK.shared.themeMode = .dark   // always dark
```

| Mode | Behavior |
|---|---|
| `.auto` | Follows the system appearance. When the user flips it in Settings, on-screen SDK views **update live** — no rebuild needed. **Default.** |
| `.light` | Always light, even when the system or host app is dark. |
| `.dark` | Always dark, even when the system or host app is light. |

### Notes

- **Change it at any time.** It does not need to be set before `configure`, nor before the views are created. Existing widgets, banners, and a presented modal all re-render themselves.
- **Only the SDK's own views are affected.** In a forced mode the SDK sets `overrideUserInterfaceStyle` on its own views, so system controls inside them (blur, scroll indicators, activity indicators) match too. Your app's other screens are **never touched**.
- **`.auto` respects the host.** If your app pins a screen with `overrideUserInterfaceStyle = .light`, SDK views nested in it inherit that trait and render light — that's intended. Use `.light` / `.dark` when the SDK should ignore the host.
- **Call on the main thread.** All SDK views are built on the main thread, and so should the theming APIs be called.

---

## Custom themes

Every `SeelTheme` field is optional. **Fields left `nil` keep the SDK's built-in colors**, so you only specify what your brand needs.

### One palette for both appearances

```swift
SeelWidgetSDK.shared.setTheme(SeelTheme(
    primaryColor: UIColor(hex: "#FF5A1F"),
    ctaBackgroundColor: UIColor(hex: "#FF5A1F"),
    ctaTextColor: .white,
    cornerRadius: 12
))
```

Omitting `for:` defaults to `.auto`, meaning both light and dark use these values. Careful: a bright background passed here will also be used in dark mode. **If a color depends on the appearance, register it per appearance instead** (below).

### A palette per appearance

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

Each palette applies to its own appearance. With `themeMode == .auto`, a system appearance switch moves between the two automatically.

### Clearing overrides

```swift
// Drop the override for one appearance
SeelWidgetSDK.shared.setTheme(nil, for: .dark)

// Drop everything and return to the built-in palette
SeelWidgetSDK.shared.resetTheme()
```

---

## SeelTheme reference

The default columns show the SDK's own light / dark values, so you can tell what actually needs overriding.

### Brand

| Field | Applies to | Light default | Dark default |
|---|---|---|---|
| `primaryColor` | Switch "on" track, the accented "Seel" word in the info screen, web view progress bar | `#2121C4` | `#6C6CF0` |
| `onPrimaryColor` | Content drawn on top of `primaryColor` | `#FFFFFF` | `#FFFFFF` |
| `accentColor` | The `seel` wordmark in the PDP banner | `#635BFF` | `#8F88FF` |

### Backgrounds

| Field | Applies to | Light default | Dark default |
|---|---|---|---|
| `backgroundColor` | Widget and info screen background | `#FFFFFF` | `#1C1C1E` |
| `selectedBackgroundColor` | Widget background once opted in | same as background | same as background |
| `disabledBackgroundColor` | Widget background when the quote is rejected | `#F0EFEF` | `#2C2C2E` |
| `cardBackgroundColor` | Cards inside the info modal (What's Covered, feature cards) | `#F8F9FF` | `#2C2C2E` |
| `elevatedBackgroundColor` | Overlays: modal sheet, tooltip card, navigation bar | `#FFFFFF` | `#1C1C1E` |

### Text

| Field | Applies to | Light default | Dark default |
|---|---|---|---|
| `primaryTextColor` | Titles and primary copy | `#000000` | `#FFFFFF` |
| `secondaryTextColor` | Supporting copy, the "No Need" button | `#565656` | `#AEAEB2` |
| `tertiaryTextColor` | Subtitles, PDP banner body | `#676667` | `#AEAEB2` |
| `disclaimerTextColor` | Disclaimers, "Continue Without Protection" | `#808692` | `#8E8E93` |
| `linkTextColor` | Privacy Policy / Terms of Service links | `#5C5F62` | `#A1A1A6` |

### Buttons

| Field | Applies to | Light default | Dark default |
|---|---|---|---|
| `ctaBackgroundColor` | Primary button background (covers both layout variants) | `#333333` / `#000000` | `#F2F2F7` |
| `ctaTextColor` | Primary button title | `#FFFFFF` | `#000000` |

> The dark default is a light button with dark text, the common pattern for CTAs on dark backgrounds. Override both fields if your brand requires a dark button in dark mode.

### Decoration and metrics

| Field | Applies to | Light default | Dark default |
|---|---|---|---|
| `borderColor` | Borders and the divider inside the modal | `#E0E0E0` | `#48484A` |
| `separatorColor` | Navigation bar hairline, progress bar track | `#EEEEEE` | `#38383A` |
| `iconTintColor` | Monochrome icon tint **in dark mode** (icons are untouched in light mode) | `#000000` | `#FFFFFF` |
| `borderWidth` | Widget border width | `0` | `0` |
| `cornerRadius` | Widget corner radius | `0` | `0` |

---

## Precedence and fallbacks

### Three levels

```
Value set on the view   >   custom theme   >   SDK built-in default
```

Once you set any of these view-level properties, the theme leaves them alone:

```swift
wfpView.backgroundColor = .white          // a theme switch will not overwrite this
wfpView.normalBackgroundColor = ...
wfpView.selectedBackgroundColor = ...
wfpView.disabledBackgroundColor = ...
wfpView.cornerRadius = 8
pdpBanner.setup(type: type, style: PDPBannerStyle(backgroundColor: .white))
```

> ⚠️ This is also the most common pitfall: a hardcoded `wfpView.backgroundColor = .white` in your app keeps the widget **white in dark mode**. Remove that line to let the theme drive it.

### Two convenience fallbacks

So that a partial theme doesn't look inconsistent, two overrides carry further:

| Overriding | Also moves | To avoid |
|---|---|---|
| `backgroundColor` | `selectedBackgroundColor` and `elevatedBackgroundColor` follow it | Set those two explicitly |
| `ctaBackgroundColor` | Both CTA variants use it | N/A — this unification is intentional |

---

## Recipes

### 1. Your app already has a Light / Dark / System setting

Forward the user's choice:

```swift
func applyAppearance(_ setting: AppAppearance) {
    switch setting {
    case .light:  SeelWidgetSDK.shared.themeMode = .light
    case .dark:   SeelWidgetSDK.shared.themeMode = .dark
    case .system: SeelWidgetSDK.shared.themeMode = .auto
    }
}
```

No SDK views need rebuilding and no quote is re-requested.

### 2. Your app has no dark mode and the SDK shouldn't either

```swift
SeelWidgetSDK.shared.themeMode = .light
```

One line, and it ignores the system setting.

### 3. Just the brand color

```swift
SeelWidgetSDK.shared.setTheme(SeelTheme(
    primaryColor: UIColor(hex: "#00A87E"),
    accentColor: UIColor(hex: "#00A87E")
))
```

Everything else keeps the SDK's light and dark defaults, so dark mode still works properly.

### 4. Rounded widget with a border

```swift
SeelWidgetSDK.shared.setTheme(SeelTheme(
    borderColor: UIColor(hex: "#E5E5E5"),
    borderWidth: 1,
    cornerRadius: 12
))
```

Or per view: `wfpView.cornerRadius = 12` (higher precedence).

### 5. A live preview in a settings screen

The theming APIs take effect immediately, so call them straight from `valueChanged`:

```swift
@objc private func modeChanged(_ sender: UISegmentedControl) {
    SeelWidgetSDK.shared.themeMode = [.light, .dark, .auto][sender.selectedSegmentIndex]
}
```

The Example project's `ViewController` ships a runnable version of this (Theme segmented control + Custom theme switch).

---

## Scope and refresh behavior

### Surfaces covered

| Surface | Notes |
|---|---|
| `SeelWFPView` | Cart / checkout protection widget (normal, selected and rejected states) |
| `SeelPDPBannerView` | Product detail page banner |
| Info modal | Both the default (full screen) and EBTH (bottom sheet) variants |
| Rejection tooltip | The overlay shown when tapping a disabled widget |
| Built-in web view | Privacy Policy / Terms pages (nav bar, progress bar, background) |

### How refresh happens

- **System appearance switch (`.auto`)**: colors are iOS 13 dynamic colors, re-resolved by UIKit on trait change. Nothing is rebuilt and there is no flicker.
- **Calling `themeMode` / `setTheme` / `resetTheme`**: the SDK broadcasts a notification; widgets and banners rebuild their subviews and a presented info modal rebuilds its content. The user's opt-in state is preserved and no network request is repeated.

To refresh your own UI alongside, observe the same notification:

```swift
NotificationCenter.default.addObserver(
    forName: .SeelThemeDidChange, object: nil, queue: .main
) { _ in
    // your refresh logic
}
```

---

## Icons and images

Images fall into two buckets in dark mode:

**Re-tinted** — flat monochrome icons with an alpha channel: checkbox outlines, the info glyph, checkmarks, bolt, headphones, shield, shopping bag. In dark mode they take `iconTintColor` (or a softer muted grey). **In light mode the original asset is returned untouched**, so the light appearance never changes.

**Left as-is** — two-tone or full-color artwork: the filled checkbox with a white tick, the Seel logo and wordmark, the modal header photo. Re-tinting these would flatten them into a solid blob, so they stay original. They remain legible on dark backgrounds.

Replacing these assets for your brand currently requires a change on the Seel side; the SDK does not expose an image-override API yet.

---

## Compatibility

### OS versions

| OS | Behavior |
|---|---|
| iOS 13+ | All three modes; `.auto` tracks the system live. |
| iOS 12 | The OS has no dark mode, so `.auto` renders as light. `.dark` **still works** (colors and icons both switch); it just cannot drive system control appearance. |

### Upgrading from an earlier version

The light appearance is **unchanged** — upgrade without configuring anything. Three APIs changed shape but kept their call sites source-compatible:

| API | Change | Impact |
|---|---|---|
| `PDPBannerStyle.backgroundColor` | `UIColor` → `UIColor?`, default `nil` (follows the theme) | Passing a `UIColor` still works; only code that **reads** the property must handle the optional |
| `SeelWFPView.disabledBackgroundColor` | Default moved from a hardcoded `#F0EFEF` to the theme | Explicit assignment behaves as before |
| `SeelWFPView.cornerRadius` | Default moved from a hardcoded `0` to the theme (still `0` by default) | Explicit assignment behaves as before |

---

## Troubleshooting

**I set `.dark` but the widget is still white**
Check for a hardcoded `wfpView.backgroundColor = .white` in your app — view-level settings outrank the theme. Remove that line.

**`.auto` doesn't react to the system switch**
Make sure the host isn't setting `overrideUserInterfaceStyle` on an ancestor view or the window; `.auto` inherits the host's trait. Use `.dark` / `.light` to ignore the host.

**I overrode `backgroundColor` but the modal cards are still default**
`backgroundColor` only carries into `selectedBackgroundColor` and `elevatedBackgroundColor`. Cards are `cardBackgroundColor` and must be set separately.

**My custom theme looks wrong in dark mode**
You probably used the default `for: .auto`, applying one palette to both appearances. Call `setTheme(_:for:)` twice when the colors differ.

**A button turned into a light button with dark text in dark mode**
That's the CTA's dark default. Override `ctaBackgroundColor` and `ctaTextColor` to keep a dark button.

**Theme changes don't take effect**
Confirm the call happens on the main thread.

---

## API cheat sheet

```swift
// Appearance mode (readable and writable, defaults to .auto)
SeelWidgetSDK.shared.themeMode: SeelThemeMode

// Inject a custom theme; mode defaults to .auto (both appearances)
SeelWidgetSDK.shared.setTheme(_ theme: SeelTheme?, for mode: SeelThemeMode = .auto)

// Drop every custom theme
SeelWidgetSDK.shared.resetTheme()

// Theme change notification
Notification.Name.SeelThemeDidChange
```
