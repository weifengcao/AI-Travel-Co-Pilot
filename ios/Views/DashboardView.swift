// AI Travel Co-Pilot
// File: ios/Views/DashboardView.swift
// Description: The main dashboard UI that displays a list of tracked flights.

import SwiftUI

struct DashboardView: View {
    
    // Create a state object for our ViewModel.
    // The @StateObject property wrapper ensures the ViewModel's lifecycle is tied to the view.
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                if viewModel.trackedTrips.isEmpty {
                    emptyStateView
                } else {
                    tripListView
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                // When the view appears, tell the ViewModel to load trips.
                // This ensures the list is up-to-date if a trip was added from the chat view.
                viewModel.loadTrips()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Your Co-Pilot")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("Tracked Flights")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var tripListView: some View {
        List {
            ForEach(viewModel.trackedTrips) { trip in
                TripCardView(trip: trip)
            }
            .onDelete(perform: deleteTrip)
        }
        .listStyle(PlainListStyle())
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Image(systemName: "airplane.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No Tracked Flights")
                .font(.headline)
                .padding(.top, 8)
            Text("Ask your Co-Pilot to find a flight to get started.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Functions
    
    private func deleteTrip(at offsets: IndexSet) {
        // Get the specific trip from the offsets and call the ViewModel's delete function.
        if let index = offsets.first {
            let tripToDelete = viewModel.trackedTrips[index]
            viewModel.delete(trip: tripToDelete)
        }
    }
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
