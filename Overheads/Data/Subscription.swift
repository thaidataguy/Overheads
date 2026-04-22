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
    var isAcknowledged: Bool

    init(
        id: UUID = UUID(),
        name: String,
        icon: String? = nil,
        amount: Double? = nil,
        frequency: Frequency? = nil,
        nextChargeDate: Date? = nil,
        isAcknowledged: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.amount = amount
        self.frequency = frequency
        self.nextChargeDate = nextChargeDate
        self.isAcknowledged = isAcknowledged
    }
}

extension Subscription {
    static let iconArchiveBySubscriptionName: [String: String] = [
        "1Password": "1password.png",
        "Adobe Creative": "adobe-creative.png",
        "AIS Play": "ais-play.png",
        "Amazon Prime": "amazon-prime.png",
        "Apple Music": "apple-music.png",
        "Apple TV+": "apple-tv-plus.png",
        "Athlytic": "athlytic.png",
        "Audible": "audible.png",
        "Base44 Pro": "base44-pro.png",
        "Bilibili": "bilibili.png",
        "Blinkist": "blinkist.png",
        "Calm": "calm.png",
        "Canva Pro": "canva-pro.png",
        "ChatGPT Plus": "chatgpt-plus.png",
        "Claude Pro": "claude-pro.png",
        "Cursor Pro": "cursor-pro.png",
        "Dashlane": "dashlane.png",
        "Deezer": "deezer.png",
        "Disney+": "disney-plus.png",
        "Dropbox": "dropbox.png",
        "Duolingo": "duolingo.png",
        "ExpressVPN": "expressvpn.png",
        "Figma": "figma.png",
        "Garena": "garena.png",
        "Genie Records": "genie-records.png",
        "GitHub Copilot": "github-copilot.png",
        "Google One": "google-one.png",
        "Google Workspace": "google-workspace.png",
        "HBO Max": "hbo-max.png",
        "Headspace": "headspace.png",
        "iCloud+": "icloud-plus.png",
        "iQIYI": "iqiyi.png",
        "JOOX": "joox.png",
        "KBank Live": "kbank-live.png",
        "Kindle Unlimited": "kindle-unlimited.png",
        "LINE MAN": "line-man.png",
        "Microsoft 365": "microsoft-365.png",
        "MONOMAX": "monomax.png",
        "MyFitnessPal": "myfitnesspal.png",
        "Netflix": "netflix.png",
        "Nike Training": "nike-training.png",
        "Nintendo Online": "nintendo-online.png",
        "NordVPN": "nordvpn.png",
        "Notion": "notion.png",
        "OneDrive": "onedrive.png",
        "Peloton": "peloton.png",
        "PlayStation Plus": "playstation-plus.png",
        "ProtonVPN": "protonvpn.png",
        "Slack": "slack.png",
        "Spotify": "spotify.png",
        "Steam": "steam.png",
        "Strava": "strava.png",
        "Surfshark": "surfshark.png",
        "TIDAL": "tidal.png",
        "TrueID": "trueid.png",
        "Viu": "viu.png",
        "WeTV": "wetv.png",
        "Workpoint TV": "workpoint-tv.png",
        "Xbox Game Pass": "xbox-game-pass.png",
        "YouTube Music": "youtube-music.png",
        "YouTube Premium": "youtube-premium.png",
        "Zoom": "zoom.png"
    ]

    static let emojiIconByRecurringPaymentName: [String: String] = [
        "Rent": "🏠",
        "Mortgage": "🏠",
        "Electricity": "⚡️",
        "Water": "💧",
        "Internet": "🖥️",
        "Phone bill": "📱",
        "Student loans": "🎓",
        "Car loans": "🚗",
        "Personal loans": "💵",
        "Health": "📝",
        "Car": "📝",
        "Home": "📝",
        "Life": "📝"
    ]

    enum Category: String, CaseIterable, Identifiable, Hashable {
        case housing = "Housing"
        case utilities = "Utilities"
        case subscriptions = "Subscriptions"
        case loans = "Loans"
        case insurance = "Insurance"
        case other = "Other"

        var id: String { rawValue }

        var items: [String] {
            switch self {
            case .housing:
                return ["Rent", "Mortgage"]
            case .utilities:
                return ["Electricity", "Water", "Internet", "Phone bill"]
            case .subscriptions:
                return Subscription.subscriptionsList.map(\.name)
            case .loans:
                return ["Student loans", "Car loans", "Personal loans"]
            case .insurance:
                return ["Health", "Car", "Home", "Life"]
            case .other:
                return ["Custom entry"]
            }
        }
    }

    static func category(for recurringPaymentName: String) -> Category? {
        for category in Category.allCases where category.items.contains(recurringPaymentName) {
            return category
        }

        return nil
    }

    static let subscriptionsList: [Subscription] = [
        Subscription(name: "1Password", icon: iconName(for: "1Password")),
        Subscription(name: "Adobe Creative", icon: iconName(for: "Adobe Creative")),
        Subscription(name: "AIS Play", icon: iconName(for: "AIS Play")),
        Subscription(name: "Amazon Prime", icon: iconName(for: "Amazon Prime")),
        Subscription(name: "Apple Music", icon: iconName(for: "Apple Music")),
        Subscription(name: "Apple TV+", icon: iconName(for: "Apple TV+")),
        Subscription(name: "Athlytic", icon: iconName(for: "Athlytic")),
        Subscription(name: "Audible", icon: iconName(for: "Audible")),
        Subscription(name: "Base44 Pro", icon: iconName(for: "Base44 Pro")),
        Subscription(name: "Bilibili", icon: iconName(for: "Bilibili")),
        Subscription(name: "Blinkist", icon: iconName(for: "Blinkist")),
        Subscription(name: "Calm", icon: iconName(for: "Calm")),
        Subscription(name: "Canva Pro", icon: iconName(for: "Canva Pro")),
        Subscription(name: "ChatGPT Plus", icon: iconName(for: "ChatGPT Plus")),
        Subscription(name: "Claude Pro", icon: iconName(for: "Claude Pro")),
        Subscription(name: "Cursor Pro", icon: iconName(for: "Cursor Pro")),
        Subscription(name: "Dashlane", icon: iconName(for: "Dashlane")),
        Subscription(name: "Deezer", icon: iconName(for: "Deezer")),
        Subscription(name: "Disney+", icon: iconName(for: "Disney+")),
        Subscription(name: "Dropbox", icon: iconName(for: "Dropbox")),
        Subscription(name: "Duolingo", icon: iconName(for: "Duolingo")),
        Subscription(name: "ExpressVPN", icon: iconName(for: "ExpressVPN")),
        Subscription(name: "Figma", icon: iconName(for: "Figma")),
        Subscription(name: "Garena", icon: iconName(for: "Garena")),
        Subscription(name: "Genie Records", icon: iconName(for: "Genie Records")),
        Subscription(name: "GitHub Copilot", icon: iconName(for: "GitHub Copilot")),
        Subscription(name: "Google One", icon: iconName(for: "Google One")),
        Subscription(name: "Google Workspace", icon: iconName(for: "Google Workspace")),
        Subscription(name: "HBO Max", icon: iconName(for: "HBO Max")),
        Subscription(name: "Headspace", icon: iconName(for: "Headspace")),
        Subscription(name: "iCloud+", icon: iconName(for: "iCloud+")),
        Subscription(name: "iQIYI", icon: iconName(for: "iQIYI")),
        Subscription(name: "JOOX", icon: iconName(for: "JOOX")),
        Subscription(name: "KBank Live", icon: iconName(for: "KBank Live")),
        Subscription(name: "Kindle Unlimited", icon: iconName(for: "Kindle Unlimited")),
        Subscription(name: "LINE MAN", icon: iconName(for: "LINE MAN")),
        Subscription(name: "Microsoft 365", icon: iconName(for: "Microsoft 365")),
        Subscription(name: "MONOMAX", icon: iconName(for: "MONOMAX")),
        Subscription(name: "MyFitnessPal", icon: iconName(for: "MyFitnessPal")),
        Subscription(name: "Netflix", icon: iconName(for: "Netflix")),
        Subscription(name: "Nike Training", icon: iconName(for: "Nike Training")),
        Subscription(name: "Nintendo Online", icon: iconName(for: "Nintendo Online")),
        Subscription(name: "NordVPN", icon: iconName(for: "NordVPN")),
        Subscription(name: "Notion", icon: iconName(for: "Notion")),
        Subscription(name: "OneDrive", icon: iconName(for: "OneDrive")),
        Subscription(name: "Peloton", icon: iconName(for: "Peloton")),
        Subscription(name: "PlayStation Plus", icon: iconName(for: "PlayStation Plus")),
        Subscription(name: "ProtonVPN", icon: iconName(for: "ProtonVPN")),
        Subscription(name: "Slack", icon: iconName(for: "Slack")),
        Subscription(name: "Spotify", icon: iconName(for: "Spotify")),
        Subscription(name: "Steam", icon: iconName(for: "Steam")),
        Subscription(name: "Strava", icon: iconName(for: "Strava")),
        Subscription(name: "Surfshark", icon: iconName(for: "Surfshark")),
        Subscription(name: "TIDAL", icon: iconName(for: "TIDAL")),
        Subscription(name: "TrueID", icon: iconName(for: "TrueID")),
        Subscription(name: "Viu", icon: iconName(for: "Viu")),
        Subscription(name: "WeTV", icon: iconName(for: "WeTV")),
        Subscription(name: "Workpoint TV", icon: iconName(for: "Workpoint TV")),
        Subscription(name: "Xbox Game Pass", icon: iconName(for: "Xbox Game Pass")),
        Subscription(name: "YouTube Music", icon: iconName(for: "YouTube Music")),
        Subscription(name: "YouTube Premium", icon: iconName(for: "YouTube Premium")),
        Subscription(name: "Zoom", icon: iconName(for: "Zoom"))
    ]

    static func iconName(for subscriptionName: String) -> String? {
        if let bundledIconName = iconArchiveBySubscriptionName[subscriptionName] {
            return bundledIconName
        }

        return emojiIconByRecurringPaymentName[subscriptionName]
    }
}
