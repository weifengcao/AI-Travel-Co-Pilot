// Zenese
// File: ios/Tools/FlightSearchTool.swift
// Description: A tool that the on-device language model can use to understand flight search queries.

import Foundation
import FoundationModels

/// A tool that the on-device language model can use to understand flight search queries.
@available(iOS 18.0, *)
struct FlightSearchTool: Tool {
    /// The name of the tool, which the model uses to identify it.
    let name = "find_flights"
    
    /// A description that helps the model understand what this tool does.
    let description = "Finds flights between two locations on specified dates."
    
    /// The arguments the tool takes, defined in a separate struct.
    typealias Arguments = FlightSearchArguments
    
    /// The business logic of the tool. In our case, we just want the parsed data.
    func run(with arguments: FlightSearchArguments) async throws -> String {
        // We don't need to do anything here since we are just using the tool to structure the data.
        return "Successfully parsed flight query."
    }
}

/// The arguments for the `FlightSearchTool`.
struct FlightSearchArguments: Codable, Sendable {
    var origin: String
    var destination: String
    var startDate: String
    var endDate: String
}
