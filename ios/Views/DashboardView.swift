// AI Travel Co-Pilot
// File: ios/Views/DashboardView.swift
// Description: The main dashboard UI that displays a list of tracked flights.

import SwiftUI

struct DashboardView: View {
    
    // Create a state object for our ViewModel.
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        // NOTE: The NavigationView was removed as it's already provided by MainView's TabView.
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
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.bottom)
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
            // FIXED: Correctly initialize TripCardView with the trip object.
            ForEach(viewModel.trackedTrips) { trip in
                TripCardView(trip: trip)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            // FIXED: Correctly call the ViewModel's delete function.
            .onDelete(perform: viewModel.deleteTrips)
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
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}

