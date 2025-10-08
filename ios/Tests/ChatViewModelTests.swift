// Zenese
// File: ios/AI_Travel_Co_PilotTests/ChatViewModelTests.swift
// Description: Unit tests for the ChatViewModel to ensure parsing logic is correct.

import XCTest
// We need to import the main app target to access its classes.
@testable import AI_Travel_Co_Pilot

class ChatViewModelTests: XCTestCase {

    var viewModel: ChatViewModel!

    // This method is called before each test function in the class is called.
    override func setUp() {
        super.setUp()
        // Create a new instance of our ViewModel for each test to ensure a clean slate.
        viewModel = ChatViewModel()
    }

    // This method is called after each test function in the class is called.
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Parsing Logic Tests

    /// Tests a standard, well-formed flight query.
    func testParse_WithValidQuery_ShouldSucceed() {
        // 1. Arrange
        let message = "Find me a flight from SFO to LAX on Nov 17 to Nov 20"
        
        // 2. Act
        let result = viewModel.parse(message: message)
        
        // 3. Assert
        XCTAssertNotNil(result, "The parsing result should not be nil for a valid query.")
        XCTAssertEqual(result?.origin, "SFO", "The origin should be correctly parsed.")
        XCTAssertEqual(result?.destination, "LAX", "The destination should be correctly parsed.")
        
        // Date validation (this is a simplified check for a unit test)
        XCTAssertNotNil(result?.startDate, "Start date should be parsed.")
        XCTAssertNotNil(result?.endDate, "End date should be parsed.")
    }

    /// Tests a query where airport codes are in lowercase.
    func testParse_WithLowercaseAirports_ShouldSucceed() {
        // 1. Arrange
        let message = "Flights from lhr to jfk next month"
        
        // 2. Act
        let result = viewModel.parse(message: message)
        
        // 3. Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.origin, "LHR", "The parser should correctly uppercase the origin.")
        XCTAssertEqual(result?.destination, "JFK", "The parser should correctly uppercase the destination.")
    }
    
    /// Tests a query with missing information (no dates).
    func testParse_WithMissingDates_ShouldReturnNil() {
        // 1. Arrange
        let message = "I want to fly from JFK to MIA"
        
        // 2. Act
        let result = viewModel.parse(message: message)
        
        // 3. Assert
        XCTAssertNil(result, "The parser should return nil when dates are missing.")
    }

    /// Tests a query with only one airport code.
    func testParse_WithMissingDestination_ShouldReturnNil() {
        // 1. Arrange
        let message = "Flights from CDG on December 1st to 5th"
        
        // 2. Act
        let result = viewModel.parse(message: message)
        
        // 3. Assert
        XCTAssertNil(result, "The parser should return nil when a destination is missing.")
    }
    
    /// Tests a non-flight-related message.
    func testParse_WithGreeting_ShouldReturnNil() {
        // 1. Arrange
        let message = "Hello, how are you?"
        
        // 2. Act
        let result = viewModel.parse(message: message)
        
        // 3. Assert
        XCTAssertNil(result, "The parser should return nil for non-flight-related queries.")
    }
}