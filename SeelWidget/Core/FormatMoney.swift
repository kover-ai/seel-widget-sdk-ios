import Foundation

public struct FormatMoneyOptions {
    public var showCurrency: Bool
    public var locale: String
    public var fallbackValue: String
    
    public init(
        showCurrency: Bool = true,
        locale: String = "",
        fallbackValue: String = "-"
    ) {
        self.showCurrency = showCurrency
        self.locale = locale
        self.fallbackValue = fallbackValue
    }
}

private let currencyLocaleMap: [String: String] = [
    "USD": "en-US",
    "CAD": "en-CA",
    "AUD": "en-AU",
    "EUR": "de-DE",
    "GBP": "en-GB",
    "NZD": "en-NZ",
    "HKD": "zh-HK",
    "SGD": "zh-SG",
    "DKK": "da-DK",
]

private let formatterLock = NSLock()
private var formatterCache: [String: NumberFormatter] = [:]

private func cachedFormatter(locale: String, currencyCode: String) -> NumberFormatter {
    let key = "\(locale)_\(currencyCode)"
    formatterLock.lock()
    defer { formatterLock.unlock() }
    if let cached = formatterCache[key] {
        return cached
    }
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: locale)
    formatter.currencyCode = currencyCode
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    formatterCache[key] = formatter
    return formatter
}

public func formatMoney(_ money: Double?, currency: String?, options: FormatMoneyOptions = FormatMoneyOptions()) -> String {
    guard let money = money else { return options.fallbackValue }
    
    // #4: uppercased() once, reuse everywhere
    let currencyCode = (currency ?? "").trimmingCharacters(in: .whitespaces).uppercased()
    
    // #3: Use String(format:) to avoid floating-point precision issues like "3.7500000000000004"
    if currencyCode.isEmpty {
        return String(format: "%.2f", money)
    }
    
    let usedLocale: String
    if !options.locale.isEmpty {
        usedLocale = options.locale
    } else {
        usedLocale = currencyLocaleMap[currencyCode] ?? "en-US"
    }
    
    let formatter = cachedFormatter(locale: usedLocale, currencyCode: currencyCode)
    
    guard let formatted = formatter.string(from: NSNumber(value: money)) else {
        let plain = String(format: "%.2f", money)
        return options.showCurrency ? "\(plain) \(currencyCode)" : plain
    }
    
    // HKD: replace "HK$" with "$"
    if currencyCode == "HKD" {
        let symbol = formatter.currencySymbol ?? "HK$"
        let replaced = formatted.replacingOccurrences(of: symbol, with: "$").trimmingCharacters(in: .whitespaces)
        return options.showCurrency ? "\(replaced) \(currencyCode)" : replaced
    }
    
    // If the currency symbol equals the currency code (e.g. "USD" instead of "$"),
    // fall back to plain format
    if let symbol = formatter.currencySymbol, symbol == currencyCode {
        let plain = String(format: "%.2f", money)
        return options.showCurrency ? "\(plain) \(currencyCode)" : plain
    }
    
    return options.showCurrency ? "\(formatted) \(currencyCode)" : formatted
}
