// AI Travel Co-Pilot
// File: ios/Models/ChatMessage.swift
// Description: Represents a single message in the chat interface.

import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
}
