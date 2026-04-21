//
//  DateUtils.swift
//  Overheads
//
//  Created by Tanagarn Ploychinda on 4/22/26.
//

import Foundation

enum DateUtils {
    static func isWithinNextSevenDays(_ date: Date, calendar: Calendar = .current) -> Bool {
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTargetDate = calendar.startOfDay(for: date)

        guard
            let daysUntilTarget = calendar.dateComponents(
                [.day],
                from: startOfToday,
                to: startOfTargetDate
            ).day
        else {
            return false
        }

        return (0...7).contains(daysUntilTarget)
    }

    static func formattedSubscriptionDate(_ date: Date) -> String {
        subscriptionDateFormatter.string(from: date)
    }

    private static let subscriptionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
