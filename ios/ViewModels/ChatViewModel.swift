// AI Travel Co-Pilot
// File: ios/ViewModels/ChatViewModel.swift
// Description: The ViewModel for the ChatView, managing the conversation and API calls.

import Foundation
import NaturalLanguage
import Combine

class ChatViewModel: ObservableObject {
    
    // @Published properties will cause the UI to update when they change.
    @Published var messages: [ChatMessage] = []
    @Published var isTyping = false
    @Published var currentInput: String = ""
    
    // Use the protocol for testability
    private var apiService: APIServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // State to manage the conversation flow for tracking a flight.
    private var isAwaitingTrackingConfirmation = false
    private var lastFoundFlightDetails: FlightDetails?
    private var lastParsedQuery: ParsedFlightQuery?
    
    // Allow injecting a different service for testing
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
        // Initial welcome message from the AI.
        messages.append(ChatMessage(text: "Hi! I'm your AI Travel Co-Pilot. Where would you like to go? (e.g., SFO to LAX Nov 17 to Nov 20)", isFromUser: false))
    }
    
    /// Main function to handle sending a message from the user.
    func sendMessage() {
        guard !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(text: currentInput, isFromUser: true)
        messages.append(userMessage)
        
        // Check if the user is confirming a previously found flight.
        if isAwaitingTrackingConfirmation {
            handleTrackingConfirmation(for: currentInput)
        } else {
            // Otherwise, treat it as a new flight query.
            fetchFlightData(for: currentInput)
        }
        
        // Clear the input field.
        currentInput = ""
    }
    
    /// Handles the user's response after being asked to track a flight.
    private func handleTrackingConfirmation(for message: String) {
        let affirmativeResponses = ["yes", "ok", "sure", "yep", "confirm", "track it"]
        let isAffirmative = affirmativeResponses.contains { message.lowercased().contains($0) }
        
        if isAffirmative, let details = lastFoundFlightDetails, let query = lastParsedQuery {
            // 1. Create the TrackedTrip object.
            let initialPricePoint = PriceDataPoint(date: Date(), price: details.price)
            // FIXED: Replaced placeholder with UUID()
            let newTrip = TrackedTrip(
                id: UUID(),
                origin: query.origin,
                destination: query.destination,
                startDate: query.startDate,
                endDate: query.endDate,
                priceHistory: [initialPricePoint]
            )
            
            // 2. Use the PersistenceService to save it.
            PersistenceService.shared.add(trip: newTrip)
            
            // 3. Confirm with the user.
            messages.append(ChatMessage(text: "Great! I've saved this trip to your dashboard and will monitor the price for you.", isFromUser: false))
            
        } else {
            // User declined or gave an unclear answer.
            messages.append(ChatMessage(text: "No problem. Let me know if you have another trip in mind!", isFromUser: false))
        }
        
        // 4. Reset the state.
        isAwaitingTrackingConfirmation = false
        lastFoundFlightDetails = nil
        lastParsedQuery = nil
    }
    
    /// Parses the user's message and fetches flight data from the backend.
    func fetchFlightData(for message: String) {
        isTyping = true
        
        // FIXED: Corrected function name from xparse to parse.
        guard let parsedQuery = parse(message: message) else {
            messages.append(ChatMessage(text: "I'm sorry, I didn't understand the destination, origin, or dates. Could you try a format like 'SFO to LAX Nov 17 to Nov 20'?", isFromUser: false))
            isTyping = false
            return
        }
        
        // Store the query for later, in case the user wants to track it.
        self.lastParsedQuery = parsedQuery
        
        // FIXED: Use a specific date formatter to match backend expectations.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.string(from: parsedQuery.startDate)
        let endDateString = dateFormatter.string(from: parsedQuery.endDate)
        
        // Create the request object for our API.
        let request = FlightSearchRequest(origin: parsedQuery.origin, destination: parsedQuery.destination, startDate: startDateString, endDate: endDateString)
        
        // Make the API call.
        apiService.fetchFlightDetails(request: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isTyping = false
                if case .failure(let error) = completion {
                    self?.messages.append(ChatMessage(text: "Sorry, I couldn't fetch flight details right now. Error: \(error.localizedDescription)", isFromUser: false))
                }
            }, receiveValue: { [weak self] flightDetails in
                // Store flight details for potential tracking.
                self?.lastFoundFlightDetails = flightDetails
                
                // Format the AI's response.
                let responseText = "I found a flight for $ \(flightDetails.price). I can track the price for you and let you know if it drops. Should I add this to your dashboard?"
                self?.messages.append(ChatMessage(text: responseText, isFromUser: false))
                
                // Set the flag to indicate we're waiting for a confirmation.
                self?.isAwaitingTrackingConfirmation = true
            })
            .store(in: &cancellables)
    }
    
    // MARK: - On-Device NLP Parsing
    
    /// Parses a user's text to extract flight query details using on-device frameworks.
    func parse(message: String) -> ParsedFlightQuery? {
        // ... NOTE: This uses Apple's on-device Natural Language frameworks.
        
        var origin: String?
        var destination: String?
        var dates: [Date] = []
        
        // 1. Use NLTagger for Entity Recognition (Airports)
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = message
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        
        tagger.enumerateTags(in: message.startIndex..<message.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if tag == .placeName {
                let airportCode = String(message[tokenRange]).uppercased()
                if origin == nil {
                    origin = airportCode
                } else if destination == nil {
                    destination = airportCode
                }
            }
            return true
        }
        
        // 2. Use NSDataDetector for finding dates
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
            let matches = detector.matches(in: message, options: [], range: NSRange(location: 0, length: message.utf16.count))
            
            for match in matches {
                if let date = match.date {
                    dates.append(date)
                }
            }
        } catch {
            print("Error creating date detector: \(error)")
        }
        
        // 3. Validate and return the final query object
        guard let originUnwrapped = origin, let destinationUnwrapped = destination, dates.count >= 2 else {
            return nil
        }
        
        let sortedDates = dates.sorted()
        
        return ParsedFlightQuery(origin: originUnwrapped, destination: destinationUnwrapped, startDate: sortedDates[0], endDate: sortedDates[1])
    }
    
    struct ParsedFlightQuery {
        let origin: String
        let destination: String
        let startDate: Date
        let endDate: Date
    }
}
