//
//  Subscription.swift
//  Overheads
//
//  Created by Tanagarn Ploychinda on 4/22/26.
//

import Foundation

struct Subscription: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var iconCustomization: IconCustomization?
    var amount: Double?
    var frequency: Frequency?
    var nextChargeDate: Date?
    var isAcknowledged: Bool

    init(
        id: UUID = UUID(),
        name: String,
        iconCustomization: IconCustomization? = nil,
        amount: Double? = nil,
        frequency: Frequency? = nil,
        nextChargeDate: Date? = nil,
        isAcknowledged: Bool = false
    ) {
        self.id = id
        self.name = name
        self.iconCustomization = iconCustomization
        self.amount = amount
        self.frequency = frequency
        self.nextChargeDate = nextChargeDate
        self.isAcknowledged = isAcknowledged
    }
}

extension Subscription {
    struct IconCustomization: Hashable, Codable {
        var uploadedImageData: Data?
        var scale: Double

        init(
            uploadedImageData: Data? = nil,
            scale: Double = 1.0
        ) {
            self.uploadedImageData = uploadedImageData
            self.scale = scale
        }

        var isModified: Bool {
            uploadedImageData != nil || abs(scale - 1.0) > 0.001
        }
    }
}
