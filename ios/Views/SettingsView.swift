// AI Travel Co-Pilot
// File: ios/Views/SettingsView.swift
// Description: A view for user settings, including the sign-out button.

import SwiftUI

struct SettingsView: View {
    
    // Access the shared authentication service to call the signOut method.
    @ObservedObject private var authService = AuthenticationService.shared
    
    var body: some View {
        // Using a Form for a standard iOS settings look and feel.
        Form {
            Section(header: Text("Account")) {
                // The sign-out button.
                Button(action: {
                    // Call the signOut method from our service.
                    authService.signOut()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red) // Standard practice for destructive actions.
                }
            }
            
            Section(header: Text("About")) {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text("1.0.0 (MVP)")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}