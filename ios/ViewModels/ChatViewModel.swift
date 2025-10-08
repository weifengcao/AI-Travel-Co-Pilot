// Zenese
// File: ios/ViewModels/ChatViewModel.swift
// Description: The ViewModel for the ChatView, managing the conversation and API calls.

import Foundation
import Combine
import FoundationModels
import Speech

@available(iOS 18.0, *)
class ChatViewModel: ObservableObject {
    
    // @Published properties will cause the UI to update when they change.
    @Published var messages: [ChatMessage] = []
    @Published var isTyping = false
    @Published var currentInput: String = ""
    @Published var isRecording: Bool = false
    
    // Use the protocol for testability
    private var apiService: APIServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // State to manage the conversation flow for tracking a flight.
    private var isAwaitingTrackingConfirmation = false
    private var lastFoundFlightDetails: FlightDetails?
    private var lastParsedQuery: ParsedFlightQuery?
    
    // The session for interacting with the on-device language model.
    private var languageModelSession: LanguageModelSession
    
    // The helper for speech-to-text
    private let speechRecognizer = SpeechRecognizer()
    
    // Allow injecting a different service for testing
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
        
        // Initialize the language model session with our custom flight search tool.
        self.languageModelSession = LanguageModelSession(tools: [FlightSearchTool()])
        
        // Initial welcome message from the AI.
        messages.append(ChatMessage(text: "Hi! I'm your Zenese. Where would you like to go? (e.g., SFO to LAX Nov 17 to Nov 20)", isFromUser: false))
        
        // Subscribe to speech recognizer updates
        setupSpeechRecognizerSubscriptions()
    }
    
    private func setupSpeechRecognizerSubscriptions() {
        speechRecognizer.$isRecording
            .receive(on: DispatchQueue.main)
            .assign(to: &$isRecording)
        
        speechRecognizer.$transcribedText
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentInput)
        
        speechRecognizer.finalTranscriptionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transcribedText in
                self?.currentInput = transcribedText
                self?.sendMessage()
            }
            .store(in: &cancellables)
    }
    
    /// Starts or stops voice recording.
    func toggleRecording() {
        if isRecording {
            speechRecognizer.stopRecording()
        } else {
            speechRecognizer.startRecording()
        }
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
            Task {
                await fetchFlightData(for: currentInput)
            }
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
    func fetchFlightData(for message: String) async {
        isTyping = true
        
        guard let parsedQuery = await parse(message: message) else {
            messages.append(ChatMessage(text: "I'm sorry, I didn't understand the destination, origin, or dates. Could you try a format like 'SFO to LAX Nov 17 to Nov 20'?", isFromUser: false))
            isTyping = false
            return
        }
        
        // Store the query for later, in case the user wants to track it.
        self.lastParsedQuery = parsedQuery
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.string(from: parsedQuery.startDate)
        let endDateString = dateFormatter.string(from: parsedQuery.endDate)
        
        let request = FlightSearchRequest(origin: parsedQuery.origin, destination: parsedQuery.destination, startDate: startDateString, endDate: endDateString)
        
        apiService.fetchFlightDetails(request: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isTyping = false
                if case .failure(let error) = completion {
                    self?.messages.append(ChatMessage(text: "Sorry, I couldn't fetch flight details right now. Error: \(error.localizedDescription)", isFromUser: false))
                }
            }, receiveValue: { [weak self] flightDetails in
                self?.lastFoundFlightDetails = flightDetails
                let responseText = "I found a flight for $ \(flightDetails.price). I can track the price for you and let you know if it drops. Should I add this to your dashboard?"
                self?.messages.append(ChatMessage(text: responseText, isFromUser: false))
                self?.isAwaitingTrackingConfirmation = true
            })
            .store(in: &cancellables)
    }
    
    // MARK: - On-Device NLP Parsing with Foundation Models
    
    /// Parses a user's text to extract flight query details using the on-device language model.
    func parse(message: String) async -> ParsedFlightQuery? {
        do {
            let response = try await languageModelSession.generate(with: message)
            
            // Check if the model decided to use our custom tool.
            if let toolCall = response.toolCalls.first(where: { $0.tool.name == "find_flights" }) {
                // The model returned a tool call, now we need to decode the arguments.
                let flightSearchTool = FlightSearchTool()
                let parsedArgs = try await flightSearchTool.decode(from: toolCall.arguments)
                
                // Convert the string dates to Date objects.
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                guard let startDate = dateFormatter.date(from: parsedArgs.startDate),
                      let endDate = dateFormatter.date(from: parsedArgs.endDate) else {
                    return nil
                }
                
                return ParsedFlightQuery(origin: parsedArgs.origin, destination: parsedArgs.destination, startDate: startDate, endDate: endDate)
            }
        } catch {
            print("Error processing message with Foundation Model: \(error)")
        }
        
        return nil
    }
    
    struct ParsedFlightQuery {
        let origin: String
        let destination: String
        let startDate: Date
        let endDate: Date
    }
}

// MARK: - Foundation Models Tool Definition

/// A tool that the on-device language model can use to understand flight search queries.
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
