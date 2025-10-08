Zenese — Product Requirements Document (PRD)
Version: 1.0
Date: October 7, 2025
Author: Product Team
Status: Finalized for MVP Development

1. Executive Summary
The Zenese is a conversational, AI-first mobile application designed to eliminate the friction and anxiety of travel planning. It begins by solving a single, high-value problem: tracking flight prices through a simple, voice-first interface. Over time, it will evolve into an indispensable companion that manages travel expenses, captures memories, and provides proactive assistance, creating a deeply personal and valuable travel history for the user.

2. The Problem
Modern travelers face a paradox of choice and complexity. They must navigate dozens of websites, manage complex spreadsheets for budgeting, and manually track flight prices, often missing the best deals. The process is fragmented, time-consuming, and stressful. Existing tools are largely form-based, requiring users to adapt to the software, rather than the software adapting to them.

3. The Vision & Solution
Our vision is to create a personal travel assistant that feels less like an app and more like a conversation with a knowledgeable friend. By leveraging Natural Language Understanding (NLU), our AI Co-Pilot will handle user requests in plain language.

The core solution is a single, continuous chat thread where the user can plan trips, log expenses, and save notes. The AI maintains context, understands user preferences over time, and progressively introduces new capabilities, creating a seamless and delightful experience.

4. Target Audience
Our initial target is "Alex, the Experience-Driven Millennial Traveler":

Age: 25-38

Tech Savviness: High. Comfortable with voice assistants and modern apps.

Travel Behavior: Flies 3-6 times per year for leisure. Values experiences over luxury but is budget-conscious.

Pain Point: Hates the "work" of finding the best flight deal and keeping track of travel spending. Wishes they had an easier way to remember their trips.

5. Product Roadmap
The product will be delivered in phased releases, each building on the last.

🟦 Phase 1: The Flight Tracker (MVP) — Build trust and delight with a magical, voice-first flight tracking experience.

🟩 Phase 2: The Smart Travel Ledger — Extend utility by becoming the central hub for tracking travel expenses and financial history.

🟨 Phase 3: The Full Travel Companion — Expand capabilities to include hotels, experiences, and journaling to capture the entire trip.

🟪 Phase 4: The Travel Yearbook — Solidify long-term retention by turning the user's travel history into a cherished, shareable asset.

6. Phase 1 (MVP) Requirements
6.1. User Experience & UI
[REQ-1.1] A single-thread, chat-based primary interface.

[REQ-1.2] Support for both voice (speech-to-text) and text input.

[REQ-1.3] A simple user dashboard listing currently tracked flights, their status, and the latest price.

[REQ-1.4] Secure user authentication and sign-in via Google Sign-In.

[REQ-1.5] Onboarding flow that briefly explains the app's core function and requests necessary permissions (e.g., notifications).

6.2. AI & Backend Logic
[REQ-2.1] The AI must use NLU to extract key travel intents: origin, destination, dates (or date ranges), and budget constraints.

[REQ-2.2] The system must maintain conversational context for the duration of a single planning session.

[REQ-2.3] A price alert system that runs background checks (e.g., daily) on tracked flights.

[REQ-2.4] The system must deliver price drop notifications via push notifications and optionally email.

[REQ-2.5] Basic reasoning to detect impossible scenarios (e.g., departure date after return date).

6.3. Infrastructure & APIs
[REQ-3.1] Integration with a third-party flight search API (e.g., Skyscanner, Amadeus) to fetch real-time flight options and prices.

[REQ-3.2] Secure database to store user profiles, tracked trips, and alert preferences.

6.4. MVP Success Metrics
Adoption: ≥70% of new users track at least one flight within their first session.

Efficiency: <15 seconds average time from initial voice command to confirmation of a tracked flight.

Retention: ≥60% of users who track a flight return to the app within the first week.

7. Monetization Strategy
Primary Model (Phases 2-3): Affiliate Revenue. Once booking assistance is introduced, the primary revenue stream will be commissions from flights and hotels booked through referral links.

Secondary Model (Phase 4+): Premium Subscription. A "Co-Pilot Pro" subscription will unlock advanced features like the Travel Yearbook, unlimited trip histories, and advanced analytics.

8. Out of Scope for MVP
No booking capabilities. The MVP is for tracking only.

No hotel, car, or experience search.

No expense logging (this is Phase 2).

iOS only. No Android or web application.