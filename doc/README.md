ZeneseWelcome to the Zenese project! This repository contains the source code for a conversational AI iOS application that helps users find, track, and manage their flights.

Project Overview
The project is divided into two main components:

Backend: A Python-based backend powered by FastAPI that serves as the "brain" of the application. It includes a Smart API Router to intelligently manage and query third-party flight APIs.

iOS App: A native iOS application built with SwiftUI that provides a beautiful, conversational user interface for interacting with the AI Co-Pilot.

Getting Started
Prerequisites
For Backend:

Python 3.9+

Docker and Docker Compose

For iOS:

macOS with Xcode 14+

An Apple Developer account (for some features)

Running the Backend with Docker (Recommended)
The entire backend environment, including the Python server and the Redis database, is managed by Docker. This is the simplest way to get started.

Navigate to the backend directory:

cd backend

Build and run the services:

docker-compose up --build

This command will build the Docker image for the web server, pull the Redis image, and start both containers. The API will then be available at http://localhost:8000.

Backend Setup (Manual)
If you prefer to run the backend without Docker:

Navigate to the backend directory:

cd backend

Create a virtual environment:

python3 -m venv venv
source venv/bin/activate

Install dependencies:

pip install -r requirements.txt

Run the FastAPI server:

uvicorn main:app --reload

The API will be available at http://localhost:8000. You will also need to have a Redis server running locally on its default port.

iOS Project Structure
The iOS project follows a clean, scalable MVVM (Model-View-ViewModel) architecture.

ios/
├── App/
│   └── AI_Travel_Co_PilotApp.swift
├── Models/
│   ├── ChatMessage.swift
│   ├── FlightModels.swift
│   └── TrackedTrip.swift
├── Views/
│   ├── ChatView.swift
│   ├── DashboardView.swift
│   ├── MainView.swift
│   ├── OnboardingView.swift
│   ├── SettingsView.swift
│   └── TripCardView.swift
├── ViewModels/
│   ├── ChatViewModel.swift
│   └── DashboardViewModel.swift
├── Services/
│   ├── APIService.swift
│   ├── AuthenticationService.swift
│   └── PersistenceService.swift
└── Tests/
    ├── AI_Travel_Co_PilotTests/
    │   ├── ChatViewModelTests.swift
    │   └── Mocks/
    │       └── MockAPIService.swift

This README provides a comprehensive guide to getting started with the Zenese project.