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
    var icon: String?
    var amount: Double?
    var frequency: Frequency?
    var nextChargeDate: Date?

    init(
        id: UUID = UUID(),
        name: String,
        icon: String? = nil,
        amount: Double? = nil,
        frequency: Frequency? = nil,
        nextChargeDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.amount = amount
        self.frequency = frequency
        self.nextChargeDate = nextChargeDate
    }
}

extension Subscription {
    static let subscriptionsList: [Subscription] = [
        Subscription(name: "Base44 Pro"),
        Subscription(name: "Netflix"),
        Subscription(name: "Disney+"),
        Subscription(name: "HBO Max"),
        Subscription(name: "Amazon Prime"),
        Subscription(name: "Apple TV+"),
        Subscription(name: "YouTube Premium"),
        Subscription(name: "TrueID"),
        Subscription(name: "AIS Play"),
        Subscription(name: "MONOMAX"),
        Subscription(name: "WeTV"),
        Subscription(name: "iQIYI"),
        Subscription(name: "Viu"),
        Subscription(name: "Bilibili"),
        Subscription(name: "Audible"),
        Subscription(name: "Kindle Unlimited"),
        Subscription(name: "Spotify"),
        Subscription(name: "Apple Music"),
        Subscription(name: "YouTube Music"),
        Subscription(name: "JOOX"),
        Subscription(name: "TIDAL"),
        Subscription(name: "Deezer"),
        Subscription(name: "Notion"),
        Subscription(name: "Slack"),
        Subscription(name: "Microsoft 365"),
        Subscription(name: "Google Workspace"),
        Subscription(name: "Canva Pro"),
        Subscription(name: "Adobe Creative"),
        Subscription(name: "Figma"),
        Subscription(name: "Zoom"),
        Subscription(name: "Duolingo"),
        Subscription(name: "Blinkist"),
        Subscription(name: "ChatGPT Plus"),
        Subscription(name: "Claude Pro"),
        Subscription(name: "Cursor Pro"),
        Subscription(name: "GitHub Copilot"),
        Subscription(name: "1Password"),
        Subscription(name: "Dashlane"),
        Subscription(name: "Dropbox"),
        Subscription(name: "iCloud+"),
        Subscription(name: "Google One"),
        Subscription(name: "OneDrive"),
        Subscription(name: "MyFitnessPal"),
        Subscription(name: "Strava"),
        Subscription(name: "Athlytic"),
        Subscription(name: "Calm"),
        Subscription(name: "Headspace"),
        Subscription(name: "Nike Training"),
        Subscription(name: "Peloton"),
        Subscription(name: "Surfshark"),
        Subscription(name: "NordVPN"),
        Subscription(name: "ExpressVPN"),
        Subscription(name: "ProtonVPN"),
        Subscription(name: "PlayStation Plus"),
        Subscription(name: "Xbox Game Pass"),
        Subscription(name: "Nintendo Online"),
        Subscription(name: "Steam"),
        Subscription(name: "Garena"),
        Subscription(name: "LINE MAN"),
        Subscription(name: "Workpoint TV"),
        Subscription(name: "Genie Records"),
        Subscription(name: "KBank Live")
    ]
}
