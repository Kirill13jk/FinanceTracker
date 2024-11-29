import SwiftUI

func currencySymbol(selectedCurrency: String) -> String {
    switch selectedCurrency {
    case "USD":
        return "$"
    case "EUR":
        return "€"
    case "RUB":
        return "₽"
    case "UZS":
        return "UZS "
    case "GBP":
        return "£"
    case "JPY":
        return "¥"
    case "CNY":
        return "¥"
    default:
        return "$"
    }
}
