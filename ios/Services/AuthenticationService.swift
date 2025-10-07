// AI Travel Co-Pilot
// File: ios/Services/AuthenticationService.swift
// Description: Manages user authentication, including Google Sign-In and Biometrics.

import Foundation
import Combine
import LocalAuthentication // Import for Face ID / Touch ID

class AuthenticationService: ObservableObject {
    
    // Singleton pattern for a single source of truth for auth state.
    static let shared = AuthenticationService()
    
    // @Published property will notify any SwiftUI view observing it of changes.
    @Published var isSignedIn = false
    
    private init() {
        // In a real app, you would check for a securely saved token here.
    }
    
    // --- Public Methods ---
    
    /// Signs the user in using their Google Account.
    func signInWithGoogle() {
        // TODO: Integrate Google Sign-In SDK.
        // This is where you would call the Google SDK to initiate the sign-in flow.
        
        // For now, we'll simulate a successful sign-in after a short delay.
        print("AuthenticationService: Initiating Google Sign-In...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isSignedIn = true
            // IMPORTANT: After a successful Google Sign-In, you would save a token
            // to the device's secure Keychain. This token is what allows future
            // Face ID logins to be secure.
            print("AuthenticationService: User signed in successfully with Google.")
        }
    }
    
    /// Signs the user out.
    func signOut() {
        // TODO: Clear Google Sign-In session.
        // IMPORTANT: Clear the authentication token from the Keychain.
        self.isSignedIn = false
        print("AuthenticationService: User signed out.")
    }

    /// Attempts to authenticate the user using on-device biometrics (Face ID / Touch ID).
    /// This should be called on app launch to quickly re-authenticate a returning user.
    func authenticateWithBiometrics() {
        // First, check if a user has previously signed in with Google.
        // In a real app, this would involve checking for a token in the Keychain.
        // For this simulation, we'll assume a token might exist.
        
        let context = LAContext()
        var error: NSError?

        // Check if the device is capable of biometric authentication.
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Sign in to your AI Travel Co-Pilot account."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // User authenticated successfully with biometrics.
                        self?.isSignedIn = true
                        print("AuthenticationService: User signed in with Biometrics.")
                    } else {
                        // Handle error (e.g., user cancelled, passcode not set).
                        print("AuthenticationService: Biometric authentication failed or was cancelled.")
                    }
                }
            }
        } else {
            // Biometrics not available on this device.
            print("AuthenticationService: Biometrics not available on this device.")
        }
    }
}