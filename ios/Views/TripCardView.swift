// Zenese
// File: ios/Views/TripCardView.swift
// Description: A reusable SwiftUI view to display a single tracked flight on the dashboard.

import SwiftUI

struct TripCardView: View {
    // FIXED: The view now takes a single TrackedTrip model object.
    let trip: TrackedTrip

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: SFO -> LAX
            HStack {
                Text(trip.origin)
                    .font(.title2)
                    .fontWeight(.bold)
                Image(systemName: "arrow.right")
                    .font(.headline)
                Text(trip.destination)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .foregroundColor(.white)

            // Dates
            Text(trip.formattedDates)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            Divider().background(Color.white.opacity(0.5))

            // Price Info
            HStack {
                Text("Current Price")
                    .font(.headline)
                Spacer()
                if let currentPrice = trip.currentPrice {
                    HStack(spacing: 4) {
                        trendIcon
                        Text(String(format: "$%.2f", currentPrice))
                            .font(.title2)
                    }
                    .fontWeight(.semibold)
                } else {
                    Text("N/A")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
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
        switch trip.priceTrend {
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
            trip: TrackedTrip(
                id: UUID(),
                origin: "SFO",
                destination: "LAX",
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 3),
                priceHistory: [PriceDataPoint(date: Date(), price: 189.0)]
            )
        )
        .padding()
    }
}
