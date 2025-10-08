// Zenese
// File: ios/Views/ChatView.swift
// Description: The main SwiftUI view for the chat interface.

import SwiftUI

struct ChatView: View {
    
    // Create and manage the lifecycle of our ViewModel.
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Zenese")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))

            // Message List
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                        }
                        
                        if viewModel.isTyping {
                            HStack {
                                ProgressView()
                                    .padding(.leading)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    // Automatically scroll to the newest message.
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input Bar
            HStack(spacing: 12) {
                TextField(viewModel.isRecording ? "Listening..." : "Ask about a flight...", text: $viewModel.currentInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(viewModel.isRecording)
                
                if viewModel.currentInput.isEmpty && !viewModel.isRecording {
                    Button(action: { viewModel.toggleRecording() }) {
                        Image(systemName: "mic.fill")
                            .font(.title2)
                    }
                }
                
                if viewModel.isRecording {
                    Button(action: { viewModel.toggleRecording() }) {
                        Image(systemName: "stop.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                } else if !viewModel.currentInput.isEmpty {
                    Button(action: { viewModel.sendMessage() }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                    }
                    .disabled(viewModel.isTyping)
                }
            }
            .padding()
            .background(Color(.systemGray6))
        }
    }
}

// A helper view to display a single chat message bubble.
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer() // Push user messages to the right
            }
            
            Text(message.text)
                .padding(12)
                .background(message.isFromUser ? Color.blue : Color(.systemGray4))
                .foregroundColor(.white)
                .cornerRadius(16)
            
            if !message.isFromUser {
                Spacer() // Push bot messages to the left
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
