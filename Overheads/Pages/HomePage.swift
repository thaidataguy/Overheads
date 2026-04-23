//
//  HomePage.swift
//  Overheads
//
//  Created by Tanagarn Ploychinda on 4/22/26.
//

import SwiftUI
import UIKit

struct HomePage: View {
    @EnvironmentObject private var subscriptionStore: SubscriptionStore
    @Environment(\.colorScheme) private var colorScheme

    @State private var showsAddSubscriptionPage = false
    @State private var showsSettingsPage = false
    @State private var selectedSubscriptionToEdit: Subscription?

    var body: some View {
        ZStack(alignment: .bottom) {
            OverheadsScreenBackground(palette: palette)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                        .padding(.top, 30)
                        .padding(.horizontal, 30)

                    subscriptionListSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 132)
                }
            }

            homeButtons
        }
        .fullScreenCover(isPresented: $showsAddSubscriptionPage) {
            AddSubscriptionPage(showsFirstTimeTitle: false)
                .environmentObject(subscriptionStore)
        }
        .fullScreenCover(isPresented: $showsSettingsPage) {
            SettingsPage()
                .environmentObject(subscriptionStore)
        }
        .fullScreenCover(item: $selectedSubscriptionToEdit) { subscription in
            AddSubscriptionPage(showsFirstTimeTitle: false, subscriptionToEdit: subscription)
                .environmentObject(subscriptionStore)
        }
    }

    private var palette: OverheadsTheme {
        OverheadsTheme.resolve(for: colorScheme)
    }

    private var currencySymbol: String {
        subscriptionStore.selectedCurrency?.symbol ?? "$"
    }

    private var monthlyTotal: Double {
        subscriptionStore.savedSubscriptions.reduce(0) { partialResult, subscription in
            guard
                let amount = subscription.amount,
                let frequency = subscription.frequency
            else {
                return partialResult
            }

            return partialResult + monthlyEquivalent(for: amount, frequency: frequency)
        }
    }

    private var dailyTotal: Double {
        monthlyTotal / 30
    }

    private var yearlyTotal: Double {
        monthlyTotal * 12
    }

    private var upcomingUnacknowledgedCount: Int {
        subscriptionStore.savedSubscriptions.filter { subscription in
            guard let nextChargeDate = subscription.nextChargeDate else { return false }
            return DateUtils.isWithinNextSevenDays(nextChargeDate) && !subscription.isAcknowledged
        }.count
    }

    private var headerSection: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Overheads")
                .font(HomeFont.extraBold(48))
                .foregroundStyle(palette.primaryText)

            Spacer()
                .frame(height: 10)

            HStack(spacing: 10) {
                Image(systemName: acknowledgementSymbolName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(palette.cream.opacity(0.96))

                Text(acknowledgementText)
                    .font(HomeFont.body(15))
                    .foregroundStyle(palette.cream.opacity(0.96))
            }
            .padding(.horizontal, 24)
            .frame(height: 44)
            .background {
                OverheadsCapsuleBackground(
                    palette: palette,
                    colors: acknowledgementStatusColors
                )
                .shadow(color: acknowledgementStatusShadowColor, radius: 26, y: 14)
            }

            Spacer()
                .frame(height: 18)

            VStack(spacing: 10) {
                Text("\(currencySymbol)\(formattedAmount(monthlyTotal))/month")
                    .font(HomeFont.medium(40))
                    .foregroundStyle(palette.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                HStack {
                    Text("\(currencySymbol)\(formattedAmount(dailyTotal))/day")
                        .font(HomeFont.body(15))
                        .foregroundStyle(palette.secondaryText)

                    Spacer()

                    Text("\(currencySymbol)\(formattedAmount(yearlyTotal))/year")
                        .font(HomeFont.body(15))
                        .foregroundStyle(palette.secondaryText)
                }
                .frame(maxWidth: 255)
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 22)
            .frame(maxWidth: .infinity)
            .background {
                OverheadsRoundedPanelBackground(
                    palette: palette,
                    cornerRadius: 34,
                    emphasis: 1.1
                )
            }
            .padding(.horizontal, 2)
        }
    }

    private var subscriptionListSection: some View {
        VStack(spacing: 8) {
            ForEach(sortedSavedSubscriptions) { subscription in
                SubscriptionRowView(
                    subscription: subscription,
                    isAcknowledged: subscription.isAcknowledged,
                    onAcknowledgementToggle: {
                        subscriptionStore.toggleAcknowledgement(for: subscription.id)
                    }
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedSubscriptionToEdit = subscription
                }
            }
        }
    }

    private var homeButtons: some View {
        HStack(spacing: 16) {
            homeButton(
                systemName: "gearshape.fill",
                colors: palette.secondaryActionColors
            ) {
                showsSettingsPage = true
            }

            Spacer(minLength: 0)

            homeButton(
                systemName: "plus",
                colors: palette.primaryActionColors
            ) {
                showsAddSubscriptionPage = true
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 34)
    }

    private func homeButton(
        systemName: String,
        colors: [Color],
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(palette.actionTextOnAccent)
                .frame(width: 68, height: 68)
                .background {
                    OverheadsCircleBackground(
                        palette: palette,
                        colors: colors
                    )
                }
        }
        .buttonStyle(.plain)
    }

    private var sortedSavedSubscriptions: [Subscription] {
        subscriptionStore.savedSubscriptions.sorted { lhs, rhs in
            switch (lhs.nextChargeDate, rhs.nextChargeDate) {
            case let (lhsDate?, rhsDate?):
                return lhsDate < rhsDate
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        }
    }

    private var acknowledgementText: String {
        let count = upcomingUnacknowledgedCount
        guard count > 0 else { return "Everything accounted for" }
        let itemLabel = count == 1 ? "item" : "items"
        return "\(count) \(itemLabel) not acknowledged"
    }

    private var acknowledgementSymbolName: String {
        upcomingUnacknowledgedCount == 0 ? "checkmark" : "xmark"
    }

    private var acknowledgementStatusColors: [Color] {
        if upcomingUnacknowledgedCount == 0 {
            return palette.settledStatusColors
        }

        return palette.attentionStatusColors
    }

    private var acknowledgementStatusShadowColor: Color {
        upcomingUnacknowledgedCount == 0 ? palette.sea.opacity(0.26) : palette.sun.opacity(0.24)
    }

    private func monthlyEquivalent(for amount: Double, frequency: Frequency) -> Double {
        switch frequency {
        case .weekly:
            return amount * 52 / 12
        case .monthly:
            return amount
        case .quarterly:
            return amount / 3
        case .annually:
            return amount / 12
        }
    }

    private func formattedAmount(_ amount: Double) -> String {
        if subscriptionStore.selectedCurrency?.showsDecimalAmounts == false {
            return amount.formatted(.number.precision(.fractionLength(0)))
        }

        return amount.formatted(.number.precision(.fractionLength(0...2)))
    }
}

private enum HomeFont {
    static func extraBold(_ size: CGFloat) -> Font {
        font(
            names: ["AbhayaLibre-ExtraBold", "Abhaya Libre ExtraBold"],
            size: size,
            fallback: .system(size: size, weight: .bold, design: .serif)
        )
    }

    static func medium(_ size: CGFloat) -> Font {
        font(
            names: ["AbhayaLibre-Medium", "Abhaya Libre Medium"],
            size: size,
            fallback: .system(size: size, weight: .medium, design: .serif)
        )
    }

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

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(SubscriptionStore())
    }
}
