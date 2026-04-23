import SwiftUI
import UIKit

struct WelcomePage: View {
    @EnvironmentObject private var subscriptionStore: SubscriptionStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var showsCurrencyPicker = false
    @State private var showsAddSubscriptionPage = false
    @State private var showsFirstAddSubscriptionTitle = false

    var body: some View {
        ZStack {
            OverheadsScreenBackground(palette: palette)

            VStack(spacing: 0) {
                Spacer(minLength: 120)

                Text("Welcome to\nOverheads.")
                    .font(WelcomeFont.extraBold(40))
                    .foregroundStyle(palette.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(10)

                Spacer(minLength: 72)

                Text("Nothing forgotten.\nNothing unexpected.")
                    .font(WelcomeFont.regular(32))
                    .foregroundStyle(palette.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(12)

                Spacer(minLength: 92)

                Text("Know before you’re charged.")
                    .font(WelcomeFont.medium(24))
                    .foregroundStyle(palette.mutedText)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                showsCurrencyPicker = true
            } label: {
                Text(buttonTitle)
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundStyle(palette.actionTextOnAccent)
                    .padding(.horizontal, 22)
                    .frame(height: 38)
                    .background {
                        OverheadsCapsuleBackground(
                            palette: palette,
                            colors: palette.primaryActionColors
                        )
                    }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 34)
        }
        .sheet(isPresented: $showsCurrencyPicker) {
            CurrencyPickerSheet(selectedCurrency: currencyBinding)
                .presentationDetents([.height(248)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.clear)
        }
        .fullScreenCover(isPresented: $showsAddSubscriptionPage) {
            AddSubscriptionPage(showsFirstTimeTitle: showsFirstAddSubscriptionTitle)
                .environmentObject(subscriptionStore)
        }
        .onChange(of: subscriptionStore.selectedCurrency) { _, newValue in
            guard newValue != nil else { return }

            showsFirstAddSubscriptionTitle = subscriptionStore.consumeFirstAddSubscriptionExperience()
            showsAddSubscriptionPage = true
        }
    }

    private var buttonTitle: String {
        if let selectedCurrency = subscriptionStore.selectedCurrency {
            return "Select Your Currency (\(selectedCurrency.symbol))"
        }

        return "Select Your Currency"
    }

    private var currencyBinding: Binding<SupportedCurrency?> {
        Binding(
            get: { subscriptionStore.selectedCurrency },
            set: { subscriptionStore.selectedCurrency = $0 }
        )
    }

    private var palette: OverheadsTheme {
        OverheadsTheme.resolve(for: colorScheme)
    }
}

private struct CurrencyPickerSheet: View {
    @Binding var selectedCurrency: SupportedCurrency?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            OverheadsScreenBackground(palette: palette)

            VStack(alignment: .leading, spacing: 20) {
                Text("Select Currency")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.primaryText)

                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 12) {
                        ForEach(SupportedCurrency.allCases) { currency in
                            Button {
                                selectedCurrency = currency
                                dismiss()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("\(currency.name) (\(currency.symbol))")
                                            .font(.system(size: 17, weight: .semibold))

                                        Text(currency.detail)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(palette.secondaryText)
                                    }

                                    Spacer()

                                    if selectedCurrency == currency {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundStyle(palette.sun)
                                    }
                                }
                                .foregroundStyle(palette.primaryText)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity, minHeight: 58)
                                .background {
                                    OverheadsRoundedPanelBackground(
                                        palette: palette,
                                        cornerRadius: 18,
                                        emphasis: selectedCurrency == currency ? 0.9 : 0.6
                                    )
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(selectedCurrency == currency ? palette.subduedFill : .clear)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 18)
        }
    }

    private var palette: OverheadsTheme {
        OverheadsTheme.resolve(for: colorScheme)
    }
}

private enum WelcomeFont {
    static func extraBold(_ size: CGFloat) -> Font {
        font(
            names: ["AbhayaLibre-ExtraBold", "Abhaya Libre ExtraBold"],
            size: size,
            fallback: .system(size: size, weight: .bold, design: .serif)
        )
    }

    static func regular(_ size: CGFloat) -> Font {
        font(
            names: ["AbhayaLibre-Regular", "Abhaya Libre"],
            size: size,
            fallback: .system(size: size, weight: .regular, design: .serif)
        )
    }

    static func medium(_ size: CGFloat) -> Font {
        font(
            names: ["AbhayaLibre-Medium", "Abhaya Libre Medium"],
            size: size,
            fallback: .system(size: size, weight: .medium, design: .serif)
        )
    }

    private static func font(names: [String], size: CGFloat, fallback: Font) -> Font {
        for name in names where UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }

        return fallback
    }
}

struct WelcomePage_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePage()
    }
}
