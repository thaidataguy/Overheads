//
//  SubscriptionStore.swift
//  Overheads
//
//  Created by Tanagarn Ploychinda on 4/22/26.
//

import Combine
import Foundation

enum SupportedCurrency: String, CaseIterable, Identifiable {
    case aud
    case gbp
    case cad
    case cny
    case eur
    case jpy
    case sgd
    case thb
    case usd
    case vnd

    var id: String { rawValue }

    var name: String {
        switch self {
        case .aud:
            return "Australian Dollar"
        case .gbp:
            return "British Pound Sterling"
        case .cad:
            return "Canadian Dollar"
        case .cny:
            return "Chinese Yuan"
        case .eur:
            return "Euro"
        case .jpy:
            return "Japanese Yen"
        case .sgd:
            return "Singapore Dollar"
        case .thb:
            return "Thai Baht"
        case .usd:
            return "US Dollar"
        case .vnd:
            return "Vietnamese Dong"
        }
    }

    var symbol: String {
        switch self {
        case .aud:
            return "$"
        case .gbp:
            return "£"
        case .cad:
            return "$"
        case .cny:
            return "¥"
        case .eur:
            return "€"
        case .jpy:
            return "¥"
        case .sgd:
            return "$"
        case .thb:
            return "฿"
        case .usd:
            return "$"
        case .vnd:
            return "₫"
        }
    }

    var detail: String {
        switch self {
        case .aud:
            return "AUD"
        case .gbp:
            return "GBP"
        case .cad:
            return "CAD"
        case .cny:
            return "CNY"
        case .eur:
            return "EUR"
        case .jpy:
            return "JPY"
        case .sgd:
            return "SGD"
        case .thb:
            return "THB"
        case .usd:
            return "USD"
        case .vnd:
            return "VND"
        }
    }

    var showsDecimalAmounts: Bool {
        switch self {
        case .thb, .jpy, .cny, .vnd:
            return false
        default:
            return true
        }
    }
}

@MainActor
final class SubscriptionStore: ObservableObject {
    @Published var selectedCurrency: SupportedCurrency? {
        didSet {
            persistSelectedCurrency()
        }
    }
    @Published private(set) var savedSubscriptions: [Subscription] {
        didSet {
            persistSavedSubscriptions()
        }
    }

    private let selectedCurrencyKey = "selected_currency"
    private let savedSubscriptionsKey = "saved_subscriptions"
    private let hasShownFirstAddSubscriptionPageKey = "has_shown_first_add_subscription_page"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let storedValue = defaults.string(forKey: selectedCurrencyKey) {
            self.selectedCurrency = SupportedCurrency(rawValue: storedValue)
        } else {
            self.selectedCurrency = nil
        }

        if
            let storedData = defaults.data(forKey: savedSubscriptionsKey),
            let decodedSubscriptions = try? JSONDecoder().decode([Subscription].self, from: storedData)
        {
            self.savedSubscriptions = decodedSubscriptions
        } else {
            self.savedSubscriptions = []
        }

        BillingNotificationScheduler.refreshNotifications(for: savedSubscriptions)
    }

    func setSelectedCurrency(_ currency: SupportedCurrency) {
        selectedCurrency = currency
    }

    func addSubscription(
        name: String,
        amount: Double,
        frequency: Frequency,
        nextChargeDate: Date
    ) {
        let subscription = Subscription(
            name: name,
            icon: Subscription.iconName(for: name),
            amount: amount,
            frequency: frequency,
            nextChargeDate: nextChargeDate,
            isAcknowledged: false
        )

        savedSubscriptions.append(subscription)
        BillingNotificationScheduler.refreshNotifications(for: savedSubscriptions)
    }

    func updateSubscription(
        id: UUID,
        name: String,
        amount: Double,
        frequency: Frequency,
        nextChargeDate: Date
    ) {
        guard let index = savedSubscriptions.firstIndex(where: { $0.id == id }) else { return }

        let previousNextChargeDate = savedSubscriptions[index].nextChargeDate
        savedSubscriptions[index].name = name
        savedSubscriptions[index].icon = Subscription.iconName(for: name)
        savedSubscriptions[index].amount = amount
        savedSubscriptions[index].frequency = frequency
        savedSubscriptions[index].nextChargeDate = nextChargeDate
        if previousNextChargeDate != nextChargeDate {
            savedSubscriptions[index].isAcknowledged = false
        }
        BillingNotificationScheduler.refreshNotifications(for: savedSubscriptions)
    }

    func deleteSubscription(id: UUID) {
        savedSubscriptions.removeAll { $0.id == id }
        BillingNotificationScheduler.refreshNotifications(for: savedSubscriptions)
    }

    func toggleAcknowledgement(for id: UUID) {
        guard let index = savedSubscriptions.firstIndex(where: { $0.id == id }) else { return }
        savedSubscriptions[index].isAcknowledged.toggle()
    }

    func consumeFirstAddSubscriptionExperience() -> Bool {
        let hasShownFirstAddSubscriptionPage = defaults.bool(forKey: hasShownFirstAddSubscriptionPageKey)

        if hasShownFirstAddSubscriptionPage {
            return false
        }

        defaults.set(true, forKey: hasShownFirstAddSubscriptionPageKey)
        return true
    }

    private func persistSelectedCurrency() {
        defaults.set(selectedCurrency?.rawValue, forKey: selectedCurrencyKey)
    }

    private func persistSavedSubscriptions() {
        guard let encodedSubscriptions = try? JSONEncoder().encode(savedSubscriptions) else { return }
        defaults.set(encodedSubscriptions, forKey: savedSubscriptionsKey)
    }
}
