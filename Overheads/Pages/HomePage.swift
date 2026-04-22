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
    @State private var showsAddSubscriptionPage = false
    @State private var selectedSubscriptionToEdit: Subscription?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.homeBackground
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                        .padding(.top, 58)
                        .padding(.horizontal, 30)

                    subscriptionListSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 140)
                }
            }

            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button {
                showsAddSubscriptionPage = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(.black.opacity(0.9))
                    .frame(width: 78, height: 78)
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.7),
                                                .white.opacity(0.25)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .blendMode(.screen)
                            }
                            .overlay {
                                Circle()
                                    .stroke(.white.opacity(0.72), lineWidth: 0.9)
                            }
                            .shadow(color: .white.opacity(0.5), radius: 10, y: -1)
                            .shadow(color: .black.opacity(0.08), radius: 22, y: 16)
                    }
            }
            .buttonStyle(.plain)
            .padding(.trailing, 26)
            .padding(.bottom, 42)
        }
        .fullScreenCover(isPresented: $showsAddSubscriptionPage) {
            AddSubscriptionPage(showsFirstTimeTitle: false)
                .environmentObject(subscriptionStore)
        }
        .fullScreenCover(item: $selectedSubscriptionToEdit) { subscription in
            AddSubscriptionPage(showsFirstTimeTitle: false, subscriptionToEdit: subscription)
                .environmentObject(subscriptionStore)
        }
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
                .foregroundStyle(.black)

            Spacer()
                .frame(height: 30)

            HStack(spacing: 10) {
                Image(systemName: acknowledgementSymbolName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black.opacity(0.78))

                Text(acknowledgementText)
                    .font(HomeFont.body(15))
                    .foregroundStyle(.black.opacity(0.86))
            }
            .padding(.horizontal, 24)
            .frame(height: 44)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: acknowledgementStatusColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Capsule()
                            .stroke(.white.opacity(0.52), lineWidth: 0.8)
                    }
                    .shadow(color: .white.opacity(0.42), radius: 8, y: -1)
                    .shadow(color: acknowledgementStatusShadowColor, radius: 24, y: 14)
            }

            Spacer()
                .frame(height: 18)

            VStack(spacing: 10) {
                Text("\(currencySymbol)\(formattedAmount(monthlyTotal))/month")
                    .font(HomeFont.medium(40))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                HStack {
                    Text("\(currencySymbol)\(formattedAmount(dailyTotal))/day")
                        .font(HomeFont.body(15))
                        .foregroundStyle(.black.opacity(0.8))

                    Spacer()

                    Text("\(currencySymbol)\(formattedAmount(yearlyTotal))/year")
                        .font(HomeFont.body(15))
                        .foregroundStyle(.black.opacity(0.8))
                }
                .frame(maxWidth: 255)
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 22)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.72),
                                        .white.opacity(0.26)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blendMode(.screen)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(.white.opacity(0.72), lineWidth: 0.9)
                    }
                    .shadow(color: .white.opacity(0.5), radius: 10, y: -1)
                    .shadow(color: .black.opacity(0.08), radius: 22, y: 16)
                }
            .padding(.horizontal, 2)
        }
    }

    private var subscriptionListSection: some View {
        VStack(spacing: 14) {
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
            return [
                Color(red: 0.60, green: 0.89, blue: 0.49),
                Color(red: 0.44, green: 0.80, blue: 0.39)
            ]
        }

        return [
            Color(red: 1.0, green: 0.96, blue: 0.38),
            Color(red: 1.0, green: 0.93, blue: 0.28)
        ]
    }

    private var acknowledgementStatusShadowColor: Color {
        upcomingUnacknowledgedCount == 0 ? .green.opacity(0.22) : .orange.opacity(0.22)
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

private extension Color {
    static let homeBackground = Color(red: 253 / 255, green: 221 / 255, blue: 197 / 255)
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(SubscriptionStore())
    }
}
