//
//  SubscriptionRowView.swift
//  Overheads
//
//  Created by Tanagarn Ploychinda on 4/22/26.
//

import SwiftUI

struct SubscriptionRowView: View {
    @EnvironmentObject private var subscriptionStore: SubscriptionStore
    @Environment(\.colorScheme) private var colorScheme
    let subscription: Subscription
    let isAcknowledged: Bool
    let onAcknowledgementToggle: (() -> Void)?

    var body: some View {
        HStack(spacing: 8) {
            subscriptionIcon

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(subscription.name)
                        .font(SubscriptionRowFont.body(15))
                        .foregroundStyle(palette.primaryText)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .layoutPriority(2)

                    HStack(spacing: 0) {
                        Text(amountText)
                            .font(SubscriptionRowFont.body(15))
                            .foregroundStyle(palette.secondaryText)

                        Text(frequencyText)
                            .font(SubscriptionRowFont.body(15))
                            .foregroundStyle(palette.secondaryText)
                    }
                    .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("Next bill date")
                            .font(SubscriptionRowFont.body(12))
                            .foregroundStyle(palette.mutedText)

                        Text(nextChargeDateText)
                            .font(SubscriptionRowFont.body(15))
                            .foregroundStyle(palette.primaryText)
                            .lineLimit(1)
                    }

                    if showsAcknowledgementIndicator {
                        Button {
                            onAcknowledgementToggle?()
                        } label: {
                            Image(systemName: isAcknowledged ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22, weight: .regular))
                                .foregroundStyle(isAcknowledged ? palette.sea : palette.sun)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(.leading, 10)
        .padding(.trailing, 16)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            OverheadsRoundedPanelBackground(
                palette: palette,
                cornerRadius: 24,
                emphasis: 0.75
            )
        }
    }

    private var subscriptionIcon: some View {
        SubscriptionIconView(
            customization: subscription.iconCustomization,
            side: SubscriptionIconMetrics.containerSide,
            symbolSide: SubscriptionIconMetrics.symbolSide
        )
    }

    private var amountText: String {
        guard let amount = subscription.amount else { return "--" }
        let currencySymbol = subscriptionStore.selectedCurrency?.symbol ?? "$"

        if subscriptionStore.selectedCurrency?.showsDecimalAmounts == false {
            return "\(currencySymbol)\(amount.formatted(.number.precision(.fractionLength(0))))"
        }

        return "\(currencySymbol)\(amount.formatted(.number.precision(.fractionLength(2))))"
    }

    private var frequencyText: String {
        guard let frequency = subscription.frequency else { return "/--" }
        return "/\(abbreviatedFrequency(for: frequency))"
    }

    private var nextChargeDateText: String {
        guard let nextChargeDate = subscription.nextChargeDate else { return "--" }
        return DateUtils.formattedSubscriptionDate(nextChargeDate)
    }

    private var showsAcknowledgementIndicator: Bool {
        guard let nextChargeDate = subscription.nextChargeDate else { return false }
        return DateUtils.isWithinNextSevenDays(nextChargeDate)
    }

    private var palette: OverheadsTheme {
        OverheadsTheme.resolve(for: colorScheme)
    }

    private func abbreviatedFrequency(for frequency: Frequency) -> String {
        switch frequency {
        case .weekly:
            return "wk"
        case .monthly:
            return "mo"
        case .quarterly:
            return "qr"
        case .annually:
            return "yr"
        }
    }
}

private enum SubscriptionIconMetrics {
    static let symbolSide: CGFloat = 30
    static let containerSide: CGFloat = 42
}

private enum SubscriptionRowFont {
    static func body(_ size: CGFloat) -> Font {
        font(
            names: ["PlusJakartaSans-Regular", "Plus Jakarta Sans"],
            size: size,
            fallback: .system(size: size, weight: .regular, design: .rounded)
        )
    }

    private static func font(names: [String], size: CGFloat, fallback: Font) -> Font {
        for name in names where UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }

        return fallback
    }
}

struct SubscriptionRowView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            OverheadsScreenBackground(palette: .resolve(for: .light))

            SubscriptionRowView(
                subscription: Subscription(
                    name: "Netflix",
                    amount: 9.99,
                    frequency: .monthly,
                    nextChargeDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
                    isAcknowledged: false
                ),
                isAcknowledged: false,
                onAcknowledgementToggle: nil
            )
            .environmentObject(SubscriptionStore())
            .padding(20)
        }
    }
}
