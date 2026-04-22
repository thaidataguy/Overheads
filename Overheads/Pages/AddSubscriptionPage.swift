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
    let subscriptionToEdit: Subscription?
    @State private var selectedRecurringPayment = ""
    @State private var selectedCategory: Subscription.Category?
    @State private var amount = ""
    @State private var selectedFrequency: Frequency?
    @State private var nextChargeDate = Date()
    @State private var hasSelectedNextChargeDate = false
    @State private var showsCategoryPicker = false
    @State private var showsFrequencyPicker = false
    @State private var showsNextChargeDatePicker = false
    @State private var showsIncompleteDataAlert = false
    @FocusState private var focusedField: Field?

    init(showsFirstTimeTitle: Bool, subscriptionToEdit: Subscription? = nil) {
        self.showsFirstTimeTitle = showsFirstTimeTitle
        self.subscriptionToEdit = subscriptionToEdit
        _selectedRecurringPayment = State(initialValue: subscriptionToEdit?.name ?? "")
        _selectedCategory = State(initialValue: subscriptionToEdit.flatMap { Subscription.category(for: $0.name) })
        _amount = State(initialValue: Self.formattedAmountText(for: subscriptionToEdit?.amount))
        _selectedFrequency = State(initialValue: subscriptionToEdit?.frequency)
        _nextChargeDate = State(initialValue: subscriptionToEdit?.nextChargeDate ?? Date())
        _hasSelectedNextChargeDate = State(initialValue: subscriptionToEdit?.nextChargeDate != nil)
    }

    var body: some View {
        ZStack {
            Color.addSubscriptionBackground
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }

            VStack(spacing: 0) {
                Spacer(minLength: 148)

                Text(pageTitle)
                    .font(AddSubscriptionFont.title(34))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 52)

                VStack(spacing: 16) {
                    UnderlinePickerField(
                        title: "Category",
                        selectedValue: categoryFieldValue,
                        action: {
                            focusedField = nil
                            showsCategoryPicker = true
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

                Spacer(minLength: 72)

                actionButtons

                Spacer(minLength: 148)
            }
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showsCategoryPicker) {
            CategoryPickerSheet(
                selectedCategory: $selectedCategory,
                selectedRecurringPayment: $selectedRecurringPayment
            )
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
            .presentationDetents([.height(440)])
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
            !selectedRecurringPayment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
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
                name: selectedRecurringPayment,
                amount: parsedAmount,
                frequency: selectedFrequency,
                nextChargeDate: nextChargeDate
            )
        } else {
            subscriptionStore.addSubscription(
                name: selectedRecurringPayment,
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

    private var categoryFieldValue: String {
        selectedRecurringPayment
    }

    private var actionButtons: some View {
        HStack(spacing: 14) {
            if let subscriptionToEdit {
                Button {
                    deleteSubscription()
                } label: {
                    actionButtonLabel(
                        title: "Delete",
                        textColor: .white,
                        fillColors: [
                            Color(red: 0.89, green: 0.24, blue: 0.21).opacity(0.92),
                            Color(red: 0.76, green: 0.16, blue: 0.16).opacity(0.84)
                        ],
                        strokeColor: .white.opacity(0.38),
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
                        textColor: .black.opacity(0.82),
                        fillColors: [
                            .white.opacity(0.45),
                            .white.opacity(0.16)
                        ],
                        strokeColor: .white.opacity(0.58),
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
                    textColor: .black.opacity(0.92),
                    fillColors: [
                        .white.opacity(0.55),
                        .white.opacity(0.18)
                    ],
                    strokeColor: .white.opacity(0.65),
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
        strokeColor: Color,
        width: CGFloat
    ) -> some View {
        Text(title)
            .font(AddSubscriptionFont.bodySemibold(18))
            .foregroundStyle(textColor)
            .frame(width: width, height: 46)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: fillColors,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .blendMode(.screen)
                    }
                    .overlay {
                        Capsule()
                            .stroke(strokeColor, lineWidth: 0.8)
                    }
                    .shadow(color: .white.opacity(0.45), radius: 8, y: -1)
                    .shadow(color: .black.opacity(0.08), radius: 18, y: 10)
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
                                Text(frequency.displayName)
                                    .font(AddSubscriptionFont.bodySemibold(17))
                                    .foregroundStyle(.black.opacity(0.9))

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
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)

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
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)

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
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField.wrappedValue = field
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

private struct CategoryPickerSheet: View {
    @Binding var selectedCategory: Subscription.Category?
    @Binding var selectedRecurringPayment: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(Subscription.Category.allCases) { category in
                NavigationLink(value: category) {
                    HStack {
                        Text(category.rawValue)
                            .font(AddSubscriptionFont.body(17))
                            .foregroundStyle(.primary)

                        Spacer()

                        if selectedCategory == category {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.black)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.white.opacity(0.38))
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Choose Category")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Subscription.Category.self) { category in
                RecurringPaymentPickerSheet(
                    category: category,
                    selectedCategory: $selectedCategory,
                    selectedRecurringPayment: $selectedRecurringPayment,
                    dismissPicker: {
                        dismiss()
                    }
                )
            }
        }
    }
}

private struct RecurringPaymentPickerSheet: View {
    let category: Subscription.Category
    @Binding var selectedCategory: Subscription.Category?
    @Binding var selectedRecurringPayment: String
    let dismissPicker: () -> Void
    @State private var searchText = ""

    var body: some View {
        List(filteredItems, id: \.self) { item in
            if category == .other && item == "Custom entry" {
                NavigationLink {
                    CustomRecurringPaymentEntryView(
                        selectedCategory: $selectedCategory,
                        selectedRecurringPayment: $selectedRecurringPayment,
                        dismissPicker: dismissPicker
                    )
                } label: {
                    rowLabel(for: item)
                }
                .listRowBackground(Color.white.opacity(0.38))
            } else {
                Button {
                    selectedCategory = category
                    selectedRecurringPayment = item
                    dismissPicker()
                } label: {
                    rowLabel(for: item)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.white.opacity(0.38))
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: category == .subscriptions ? "Search subscriptions" : "Search recurring payments"
        )
    }

    private var filteredItems: [String] {
        let items = category.items
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedSearchText.isEmpty else { return items }

        return items.filter {
            $0.localizedCaseInsensitiveContains(trimmedSearchText)
        }
    }

    @ViewBuilder
    private func rowLabel(for item: String) -> some View {
        HStack {
            RecurringPaymentIconView(iconName: Subscription.iconName(for: item))

            Text(item)
                .font(AddSubscriptionFont.body(17))
                .foregroundStyle(.primary)

            Spacer()

            if selectedCategory == category && selectedRecurringPayment == item {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.black)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct RecurringPaymentIconView: View {
    let iconName: String?

    var body: some View {
        Group {
            if let emojiIcon {
                Text(emojiIcon)
                    .font(.system(size: 18))
                    .frame(width: PickerIconMetrics.symbolSide, height: PickerIconMetrics.symbolSide)
            } else if let iconImage {
                iconImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: PickerIconMetrics.symbolSide, height: PickerIconMetrics.symbolSide)
            } else {
                Image(systemName: "app.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: PickerIconMetrics.symbolSide, height: PickerIconMetrics.symbolSide)
                    .foregroundStyle(Color.primary.opacity(0.7))
            }
        }
        .frame(width: PickerIconMetrics.containerWidth, alignment: .center)
    }

    private var emojiIcon: String? {
        guard let iconName, !iconName.isEmpty else { return nil }
        guard UIImage(systemName: iconName) == nil else { return nil }
        guard bundledIcon(named: iconName) == nil else { return nil }
        guard UIImage(named: iconName) == nil else { return nil }
        return iconName
    }

    private var iconImage: Image? {
        guard let iconName, !iconName.isEmpty else { return nil }

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
}

private enum PickerIconMetrics {
    static let symbolSide: CGFloat = 18
    static let containerWidth: CGFloat = 26
}

private struct CustomRecurringPaymentEntryView: View {
    @Binding var selectedCategory: Subscription.Category?
    @Binding var selectedRecurringPayment: String
    let dismissPicker: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var customEntry = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            TextField("Custom entry", text: $customEntry)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .focused($isTextFieldFocused)
                .font(AddSubscriptionFont.body(18))
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.white.opacity(0.6))
                )

            Button {
                let trimmedEntry = customEntry.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedEntry.isEmpty else { return }

                selectedCategory = .other
                selectedRecurringPayment = trimmedEntry
                dismiss()
                dismissPicker()
            } label: {
                Text("Use Custom Entry")
                    .font(AddSubscriptionFont.bodySemibold(17))
                    .foregroundStyle(.black.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.white.opacity(0.7))
                    )
            }
            .buttonStyle(.plain)
            .disabled(customEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(customEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .navigationTitle("Custom entry")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isTextFieldFocused = true
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
}

struct AddSubscriptionPage_Previews: PreviewProvider {
    static var previews: some View {
        AddSubscriptionPage(showsFirstTimeTitle: true)
            .environmentObject(SubscriptionStore())
    }
}
