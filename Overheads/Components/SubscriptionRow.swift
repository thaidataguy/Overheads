//
//  SubscriptionRowView.swift
//  Overheads
//
//  Created by Tanagarn Ploychinda on 4/22/26.
//

import SwiftUI
import UIKit

struct SubscriptionRowView: View {
    let subscription: Subscription
    let isAcknowledged: Bool

    var body: some View {
        HStack(spacing: 14) {
            subscriptionIcon

            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(subscription.name)
                        .font(SubscriptionRowFont.body(15))
                        .foregroundStyle(Color.subscriptionRowText)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(amountText)
                            .font(SubscriptionRowFont.body(15))
                            .foregroundStyle(Color.subscriptionRowText)

                        Text(frequencyText)
                            .font(SubscriptionRowFont.body(15))
                            .foregroundStyle(Color.subscriptionRowText)
                    }
                    .lineLimit(1)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 6) {
                    Text("Next bill date")
                        .font(SubscriptionRowFont.body(12))
                        .foregroundStyle(Color.subscriptionRowText)

                    Text(nextChargeDateText)
                        .font(SubscriptionRowFont.body(15))
                        .foregroundStyle(Color.subscriptionRowText)
                        .lineLimit(1)
                }

                if showsAcknowledgementIndicator {
                    Image(systemName: isAcknowledged ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(Color.subscriptionRowText)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.58))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.65), lineWidth: 0.8)
        )
    }

    private var subscriptionIcon: some View {
        Group {
            if let iconImage {
                iconImage
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "app.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(11)
                    .foregroundStyle(Color.subscriptionRowText.opacity(0.82))
                    .background(Color.white.opacity(0.55))
            }
        }
        .frame(width: 52, height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var iconImage: Image? {
        guard let iconName = subscription.icon, !iconName.isEmpty else { return nil }

        if UIImage(named: iconName) != nil {
            return Image(iconName)
        }

        if UIImage(systemName: iconName) != nil {
            return Image(systemName: iconName)
        }

        return nil
    }

    private var amountText: String {
        guard let amount = subscription.amount else { return "--" }
        return amount.formatted(.number.precision(.fractionLength(2)))
    }

    private var frequencyText: String {
        guard let frequency = subscription.frequency else { return "/ --" }
        return "/ \(abbreviatedFrequency(for: frequency))"
    }

    private var nextChargeDateText: String {
        guard let nextChargeDate = subscription.nextChargeDate else { return "--" }
        return DateUtils.formattedSubscriptionDate(nextChargeDate)
    }

    private var showsAcknowledgementIndicator: Bool {
        guard let nextChargeDate = subscription.nextChargeDate else { return false }
        return DateUtils.isWithinNextSevenDays(nextChargeDate)
    }

    private func abbreviatedFrequency(for frequency: Frequency) -> String {
        switch frequency {
        case .weekly:
            return "wk"
        case .monthly:
            return "mo"
        case .quarterly:
            return "qtr"
        case .annually:
            return "yr"
        }
    }
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

private extension Color {
    static let subscriptionRowText = Color(red: 97 / 255, green: 97 / 255, blue: 97 / 255)
}

struct SubscriptionRowView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 253 / 255, green: 221 / 255, blue: 197 / 255)
                .ignoresSafeArea()

            SubscriptionRowView(
                subscription: Subscription(
                    name: "Netflix",
                    icon: "play.rectangle.fill",
                    amount: 9.99,
                    frequency: .monthly,
                    nextChargeDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())
                ),
                isAcknowledged: false
            )
            .padding(20)
        }
    }
}
