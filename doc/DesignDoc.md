Zenese — Technical Design Document
Version: 1.0
Status: For Review
Related PRD: Zenese PRD v1.0

1. System Architecture Overview
The system is designed as a standard client-server architecture with a microservice-inspired backend to ensure scalability and maintainability. The core components are the iOS Client, a central AI Backend, a Smart API Router for external data, and a persistent database.

iOS Client: The user-facing application responsible for UI, voice input, and local notifications.

AI Backend: The brain of the operation. It handles business logic, NLU, and conversation management.

Smart API Router: A dedicated internal service that manages all third-party flight API integrations, providing a single, consistent interface to the AI Backend.

Database: Stores all user data, including profiles, tracked trips, and preferences.

Job Scheduler: A background service that triggers daily price checks for all active alerts.

2. Component Breakdown
2.1. iOS Client (Swift, SwiftUI)
ChatView: The primary interface, built in SwiftUI, displaying the conversation history.

VoiceInputManager: A wrapper around Apple's SFSpeechRecognizer to handle real-time speech-to-text transcription. It will manage microphone permissions and provide live feedback to the user.

APIService: A network layer to handle secure communication with the AI Backend via RESTful API calls.

DashboardView: A secondary view displaying a summary of tracked flights, populated by data from the backend.

NotificationService: Manages push notification registration with APNs and handles the display of incoming price alerts.

Authentication: Uses the Google Sign-In for iOS SDK to securely authenticate the user and retrieve a JWT for backend communication.

2.2. AI Backend (Python, FastAPI)
API Endpoints:

POST /v1/chat: Main endpoint for processing user messages (text or transcribed voice).

GET /v1/trips: Fetches all tracked trips for the authenticated user to populate the dashboard.

POST /v1/users: Creates a new user profile upon first sign-in.

NLU Service: Utilizes a pre-trained model library (e.g., spaCy or Rasa) to perform named entity recognition (NER) on user input, extracting ORIGIN, DESTINATION, DATE, and BUDGET.

Conversation Manager: A state machine that tracks the context of the current conversation (e.g., "user is currently planning a trip to SBA"). It uses this context to ask clarifying questions if needed.

Security: Endpoints will be protected, requiring a valid JWT passed in the Authorization header.

2.3. Smart API Router (Node.js, Express)
Core Function: Exposes a single internal endpoint (e.g., POST /search-flights) to the AI Backend.

Provider Adapters: Contains separate modules (amadeusAdapter.js, duffelAdapter.js) responsible for translating a standardized internal request into the specific format required by each third-party API.

Quota Management: Uses a Redis cache to track the number of calls made to each provider for the current month.

Waterfall Logic: Implements the prioritized routing logic to select the appropriate API provider based on available free quotas.

Data Normalization: Translates the varied responses from different providers into a single, consistent JSON structure before returning it to the AI Backend.

2.4. Database (PostgreSQL)
A relational database is chosen for its data integrity and structured query capabilities.

users table: id, google_id, email, created_at

tracked_trips table: id, user_id, origin_airport, destination_airport, start_date, end_date, max_budget, is_active

flight_prices table: id, trip_id, price, airline, timestamp

3. Data Flow: User Tracks a Flight
User speaks: "Find me flights from SFO to SBA, Nov 17–20 under $200."

iOS App: VoiceInputManager transcribes the audio to text. The text is sent to the AI Backend's /v1/chat endpoint with the user's JWT.

AI Backend:

Authenticates the user via the JWT.

The NLU Service extracts entities: SFO, SBA, 2025-11-17, 2025-11-20, $200.

The Conversation Manager confirms all required information is present.

It sends a request to the Smart API Router to find initial flight options.

Smart API Router:

Checks its Redis cache and sees that the Amadeus free quota is available.

Calls the Amadeus API via its adapter.

Receives the flight data, normalizes it into a standard format, and returns it to the AI Backend.

AI Backend:

Saves the trip details to the tracked_trips table in the database.

Constructs the response: "✈️ Got it! I found 3 flights under $200. I’ll track prices daily. Add this to your dashboard?"

Sends this response back to the iOS client.

iOS App: Renders the AI's response in the ChatView.