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
    enum Field: Hashable {
        case amount
    }

    let showsFirstTimeTitle: Bool
    @State private var name = ""
    @State private var amount = ""
    @State private var selectedFrequency: Frequency?
    @State private var nextChargeDate = Date()
    @State private var hasSelectedNextChargeDate = false
    @State private var showsSubscriptionPicker = false
    @State private var showsFrequencyPicker = false
    @State private var showsNextChargeDatePicker = false
    @State private var showsIncompleteDataAlert = false
    @FocusState private var focusedField: Field?

    var body: some View {
        ZStack {
            Color.addSubscriptionBackground
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }

            VStack(spacing: 0) {
                Spacer(minLength: 140)

                Text(pageTitle)
                    .font(AddSubscriptionFont.title(34))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 28)

                Button {
                } label: {
                    VStack(spacing: 10) {
                        Circle()
                            .fill(.white.opacity(0.96))
                            .frame(width: 60, height: 60)

                        Text("Upload icon")
                            .font(AddSubscriptionFont.body(18))
                            .foregroundStyle(Color.formPlaceholder)
                    }
                }
                .buttonStyle(.plain)

                Spacer(minLength: 22)

                VStack(spacing: 16) {
                    UnderlinePickerField(
                        title: "Name",
                        selectedValue: name,
                        action: {
                            focusedField = nil
                            showsSubscriptionPicker = true
                        }
                    )
                    UnderlineInputField(title: "Amount", text: $amount, field: .amount, focusedField: $focusedField)
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

                Spacer(minLength: 54)

                VStack(spacing: 6) {
                    Text("This adds $9.99/month")
                        .font(AddSubscriptionFont.body(18))
                        .foregroundStyle(.black.opacity(0.88))

                    Text("Your total becomes $1,210/month")
                        .font(AddSubscriptionFont.body(18))
                        .foregroundStyle(.black.opacity(0.88))
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 84)
                .background {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color.summaryCard)
                        .overlay {
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(.white.opacity(0.6), lineWidth: 0.8)
                        }
                        .shadow(color: .white.opacity(0.4), radius: 10, y: -1)
                        .shadow(color: .black.opacity(0.08), radius: 22, y: 14)
                }
                .padding(.horizontal, 12)

                Spacer(minLength: 28)

                Button {
                    confirmSubscription()
                } label: {
                    Text("Confirm")
                        .font(AddSubscriptionFont.bodySemibold(18))
                        .foregroundStyle(.black.opacity(0.92))
                        .padding(.horizontal, 28)
                        .frame(height: 46)
                        .background {
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(0.55),
                                                    .white.opacity(0.18)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .blendMode(.screen)
                                }
                                .overlay {
                                    Capsule()
                                        .stroke(.white.opacity(0.65), lineWidth: 0.8)
                                }
                                .shadow(color: .white.opacity(0.45), radius: 8, y: -1)
                                .shadow(color: .black.opacity(0.08), radius: 18, y: 10)
                        }
                }
                .buttonStyle(.plain)

                Spacer(minLength: 56)
            }
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showsSubscriptionPicker) {
            SubscriptionPickerSheet(selectedName: $name)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.thinMaterial)
        }
        .sheet(isPresented: $showsFrequencyPicker) {
            FrequencyPickerSheet(selectedFrequency: $selectedFrequency)
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.thinMaterial)
        }
        .sheet(isPresented: $showsNextChargeDatePicker) {
            NextChargeDatePickerSheet(
                selectedDate: $nextChargeDate,
                hasSelectedDate: $hasSelectedNextChargeDate
            )
            .presentationDetents([.height(360)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
            .presentationBackground(.thinMaterial)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Done") {
                    focusedField = nil
                }
                .font(AddSubscriptionFont.bodySemibold(16))
            }
        }
        .alert("Data field is incomplete", isPresented: $showsIncompleteDataAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please fill in all 4 fields before confirming.")
        }
    }

    private var pageTitle: String {
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

        subscriptionStore.addSubscription(
            name: name,
            amount: parsedAmount,
            frequency: selectedFrequency,
            nextChargeDate: nextChargeDate
        )
        dismiss()
    }

    private var parsedAmount: Double? {
        let trimmedAmount = amount.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAmount.isEmpty else { return nil }

        let normalizedAmount = trimmedAmount.replacingOccurrences(of: ",", with: "")
        return Double(normalizedAmount)
    }
}

private struct FrequencyPickerSheet: View {
    @Binding var selectedFrequency: Frequency?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(Frequency.allCases) { frequency in
                        Button {
                            selectedFrequency = frequency
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(frequency.displayName)
                                        .font(AddSubscriptionFont.bodySemibold(17))
                                        .foregroundStyle(.black.opacity(0.9))

                                    Text(frequency.rawValue.uppercased())
                                        .font(AddSubscriptionFont.body(14))
                                        .foregroundStyle(Color.formPlaceholder)
                                }

                                Spacer()

                                if selectedFrequency == frequency {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.black.opacity(0.75))
                                }
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(.white.opacity(0.6))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 28)
            }
            .navigationTitle("Select Frequency")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct UnderlineDatePickerField: View {
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
                        .foregroundStyle(hasSelectedDate ? .black.opacity(0.9) : Color.formPlaceholder)

                    Spacer()

                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.formPlaceholder)
                }
                .padding(.bottom, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(Color.formDivider)
                .frame(height: 1)
        }
    }

    private var displayText: String {
        guard hasSelectedDate else { return title }
        return AddSubscriptionDateFormatter.display.string(from: date)
    }
}

private struct UnderlinePickerField: View {
    let title: String
    let selectedValue: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 10) {
                    Text(displayText)
                        .font(AddSubscriptionFont.body(18))
                        .foregroundStyle(selectedValue.isEmpty ? Color.formPlaceholder : .black.opacity(0.9))

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.formPlaceholder)
                }
                .padding(.bottom, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(Color.formDivider)
                .frame(height: 1)
        }
    }

    private var displayText: String {
        selectedValue.isEmpty ? title : selectedValue
    }
}

private struct NextChargeDatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var hasSelectedDate: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var hasDismissedAfterSelection = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker(
                    "Next Charge Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
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
}

private struct UnderlineInputField: View {
    let title: String
    @Binding var text: String
    let field: AddSubscriptionPage.Field
    var focusedField: FocusState<AddSubscriptionPage.Field?>.Binding

    var body: some View {
        VStack(spacing: 0) {
            TextField("", text: $text, prompt: placeholder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.decimalPad)
                .focused(focusedField, equals: field)
                .font(AddSubscriptionFont.body(18))
                .foregroundStyle(.black.opacity(0.9))
                .padding(.bottom, 10)

            Rectangle()
                .fill(Color.formDivider)
                .frame(height: 1)
        }
    }

    private var placeholder: Text {
        Text(title)
            .font(AddSubscriptionFont.body(18))
            .foregroundStyle(Color.formPlaceholder)
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

private struct SubscriptionPickerSheet: View {
    @Binding var selectedName: String
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List(filteredSubscriptions, id: \.id) { subscription in
                Button {
                    selectedName = subscription.name
                    dismiss()
                } label: {
                    HStack {
                        Text(subscription.name)
                            .font(AddSubscriptionFont.body(17))
                            .foregroundStyle(.primary)

                        Spacer()

                        if selectedName == subscription.name {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.black)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.white.opacity(0.38))
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search subscriptions")
            .navigationTitle("Choose Subscription")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var filteredSubscriptions: [Subscription] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Subscription.subscriptionsList
        }

        return Subscription.subscriptionsList.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}

private enum AddSubscriptionFont {
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

private extension Color {
    static let addSubscriptionBackground = Color(red: 253 / 255, green: 221 / 255, blue: 197 / 255)
    static let formDivider = Color.black.opacity(0.12)
    static let formPlaceholder = Color.black.opacity(0.22)
    static let summaryCard = Color(red: 220 / 255, green: 219 / 255, blue: 210 / 255)
}

struct AddSubscriptionPage_Previews: PreviewProvider {
    static var previews: some View {
        AddSubscriptionPage(showsFirstTimeTitle: true)
            .environmentObject(SubscriptionStore())
    }
}
