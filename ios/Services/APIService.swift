// AI Travel Co-Pilot
// File: ios/APIService.swift
// Description: The service responsible for all networking calls to the backend API.

import Foundation
import Combine

// The real APIService now conforms to the APIServiceProtocol.
// This allows us to use it interchangeably with our MockAPIService in different contexts (live app vs. tests).
class APIService: APIServiceProtocol {
    
    private let baseURL = URL(string: "http://127.0.0.1:8000")!
    
    /// Fetches flight details from our backend API.
    /// - Parameter request: A `FlightSearchRequest` containing origin and destination.
    /// - Returns: A Combine publisher for `FlightDetails` or an `APIError`.
    func fetchFlightDetails(request: FlightSearchRequest) -> AnyPublisher<FlightDetails, APIError> {
        let url = baseURL.appendingPathComponent("/search-flights")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            // If encoding fails, return an immediate failure publisher.
            return Fail(error: APIError.encodingError(error)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                    throw APIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500)
                }
                return data
            }
            .decode(type: FlightDetails.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                }
                return APIError.networkError(reason: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}

/// Defines the possible errors our API service can throw.
enum APIError: Error, LocalizedError {
    case encodingError(Error)
    case decodingError(Error)
    case serverError(statusCode: Int)
    case networkError(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .networkError(let reason):
            return "Network error: \(reason)"
        }
    }
}