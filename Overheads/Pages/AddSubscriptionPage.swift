//
//  AddSubscriptionView.swift
//  Overheads
//
//  Created by Tanagarn Ploychinda on 4/22/26.
//

import SwiftUI
import UIKit

struct AddSubscriptionPage: View {
    @EnvironmentObject private var subscriptionStore: SubscriptionStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    enum Field: Hashable {
        case name
        case amount
    }

    let showsFirstTimeTitle: Bool
    let subscriptionToEdit: Subscription?
    @State private var name = ""
    @State private var uploadedIconData: Data?
    @State private var selectedIconScale = 1.0
    @State private var amount = ""
    @State private var selectedFrequency: Frequency?
    @State private var nextChargeDate = Date()
    @State private var hasSelectedNextChargeDate = false
    @State private var showsFrequencyPicker = false
    @State private var showsNextChargeDatePicker = false
    @State private var showsIncompleteDataAlert = false
    @FocusState private var focusedField: Field?

    init(showsFirstTimeTitle: Bool, subscriptionToEdit: Subscription? = nil) {
        self.showsFirstTimeTitle = showsFirstTimeTitle
        self.subscriptionToEdit = subscriptionToEdit
        _name = State(initialValue: subscriptionToEdit?.name ?? "")
        _uploadedIconData = State(initialValue: subscriptionToEdit?.iconCustomization?.uploadedImageData)
        _selectedIconScale = State(initialValue: subscriptionToEdit?.iconCustomization?.scale ?? 1.0)
        _amount = State(initialValue: Self.formattedAmountText(for: subscriptionToEdit?.amount))
        _selectedFrequency = State(initialValue: subscriptionToEdit?.frequency)
        _nextChargeDate = State(initialValue: subscriptionToEdit?.nextChargeDate ?? Date())
        _hasSelectedNextChargeDate = State(initialValue: subscriptionToEdit?.nextChargeDate != nil)
    }

    var body: some View {
        ZStack {
            OverheadsScreenBackground(palette: palette)
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }

            VStack {
                Spacer(minLength: 0)

                VStack(spacing: 28) {
                    Text(pageTitle)
                        .font(AddSubscriptionFont.title(34))
                        .foregroundStyle(palette.primaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    IconCustomizationCard(uploadedImageData: $uploadedIconData, scale: $selectedIconScale)
                        .padding(.horizontal, 12)

                    VStack(spacing: 16) {
                        UnderlineInputField(
                            title: "Name",
                            text: $name,
                            field: .name,
                            focusedField: $focusedField,
                            keyboardType: .default,
                            textInputAutocapitalization: .words
                        )
                        UnderlineInputField(
                            title: "Amount",
                            text: $amount,
                            field: .amount,
                            focusedField: $focusedField,
                            keyboardType: .decimalPad,
                            textInputAutocapitalization: .never
                        )
                        UnderlinePickerField(
                            title: "Frequency",
                            selectedValue: selectedFrequency?.displayName ?? "",
                            action: {
                                focusedField = nil
                                showsFrequencyPicker = true
                            }
                        )
                        UnderlineDatePickerField(
                            title: "Next Charge Date",
                            date: $nextChargeDate,
                            hasSelectedDate: $hasSelectedNextChargeDate,
                            action: {
                                focusedField = nil
                                showsNextChargeDatePicker = true
                            }
                        )
                    }
                    .padding(.horizontal, 38)

                    actionButtons
                        .padding(.top, 12)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 30)
                .background {
                    OverheadsRoundedPanelBackground(
                        palette: palette,
                        cornerRadius: 36,
                        emphasis: 1.05
                    )
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $showsFrequencyPicker) {
            FrequencyPickerSheet(selectedFrequency: $selectedFrequency)
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.clear)
        }
        .sheet(isPresented: $showsNextChargeDatePicker) {
            NextChargeDatePickerSheet(
                selectedDate: $nextChargeDate,
                hasSelectedDate: $hasSelectedNextChargeDate
            )
            .presentationDetents([.height(440)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
            .presentationBackground(.clear)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Done") {
                    focusedField = nil
                }
                .font(AddSubscriptionFont.bodySemibold(16))
                .foregroundStyle(palette.primaryText)
            }
        }
        .alert("Data field is incomplete", isPresented: $showsIncompleteDataAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please fill in all 4 fields before confirming.")
        }
    }

    private var pageTitle: String {
        if subscriptionToEdit != nil {
            return "Edit Recurring Payment"
        }

        if showsFirstTimeTitle {
            return "Add Your First\nRecurring Payment"
        }

        return "Add Recurring Payment"
    }

    private func confirmSubscription() {
        focusedField = nil

        guard
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let parsedAmount = parsedAmount,
            let selectedFrequency,
            hasSelectedNextChargeDate
        else {
            showsIncompleteDataAlert = true
            return
        }

        if let subscriptionToEdit {
            subscriptionStore.updateSubscription(
                id: subscriptionToEdit.id,
                name: name,
                iconCustomization: effectiveIconCustomization,
                amount: parsedAmount,
                frequency: selectedFrequency,
                nextChargeDate: nextChargeDate
            )
        } else {
            subscriptionStore.addSubscription(
                name: name,
                iconCustomization: effectiveIconCustomization,
                amount: parsedAmount,
                frequency: selectedFrequency,
                nextChargeDate: nextChargeDate
            )
        }

        dismiss()
    }

    private func deleteSubscription() {
        guard let subscriptionToEdit else { return }
        subscriptionStore.deleteSubscription(id: subscriptionToEdit.id)
        dismiss()
    }

    private var parsedAmount: Double? {
        let trimmedAmount = amount.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAmount.isEmpty else { return nil }

        let normalizedAmount = trimmedAmount.replacingOccurrences(of: ",", with: "")
        return Double(normalizedAmount)
    }

    private var effectiveIconCustomization: Subscription.IconCustomization? {
        let customization = Subscription.IconCustomization(
            uploadedImageData: uploadedIconData,
            scale: selectedIconScale
        )

        return customization.isModified ? customization : nil
    }

    private var palette: OverheadsTheme {
        OverheadsTheme.resolve(for: colorScheme)
    }

    private var actionButtons: some View {
        HStack(spacing: 14) {
            if let subscriptionToEdit {
                Button {
                    deleteSubscription()
                } label: {
                    actionButtonLabel(
                        title: "Delete",
                        textColor: palette.actionTextOnAccent,
                        fillColors: palette.destructiveActionColors,
                        width: 138
                    )
                }
                .buttonStyle(.plain)
            } else if !showsFirstTimeTitle {
                Button {
                    dismiss()
                } label: {
                    actionButtonLabel(
                        title: "Back",
                        textColor: palette.actionTextOnSecondary,
                        fillColors: palette.secondaryActionColors,
                        width: 96
                    )
                }
                .buttonStyle(.plain)
            }

            Button {
                confirmSubscription()
            } label: {
                actionButtonLabel(
                    title: "Confirm",
                    textColor: palette.actionTextOnAccent,
                    fillColors: palette.primaryActionColors,
                    width: subscriptionToEdit != nil ? 138 : 124
                )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    private func actionButtonLabel(
        title: String,
        textColor: Color,
        fillColors: [Color],
        width: CGFloat
    ) -> some View {
        Text(title)
            .font(AddSubscriptionFont.bodySemibold(18))
            .foregroundStyle(textColor)
            .frame(width: width, height: 46)
            .background {
                OverheadsCapsuleBackground(
                    palette: palette,
                    colors: fillColors
                )
            }
    }

    private static func formattedAmountText(for amount: Double?) -> String {
        guard let amount else { return "" }
        return amount.formatted(.number.precision(.fractionLength(0...2)))
    }
}

private struct FrequencyPickerSheet: View {
    @Binding var selectedFrequency: Frequency?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                OverheadsScreenBackground(palette: palette)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(Frequency.allCases) { frequency in
                            Button {
                                selectedFrequency = frequency
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    Text(frequency.displayName)
                                        .font(AddSubscriptionFont.bodySemibold(17))
                                        .foregroundStyle(palette.primaryText)

                                    Spacer()

                                    if selectedFrequency == frequency {
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
                                        emphasis: selectedFrequency == frequency ? 0.9 : 0.6
                                    )
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .fill(selectedFrequency == frequency ? palette.subduedFill : .clear)
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
            .navigationTitle("Select Frequency")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var palette: OverheadsTheme {
        OverheadsTheme.resolve(for: colorScheme)
    }
}

private struct UnderlineDatePickerField: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    @Binding var date: Date
    @Binding var hasSelectedDate: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 10) {
                    Text(displayText)
                        .font(AddSubscriptionFont.body(18))
                        .foregroundStyle(hasSelectedDate ? palette.primaryText : palette.placeholderText)

                    Spacer()

                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(palette.placeholderText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(palette.divider)
                .frame(height: 1)
        }
    }

    private var displayText: String {
        guard hasSelectedDate else { return title }
        return AddSubscriptionDateFormatter.display.string(from: date)
    }

    private var palette: OverheadsTheme {
        OverheadsTheme.resolve(for: colorScheme)
    }
}

private struct UnderlinePickerField: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let selectedValue: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 10) {
                    Text(displayText)
                        .font(AddSubscriptionFont.body(18))
                        .foregroundStyle(selectedValue.isEmpty ? palette.placeholderText : palette.primaryText)

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(palette.placeholderText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(palette.divider)
                .frame(height: 1)
        }
    }

    private var displayText: String {
        selectedValue.isEmpty ? title : selectedValue
    }

    private var palette: OverheadsTheme {
        OverheadsTheme.resolve(for: colorScheme)
    }
}

private struct NextChargeDatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var hasSelectedDate: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var hasDismissedAfterSelection = false

    var body: some View {
        NavigationStack {
            ZStack {
                OverheadsScreenBackground(palette: palette)

                VStack(spacing: 20) {
                    DatePicker(
                        "Next Charge Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .tint(palette.sun)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedDate) { _, _ in
                guard !hasDismissedAfterSelection else { return }

                hasSelectedDate = true
                hasDismissedAfterSelection = true
                dismiss()
            }
        }
    }

    private var palette: OverheadsTheme {
        OverheadsTheme.resolve(for: colorScheme)
    }
}

private struct UnderlineInputField: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    @Binding var text: String
    let field: AddSubscriptionPage.Field
    var focusedField: FocusState<AddSubscriptionPage.Field?>.Binding
    let keyboardType: UIKeyboardType
    let textInputAutocapitalization: TextInputAutocapitalization

    var body: some View {
        VStack(spacing: 0) {
            TextField("", text: $text, prompt: placeholder)
                .textInputAutocapitalization(textInputAutocapitalization)
                .autocorrectionDisabled()
                .keyboardType(keyboardType)
                .focused(focusedField, equals: field)
                .font(AddSubscriptionFont.body(18))
                .foregroundStyle(palette.primaryText)
                .padding(.bottom, 10)

            Rectangle()
                .fill(palette.divider)
                .frame(height: 1)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField.wrappedValue = field
        }
    }

    private var placeholder: Text {
        Text(title)
            .font(AddSubscriptionFont.body(18))
            .foregroundStyle(palette.placeholderText)
    }

    private var palette: OverheadsTheme {
        OverheadsTheme.resolve(for: colorScheme)
    }
}

private enum AddSubscriptionDateFormatter {
    static let display: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

enum AddSubscriptionFont {
    static func title(_ size: CGFloat) -> Font {
        font(
            names: ["AbhayaLibre-ExtraBold", "Abhaya Libre ExtraBold"],
            size: size,
            fallback: .system(size: size, weight: .bold, design: .serif)
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

    private static func font(names: [String], size: CGFloat, fallback: Font) -> Font {
        for name in names where UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }

        return fallback
    }
}

struct AddSubscriptionPage_Previews: PreviewProvider {
    static var previews: some View {
        AddSubscriptionPage(showsFirstTimeTitle: true)
            .environmentObject(SubscriptionStore())
    }
}
