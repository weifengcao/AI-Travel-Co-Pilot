// Zenese
// File: ios/Views/OnboardingView.swift
// Description: The UI for the onboarding flow shown to first-time users.

import SwiftUI

struct OnboardingView: View {
    
    // The action to perform when the sign-in button is tapped.
    var onSignIn: () -> Void
    
    var body: some View {
        VStack {
            TabView {
                OnboardingPageView(
                    imageName: "airplane.circle.fill",
                    title: "Welcome to Zenese",
                    description: "Your personal AI assistant for smarter travel planning."
                )
                
                OnboardingPageView(
                    imageName: "magnifyingglass.circle.fill",
                    title: "Track Prices with Ease",
                    description: "Just ask, and I'll watch flight prices for you, notifying you of the best deals."
                )
                
                OnboardingPageView(
                    imageName: "book.circle.fill",
                    title: "Build Your Travel Story",
                    description: "Log your trips, expenses, and memories to create a personal travel journal."
                )
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            // Sign-In Button
            Button(action: onSignIn) {
                HStack {
                    // In a real project, you would add a Google logo image to your asset catalog.
                    Image(systemName: "g.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                    Text("Sign In with Google")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.primary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.thinMaterial)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
    }
}

// A reusable view for a single page in the onboarding flow.
struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: imageName)
                .font(.system(size: 100))
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.8)) // Brand color from UI Guide
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(description)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onSignIn: {})
    }
}