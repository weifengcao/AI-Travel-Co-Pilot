// AI Travel Co-Pilot
// File: ios/AI_Travel_Co_PilotApp.swift
// Description: The main entry point for the AI Travel Co-Pilot SwiftUI application.

import SwiftUI

// The @main attribute identifies the app's entry point.
@main
struct AI_Travel_Co_PilotApp: App {
    
    // The body of the App protocol is a Scene, which contains the view hierarchy.
    var body: some Scene {
        WindowGroup {
            // We instantiate our MainView here.
            // MainView will handle whether to show the Onboarding flow or the main TabView
            // based on the user's authentication state.
            MainView()
        }
    }
}
