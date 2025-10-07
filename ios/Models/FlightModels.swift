// AI Travel Co-Pilot
// File: ios/Models/FlightModels.swift
// Description: Data models for flight search requests and responses.

import Foundation

// The request body sent to our backend API.
struct FlightSearchRequest: Codable {
    let origin: String
    let destination: String
    let startDate: String
    let endDate: String
}

// Represents a single flight option returned from the backend.
struct FlightDetails: Codable, Identifiable {
    let id: String // A unique identifier for the flight
    let airline: AirlineInfo
    let price: Double
    let departureTime: String
    let arrivalTime: String
    let stops: Int
    
    // CodingKeys are used to map JSON keys to Swift properties if they differ.
    // In this case, they match, but it's good practice to include them.
    enum CodingKeys: String, CodingKey {
        case id
        case airline
        case price
        case departureTime = "departure_time"
        case arrivalTime = "arrival_time"
        case stops
    }
}

struct FlightSearchResponse: Codable {
    let flights: [FlightDetails]?
}

// Represents airline information.
struct AirlineInfo: Codable {
    let name: String
    let logoUrl: String? // Optional, in case a logo isn't available
    
    enum CodingKeys: String, CodingKey {
        case name
        case logoUrl = "logo_url"
    }
}