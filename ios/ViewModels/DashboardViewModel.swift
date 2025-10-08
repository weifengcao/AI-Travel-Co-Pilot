// Zenese
// File: ios/ViewModels/DashboardViewModel.swift
// Description: The ViewModel for the DashboardView, managing the list of tracked trips.

import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    
    // @Published property will cause the UI to update when the array changes.
    @Published var trackedTrips: [TrackedTrip] = []
    
    private let persistenceService = PersistenceService.shared
    private let apiService = APIService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load the trips from disk when the ViewModel is created.
        loadTrips()
        
        // In a real app, you would use the BGTaskScheduler framework to schedule this.
        // For demonstration, we'll just call it once on launch after a delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.refreshTripPrices()
        }
    }
    
    /// Loads the tracked trips from the persistence service.
    private func loadTrips() {
        self.trackedTrips = persistenceService.loadTrips()
    }
    
    /// Adds a new trip and saves the updated list.
    func add(trip: TrackedTrip) {
        trackedTrips.append(trip)
        persistenceService.save(trips: trackedTrips)
    }
    
    /// Deletes trips at the specified offsets.
    func deleteTrips(at offsets: IndexSet) {
        trackedTrips.remove(atOffsets: offsets)
        persistenceService.save(trips: trackedTrips)
    }
    
    /// Iterates through all tracked trips and fetches the latest price for each.
    func refreshTripPrices() {
        print("DashboardViewModel: Starting to refresh trip prices...")
        
        // Create a copy of the trips to avoid mutation issues while iterating.
        let tripsToRefresh = self.trackedTrips
        
        for (index, trip) in tripsToRefresh.enumerated() {
            // Create a request from the trip's data.
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let request = FlightSearchRequest(origin: trip.origin, destination: trip.destination, startDate: dateFormatter.string(from: trip.startDate), endDate: dateFormatter.string(from: trip.endDate))
            
            // Make the API call for the current trip.
            apiService.fetchFlightDetails(request: request)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to refresh price for \(trip.origin)-\(trip.destination): \(error.localizedDescription)")
                    }
                }, receiveValue: { [weak self] flightDetails in
                    guard let self = self else { return }
                    
                    // Create a new price data point.
                    let newPricePoint = PriceDataPoint(date: Date(), price: flightDetails.price)
                    
                    // Append the new price to the trip's history.
                    self.trackedTrips[index].priceHistory.append(newPricePoint)
                    
                    print("Successfully updated price for \(trip.origin)-\(trip.destination) to $\(flightDetails.price)")
                    
                    // After the last trip is updated, save the entire list back to disk.
                    if index == tripsToRefresh.count - 1 {
                        self.persistenceService.save(trips: self.trackedTrips)
                        print("DashboardViewModel: Finished refreshing all prices and saved to disk.")
                    }
                })
                .store(in: &cancellables)
        }
    }
}