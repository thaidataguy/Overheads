//
//  OverheadsApp.swift
//  Overheads
//
//  Created by Tanagarn Ploychinda on 4/22/26.
//

import SwiftUI

enum AppThemePreference: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

@main
struct OverheadsApp: App {
    @StateObject private var subscriptionStore = SubscriptionStore()
    @AppStorage("app_theme_preference") private var appThemePreference = AppThemePreference.system.rawValue

    var body: some Scene {
        WindowGroup {
            Group {
                if subscriptionStore.savedSubscriptions.isEmpty {
                    WelcomePage()
                } else {
                    HomePage()
                }
            }
            .environmentObject(subscriptionStore)
            .preferredColorScheme(selectedTheme.colorScheme)
            .tint(Color.overheadsSun)
            .task {
                BillingNotificationScheduler.requestAuthorizationIfNeeded()
            }
        }
    }

    private var selectedTheme: AppThemePreference {
        AppThemePreference(rawValue: appThemePreference) ?? .system
    }
}
