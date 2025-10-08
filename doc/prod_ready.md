Zenese — Production Readiness Checklist
This document outlines the final infrastructure, configuration, and monitoring tasks required to launch the Zenese service to the public. All items must be completed and verified before submitting the iOS app to the App Store.

Phase 1: Backend Infrastructure (Google Cloud Platform)
[ ] Provision Production Database:

[ ] Set up a managed PostgreSQL instance on Google Cloud SQL.

[ ] Configure access controls to only allow connections from our Cloud Run service.

[ ] Create a separate, non-production "staging" database for final testing.

[ ] Set Up Production Redis:

[ ] Provision a Google Cloud Memorystore (Redis) instance for our caching layer.

[ ] Configure access controls.

[ ] Secrets Management:

[ ] Store all third-party flight API keys securely in Google Secret Manager.

[ ] Grant the Cloud Run service account permission to access these secrets at runtime.

[ ] Verify that all GitHub Actions secrets (GCP_PROJECT_ID, etc.) are correctly configured for the production environment.

[ ] Configure Monitoring & Logging:

[ ] Enable Google Cloud's operations suite (formerly Stackdriver) for the Cloud Run service.

[ ] Set up a basic monitoring dashboard to track CPU usage, memory, and request latency.

[ ] Create a log-based alert that notifies the team of any critical errors (e.g., HTTP 500 responses).

Phase 2: iOS App Finalization
[ ] Configure Production Backend URL:

[ ] Update the APIService.swift file to point to the final URL of our deployed Cloud Run service.

[ ] Integrate Analytics SDK:

[ ] Integrate a production-ready analytics SDK (e.g., Firebase Analytics).

[ ] Add event tracking for key success metrics defined in the PRD, such as flight_tracked, user_signed_in, and dashboard_viewed.

[ ] App Store Connect Preparation:

[ ] Prepare final app screenshots for all required device sizes.

[ ] Write the app description, keywords, and promotional text.

[ ] Finalize the app's Privacy Policy and link it within App Store Connect.

Phase 3: Final Go-Live Checks
[ ] End-to-End Testing:

[ ] Perform a full end-to-end test using a build from TestFlight connected to the live production backend.

[ ] Verify that a user can sign in, track a flight, see it on the dashboard, and sign out without errors.

[ ] Submit to App Store:

[ ] Submit the final build for review by Apple.