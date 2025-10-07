// AI Travel Co-Pilot
// File: ios/APIService.swift
// Description: Handles all communication with our backend API.

import Foundation

// --- API Service Configuration ---
struct Constants {
    // In a real app, this URL would point to your deployed backend.
    // For local development, it points to the server running on your Mac.
    static let apiBaseURL = URL(string: "http://127.0.0.1:8000")!
}

// --- Data Models (Must match the Pydantic models in main.py) ---

// Represents the data we SEND to the backend.
struct FlightSearchRequest: Codable {
    let origin: String
    let destination: String
    let start_date: String
    let end_date: String
}

// Represents the data we RECEIVE from the backend.
struct FlightDetails: Codable, Identifiable {
    // Identifiable conformance is useful for SwiftUI lists.
    var id: String { departure_time + airline }
    
    let price: Double
    let airline: String
    let departure_time: String
    let arrival_time: String
}

struct FlightSearchResponse: Codable {
    let flights: [FlightDetails]?
}

// --- Custom Error Type ---
enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
}


// --- The Main Networking Service ---

class APIService {
    
    /// The shared singleton instance of the service.
    static let shared = APIService()
    
    private init() {} // Private initializer to enforce singleton usage.
    
    /// Fetches flight options from our backend.
    /// - Parameters:
    ///   - origin: The departure airport code (e.g., "SFO").
    ///   - destination: The arrival airport code (e.g., "SBA").
    ///   - startDate: The start date for the search (e.g., "2025-11-17").
    ///   - endDate: The end date for the search (e.g., "2025-11-20").
    /// - Returns: An array of `FlightDetails` or throws an `APIError`.
    func searchFlights(origin: String, destination: String, startDate: String, endDate: String) async throws -> [FlightDetails] {
        
        // 1. Set up the URL and the request body
        let endpoint = Constants.apiBaseURL.appendingPathComponent("/search-flights")
        let requestBody = FlightSearchRequest(origin: origin, destination: destination, start_date: startDate, end_date: endDate)
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw APIError.decodingError(error)
        }
        
        // 2. Perform the network request using async/await
        let (data, response) throws = try await URLSession.shared.data(for: request)
        
        // 3. Validate the response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        // 4. Decode the JSON response into our Swift models
        do {
            let flightResponse = try JSONDecoder().decode(FlightSearchResponse.self, from: data)
            return flightResponse.flights ?? [] // Return the flights, or an empty array if null
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
