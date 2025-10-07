// AI Travel Co-Pilot
// File: ios/AI_Travel_Co_PilotTests/Mocks/MockAPIService.swift
// Description: A mock version of the APIService for unit testing.

import Foundation
import Combine
@testable import AI_Travel_Co_Pilot

/// A mock APIService that conforms to a new APIServiceProtocol.
/// This allows us to inject this mock into our ViewModel for testing.
class MockAPIService: APIServiceProtocol {
    
    // A property to control what this mock should return.
    var result: Result<FlightDetails, APIError>!
    
    func fetchFlightDetails(request: FlightSearchRequest) -> AnyPublisher<FlightDetails, APIError> {
        // We use a Future to simulate an asynchronous network call.
        return Future { promise in
            // Return the pre-configured result immediately.
            promise(self.result)
        }.eraseToAnyPublisher()
    }
}

/// A protocol that our real APIService will also conform to.
/// This is what enables dependency injection, allowing us to swap the real service with our mock one.
protocol APIServiceProtocol {
    func fetchFlightDetails(request: FlightSearchRequest) -> AnyPublisher<FlightDetails, APIError>
}

// We would also update the real `APIService` to conform to this protocol:
// class APIService: APIServiceProtocol { ... }
