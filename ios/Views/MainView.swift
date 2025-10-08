// AI Travel Co-Pilot
// File: ios/Views/MainView.swift
// Description: The main root view of the application that handles authentication state.

import SwiftUI

struct MainView: View {
    
    // An @ObservedObject to subscribe to the AuthenticationService's published properties.
    @ObservedObject private var authService = AuthenticationService.shared
    
    var body: some View {
        Group {
            if authService.isSignedIn {
                // Main App Interface with Tabs
                TabView {
                    NavigationView {
                        ChatView()
                            .navigationTitle("Co-Pilot Chat")
                    }
                    .tabItem {
                        Label("Chat", systemImage: "message.fill")
                    }
                    
                    NavigationView {
                        DashboardView()
                            .navigationTitle("Your Dashboard")
                    }
                    .tabItem {
                        Label("Dashboard", systemImage: "list.bullet")
                    }
                    
                    // Add the new Settings tab.
                    NavigationView {
                        SettingsView()
                    }
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                }
            } else {
                // Onboarding flow with the primary Google Sign-In button
                OnboardingView(onSignIn: {
                    authService.signInWithGoogle()
                })
            }
        }
        .onAppear {
            // When the view appears, if the user isn't signed in,
            // immediately try to authenticate with Face ID.
            if !authService.isSignedIn {
                authService.authenticateWithBiometrics()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    // FIXED: Corrected the syntax error in the preview provider.
    static var previews: some View {
        MainView()
    }
}
