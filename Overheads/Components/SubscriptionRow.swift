//
//  SubscriptionRowView.swift
//  Overheads
//
//  Created by Tanagarn Ploychinda on 4/22/26.
//

import SwiftUI
import UIKit

struct SubscriptionRowView: View {
    @EnvironmentObject private var subscriptionStore: SubscriptionStore
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

                VStack(alignment: .trailing, spacing: 0) {
                    Text("Next bill date")
                        .font(SubscriptionRowFont.body(12))
                        .foregroundStyle(Color.subscriptionRowText)

                    Text(nextChargeDateText)
                        .font(SubscriptionRowFont.body(15))
                        .foregroundStyle(Color.subscriptionRowText)
                        .lineLimit(1)
                }

                if showsAcknowledgementIndicator {
                    Button {
                        onAcknowledgementToggle?()
                    } label: {
                        Image(systemName: isAcknowledged ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(isAcknowledged ? Color.subscriptionAcknowledged : Color.subscriptionRowText)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.leading, 10)
        .padding(.trailing, 16)
        .padding(.vertical, 16)
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
            if let emojiIcon {
                Text(emojiIcon)
                    .font(.system(size: 26))
                    .frame(width: SubscriptionIconMetrics.symbolSide, height: SubscriptionIconMetrics.symbolSide)
            } else if let iconImage {
                iconImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: SubscriptionIconMetrics.symbolSide, height: SubscriptionIconMetrics.symbolSide)
            } else {
                Image(systemName: "app.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: SubscriptionIconMetrics.symbolSide, height: SubscriptionIconMetrics.symbolSide)
                    .foregroundStyle(Color.subscriptionRowText.opacity(0.82))
            }
        }
        .frame(width: SubscriptionIconMetrics.containerWidth, alignment: .center)
    }

    private var emojiIcon: String? {
        let resolvedIconName = subscription.icon ?? Subscription.iconName(for: subscription.name)
        guard let iconName = resolvedIconName, !iconName.isEmpty else { return nil }
        guard UIImage(systemName: iconName) == nil else { return nil }
        guard bundledIcon(named: iconName) == nil else { return nil }
        guard UIImage(named: iconName) == nil else { return nil }
        return iconName
    }

    private var iconImage: Image? {
        let resolvedIconName = subscription.icon ?? Subscription.iconName(for: subscription.name)
        guard let iconName = resolvedIconName, !iconName.isEmpty else { return nil }

        if let bundledImage = bundledIcon(named: iconName) {
            return Image(uiImage: bundledImage)
        }

        if UIImage(named: iconName) != nil {
            return Image(iconName)
        }

        if UIImage(systemName: iconName) != nil {
            return Image(systemName: iconName)
        }

        return nil
    }

    private func bundledIcon(named iconName: String) -> UIImage? {
        let nsIconName = iconName as NSString
        let resourceName = nsIconName.deletingPathExtension
        let resourceExtension = nsIconName.pathExtension.isEmpty ? nil : nsIconName.pathExtension

        if let image = UIImage(named: "Icons/\(iconName)") {
            return image
        }

        if let image = UIImage(named: iconName) {
            return image
        }

        let candidateURLs = [
            Bundle.main.url(
                forResource: resourceName,
                withExtension: resourceExtension,
                subdirectory: "Icons"
            ),
            Bundle.main.url(
                forResource: resourceName,
                withExtension: resourceExtension
            )
        ]

        for candidateURL in candidateURLs {
            guard let url = candidateURL else { continue }
            guard let data = try? Data(contentsOf: url) else { continue }
            guard let image = UIImage(data: data) else { continue }
            return image
        }

        return nil
    }

    private var amountText: String {
        guard let amount = subscription.amount else { return "--" }
        if subscriptionStore.selectedCurrency?.showsDecimalAmounts == false {
            return amount.formatted(.number.precision(.fractionLength(0)))
        }

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
            return "qr"
        case .annually:
            return "yr"
        }
    }
}

private enum SubscriptionIconMetrics {
    static let symbolSide: CGFloat = 30
    static let containerWidth: CGFloat = 42
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
    static let subscriptionAcknowledged = Color(red: 46 / 255, green: 184 / 255, blue: 92 / 255)
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
