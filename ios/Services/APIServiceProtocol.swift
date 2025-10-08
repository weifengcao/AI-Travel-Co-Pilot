// Zenese
// File: ios/APIServiceProtocol.swift
// Description: Protocol defining the networking interface for API services.

import Foundation
import Combine

// MARK: - APIServiceProtocol
/// A protocol abstraction for the API service to enable mocking and testability.
protocol APIServiceProtocol {
    /// Fetches flight details from the backend API.
    /// - Parameter request: A `FlightSearchRequest` containing origin and destination.
    /// - Returns: A Combine publisher for `FlightDetails` or an `APIError`.
    func fetchFlightDetails(request: FlightSearchRequest) -> AnyPublisher<FlightDetails, APIError>
}
