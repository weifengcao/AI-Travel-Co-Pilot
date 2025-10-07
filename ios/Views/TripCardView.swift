// AI Travel Co-Pilot
// File: ios/Views/TripCardView.swift
// Description: A reusable SwiftUI view to display a single tracked flight on the dashboard.

import SwiftUI

struct TripCardView: View {
    // Mock data for a single trip. In a real app, this would be a 'TrackedTrip' model object.
    let origin: String
    let destination: String
    let dates: String
    let currentPrice: Int
    let priceTrend: PriceTrend // Enum to represent price changes

    enum PriceTrend {
        case up, down, stable
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: SFO -> LAX
            HStack {
                Text(origin)
                    .font(.title2)
                    .fontWeight(.bold)
                Image(systemName: "arrow.right")
                    .font(.headline)
                Text(destination)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .foregroundColor(.white)

            // Dates
            Text(dates)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            Divider().background(Color.white.opacity(0.5))

            // Price Info
            HStack {
                Text("Current Price")
                    .font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    trendIcon
                    Text("$\(currentPrice)")
                        .font(.title2)
                }
                .fontWeight(.semibold)
            }
            .foregroundColor(.white)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(radius: 5)
    }
    
    // Helper view to determine the trend icon and color
    @ViewBuilder
    private var trendIcon: some View {
        switch priceTrend {
        case .up:
            Image(systemName: "arrow.up.right")
                .foregroundColor(.red.opacity(0.8))
        case .down:
            Image(systemName: "arrow.down.right")
                .foregroundColor(.green)
        case .stable:
            Image(systemName: "minus")
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// A preview provider to see the card in Xcode's canvas.
struct TripCardView_Previews: PreviewProvider {
    static var previews: some View {
        TripCardView(
            origin: "SFO",
            destination: "LAX",
            dates: "Nov 17 - Nov 20, 2025",
            currentPrice: 189,
            priceTrend: .down
        )
        .padding()
    }
}
