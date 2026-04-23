import SwiftUI
import UIKit

struct SettingsPage: View {
    @EnvironmentObject private var subscriptionStore: SubscriptionStore
    @Environment(\.dismiss) private var dismiss
    @AppStorage("app_theme_preference") private var appThemePreference = AppThemePreference.system.rawValue

    @State private var showsCurrencyPicker = false
    @State private var showsThemePicker = false
    @State private var showsSignInAlert = false
    @State private var systemColorScheme = ColorScheme.light

    var body: some View {
        ZStack {
            OverheadsScreenBackground(palette: palette)

            VStack(spacing: 30) {
                header

                VStack(spacing: 12) {
                    settingsRow(
                        title: "Change Currency",
                        value: currencyLabel,
                        systemName: "dollarsign.arrow.circlepath",
                        accentColors: palette.primaryActionColors,
                        action: {
                            showsCurrencyPicker = true
                        }
                    )

                    settingsRow(
                        title: "Change Theme",
                        value: selectedTheme.displayName,
                        systemName: "circle.lefthalf.filled",
                        accentColors: palette.secondaryActionColors,
                        action: {
                            showsThemePicker = true
                        }
                    )

                    settingsRow(
                        title: "Sign In",
                        value: "Not Signed In",
                        systemName: "person.crop.circle.badge.plus",
                        accentColors: palette.destructiveActionColors,
                        action: {
                            showsSignInAlert = true
                        }
                    )
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 26)
            .padding(.bottom, 36)
        }
        .sheet(isPresented: $showsCurrencyPicker) {
            SettingsCurrencyPickerSheet(selectedCurrency: currencyBinding)
                .presentationDetents([.height(248)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.clear)
        }
        .sheet(isPresented: $showsThemePicker) {
            ThemePickerSheet(selectedTheme: themeBinding)
                .presentationDetents([.height(260)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.clear)
        }
        .alert("Sign In", isPresented: $showsSignInAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Sign in is not connected yet.")
        }
        .preferredColorScheme(displayedColorScheme)
        .overlay(alignment: .topLeading) {
            SystemColorSchemeReader(colorScheme: $systemColorScheme)
                .frame(width: 0, height: 0)
        }
    }

    private var palette: OverheadsTheme {
        OverheadsTheme.resolve(for: displayedColorScheme)
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(palette.actionTextOnSecondary)
                    .frame(width: 44, height: 44)
                    .background {
                        OverheadsCircleBackground(
                            palette: palette,
                            colors: palette.secondaryActionColors
                        )
                    }
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Settings")
                .font(SettingsFont.title(34))
                .foregroundStyle(palette.primaryText)

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
    }

    private func settingsRow(
        title: String,
        value: String,
        systemName: String,
        accentColors: [Color],
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemName)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(palette.actionTextOnSecondary)
                    .frame(width: 38, height: 38)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: accentColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                Text(title)
                    .font(SettingsFont.body(18))
                    .foregroundStyle(palette.primaryText)

                Spacer(minLength: 12)

                Text(value)
                    .font(SettingsFont.detail(15))
                    .foregroundStyle(palette.secondaryText)
                    .lineLimit(1)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(palette.mutedText)
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: 74)
            .background {
                OverheadsRoundedPanelBackground(
                    palette: palette,
                    cornerRadius: 24,
                    emphasis: 0.85
                )
            }
        }
        .buttonStyle(.plain)
    }

    private var currencyBinding: Binding<SupportedCurrency?> {
        Binding(
            get: { subscriptionStore.selectedCurrency },
            set: { subscriptionStore.selectedCurrency = $0 }
        )
    }

    private var themeBinding: Binding<AppThemePreference> {
        Binding(
            get: { selectedTheme },
            set: { appThemePreference = $0.rawValue }
        )
    }

    private var currencyLabel: String {
        if let selectedCurrency = subscriptionStore.selectedCurrency {
            return "\(selectedCurrency.symbol) \(selectedCurrency.detail)"
        }

        return "Not Set"
    }

    private var selectedTheme: AppThemePreference {
        AppThemePreference(rawValue: appThemePreference) ?? .system
    }

    private var displayedColorScheme: ColorScheme {
        selectedTheme.colorScheme ?? systemColorScheme
    }
}

private struct SettingsCurrencyPickerSheet: View {
    @Binding var selectedCurrency: SupportedCurrency?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            OverheadsScreenBackground(palette: palette)

            VStack(alignment: .leading, spacing: 20) {
                Text("Change Currency")
                    .font(SettingsFont.sheetTitle(22))
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
                                            .font(SettingsFont.bodySemibold(17))

                                        Text(currency.detail)
                                            .font(SettingsFont.detail(13))
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

private struct ThemePickerSheet: View {
    @Binding var selectedTheme: AppThemePreference
    @Environment(\.dismiss) private var dismiss
    @State private var systemColorScheme = ColorScheme.light

    var body: some View {
        NavigationStack {
            ZStack {
                OverheadsScreenBackground(palette: palette)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(AppThemePreference.allCases) { theme in
                            Button {
                                selectedTheme = theme
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    Text(theme.displayName)
                                        .font(SettingsFont.bodySemibold(17))
                                        .foregroundStyle(palette.primaryText)

                                    Spacer()

                                    if selectedTheme == theme {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(palette.sun)
                                    }
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background {
                                    OverheadsRoundedPanelBackground(
                                        palette: palette,
                                        cornerRadius: 22,
                                        emphasis: selectedTheme == theme ? 0.9 : 0.6
                                    )
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .fill(selectedTheme == theme ? palette.subduedFill : .clear)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("Change Theme")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(displayedColorScheme)
        .overlay(alignment: .topLeading) {
            SystemColorSchemeReader(colorScheme: $systemColorScheme)
                .frame(width: 0, height: 0)
        }
    }

    private var palette: OverheadsTheme {
        OverheadsTheme.resolve(for: displayedColorScheme)
    }

    private var displayedColorScheme: ColorScheme {
        selectedTheme.colorScheme ?? systemColorScheme
    }
}

private struct SystemColorSchemeReader: UIViewRepresentable {
    @Binding var colorScheme: ColorScheme

    func makeUIView(context: Context) -> SystemColorSchemeView {
        let view = SystemColorSchemeView()
        view.onColorSchemeChange = { style in
            let resolvedColorScheme = style == .dark ? ColorScheme.dark : .light
            if colorScheme != resolvedColorScheme {
                colorScheme = resolvedColorScheme
            }
        }
        return view
    }

    func updateUIView(_ uiView: SystemColorSchemeView, context: Context) {
        uiView.onColorSchemeChange = { style in
            let resolvedColorScheme = style == .dark ? ColorScheme.dark : .light
            if colorScheme != resolvedColorScheme {
                colorScheme = resolvedColorScheme
            }
        }

        let resolvedColorScheme = uiView.resolvedColorScheme
        if colorScheme != resolvedColorScheme {
            DispatchQueue.main.async {
                colorScheme = resolvedColorScheme
            }
        }
    }
}

private final class SystemColorSchemeView: UIView {
    var onColorSchemeChange: ((UIUserInterfaceStyle) -> Void)?

    var resolvedColorScheme: ColorScheme {
        traitCollection.userInterfaceStyle == .dark ? .dark : .light
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        notifyColorSchemeChange()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else {
            return
        }

        notifyColorSchemeChange()
    }

    private func notifyColorSchemeChange() {
        onColorSchemeChange?(traitCollection.userInterfaceStyle)
    }
}

private enum SettingsFont {
    static func title(_ size: CGFloat) -> Font {
        font(
            names: ["AbhayaLibre-ExtraBold", "Abhaya Libre ExtraBold"],
            size: size,
            fallback: .system(size: size, weight: .bold, design: .serif)
        )
    }

    static func sheetTitle(_ size: CGFloat) -> Font {
        font(
            names: ["PlusJakartaSans-SemiBold", "Plus Jakarta Sans SemiBold"],
            size: size,
            fallback: .system(size: size, weight: .semibold, design: .rounded)
        )
    }

    static func body(_ size: CGFloat) -> Font {
        font(
            names: ["PlusJakartaSans-Regular", "Plus Jakarta Sans"],
            size: size,
            fallback: .system(size: size, weight: .regular, design: .rounded)
        )
    }

    static func bodySemibold(_ size: CGFloat) -> Font {
        font(
            names: ["PlusJakartaSans-SemiBold", "Plus Jakarta Sans SemiBold"],
            size: size,
            fallback: .system(size: size, weight: .semibold, design: .rounded)
        )
    }

    static func detail(_ size: CGFloat) -> Font {
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

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage()
            .environmentObject(SubscriptionStore())
    }
}
