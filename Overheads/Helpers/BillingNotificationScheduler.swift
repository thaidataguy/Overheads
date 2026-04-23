//
//  BillingNotificationScheduler.swift
//  Overheads
//
//  Created by Codex on 4/22/26.
//

import Foundation
import UserNotifications

enum BillingNotificationScheduler {
    private static let identifierPrefix = "overheads.billing."
    private static let scheduledOccurrencesPerSubscription = 12

    static func requestAuthorizationIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    static func refreshNotifications(for subscriptions: [Subscription]) {
        requestAuthorizationIfNeeded()

        Task {
            let center = UNUserNotificationCenter.current()
            let existingRequests = await center.pendingNotificationRequests()
            let identifiersToRemove = existingRequests
                .map(\.identifier)
                .filter { $0.hasPrefix(identifierPrefix) }

            if !identifiersToRemove.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            }

            for subscription in subscriptions {
                let requests = notificationRequests(for: subscription)
                for request in requests {
                    try? await center.add(request)
                }
            }
        }
    }

    private static func notificationRequests(for subscription: Subscription) -> [UNNotificationRequest] {
        guard
            let nextChargeDate = subscription.nextChargeDate,
            let frequency = subscription.frequency
        else {
            return []
        }

        let calendar = Calendar.current
        let occurrences = futureChargeDates(
            startingAt: nextChargeDate,
            frequency: frequency,
            count: scheduledOccurrencesPerSubscription,
            calendar: calendar
        )

        return occurrences.compactMap { chargeDate in
            let dayBeforeCharge = calendar.date(byAdding: .day, value: -1, to: chargeDate) ?? chargeDate
            let reminderDate = calendar.date(
                bySettingHour: 10,
                minute: 0,
                second: 0,
                of: dayBeforeCharge
            ) ?? dayBeforeCharge
            guard reminderDate > Date() else { return nil }

            let content = UNMutableNotificationContent()
            content.title = "Billing reminder"
            content.body = "\(subscription.name) is due tomorrow."
            content.sound = .default

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let identifier = notificationIdentifier(for: subscription.id, reminderDate: reminderDate, calendar: calendar)
            return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        }
    }

    private static func futureChargeDates(
        startingAt date: Date,
        frequency: Frequency,
        count: Int,
        calendar: Calendar
    ) -> [Date] {
        var dates: [Date] = []
        var currentDate = date

        for _ in 0..<count {
            dates.append(currentDate)

            guard let nextDate = nextChargeDate(after: currentDate, frequency: frequency, calendar: calendar) else {
                break
            }

            currentDate = nextDate
        }

        return dates
    }

    private static func nextChargeDate(after date: Date, frequency: Frequency, calendar: Calendar) -> Date? {
        switch frequency {
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date)
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: date)
        case .annually:
            return calendar.date(byAdding: .year, value: 1, to: date)
        }
    }

    private static func notificationIdentifier(for subscriptionID: UUID, reminderDate: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        return "\(identifierPrefix)\(subscriptionID.uuidString).\(year)-\(month)-\(day)-\(hour)-\(minute)"
    }
}
