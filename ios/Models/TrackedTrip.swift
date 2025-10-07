// AI Travel Co-Pilot
// File: ios/Models/TrackedTrip.swift
// Description: Defines the data model for a flight the user is actively tracking.

import Foundation

// Enum to represent price changes for the UI.
// This is moved here to be used by the model and eventually the ViewModel.
enum PriceTrend {
    case up, down, stable
}

// The main struct for a tracked trip.
// It's Codable so we can easily save/load it from device storage (e.g., UserDefaults or a file).
struct TrackedTrip: Codable, Identifiable {
    let id: UUID
    let origin: String
    let destination: String
    let startDate: Date
    let endDate: Date
    
    // Stores a history of prices to determine trends.
    var priceHistory: [PriceDataPoint]
    
    // A computed property to get the most recent price.
    var currentPrice: Double? {
        priceHistory.sorted(by: { $0.date > $1.date }).first?.price
    }
    
    // A computed property to determine the price trend.
    var priceTrend: PriceTrend {
        guard priceHistory.count >= 2 else { return .stable }
        
        let sortedHistory = priceHistory.sorted { $0.date < $1.date }
        let lastPrice = sortedHistory.last!.price
        let previousPrice = sortedHistory[sortedHistory.count - 2].price
        
        if lastPrice > previousPrice {
            return .up
        } else if lastPrice < previousPrice {
            return .down
        } else {
            return .stable
        }
    }
    
    // Formatted string for display in the UI
    var formattedDates: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        
        // Add year if it's different from the current year
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let currentYear = yearFormatter.string(from: Date())
        
        if yearFormatter.string(from: endDate) != currentYear {
            return "\(start) - \(end), \(yearFormatter.string(from: endDate))"
        } else {
            return "\(start) - \(end)"
        }
    }
}

// Represents a single price check at a specific time.
struct PriceDataPoint: Codable {
    let date: Date
    let price: Double
}