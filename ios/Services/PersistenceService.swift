// AI Travel Co-Pilot
// File: ios/Services/PersistenceService.swift
// Description: Manages saving and loading of user data, like tracked trips, to the device.

import Foundation

class PersistenceService {
    
    // Singleton pattern for easy access throughout the app.
    static let shared = PersistenceService()
    
    // The key we'll use to store our data in UserDefaults.
    private let trackedTripsKey = "trackedTripsKey"
    
    // Private initializer to enforce the singleton pattern.
    private init() {}
    
    /// Loads the array of TrackedTrip objects from the device's storage.
    /// - Returns: An array of TrackedTrip objects, or an empty array if none are saved or an error occurs.
    func loadTrips() -> [TrackedTrip] {
        guard let data = UserDefaults.standard.data(forKey: trackedTripsKey) else {
            return [] // No data saved yet, return an empty array.
        }
        
        do {
            let decoder = JSONDecoder()
            let trips = try decoder.decode([TrackedTrip].self, from: data)
            return trips
        } catch {
            print("Error decoding tracked trips: \(error)")
            return [] // Return empty array if decoding fails.
        }
    }
    
    /// Saves an array of TrackedTrip objects to the device's storage.
    /// - Parameter trips: The array of TrackedTrip objects to save.
    func save(trips: [TrackedTrip]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(trips)
            UserDefaults.standard.set(data, forKey: trackedTripsKey)
        } catch {
            print("Error encoding tracked trips: \(error)")
        }
    }
    
    /// A helper method to add a new trip to the existing list.
    /// - Parameter trip: The new TrackedTrip to add.
    func add(trip: TrackedTrip) {
        var currentTrips = loadTrips()
        currentTrips.append(trip)
        save(trips: currentTrips)
    }
    
    /// A helper method to delete a trip.
    /// - Parameter trip: The TrackedTrip to delete.
    func delete(trip: TrackedTrip) {
        var currentTrips = loadTrips()
        currentTrips.removeAll { $0.id == trip.id }
        save(trips: currentTrips)
    }
}