//
//  OverheadsApp.swift
//  Overheads
//
//  Created by Tanagarn Ploychinda on 4/22/26.
//

import SwiftUI

@main
struct OverheadsApp: App {
    @StateObject private var subscriptionStore = SubscriptionStore()

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
            .task {
                BillingNotificationScheduler.requestAuthorizationIfNeeded()
            }
        }
    }
}
