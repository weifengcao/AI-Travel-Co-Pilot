# Zenese
# File: backend/main.py
# Description: The main FastAPI application to serve our Smart API Router.

from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional

# Import our core logic from the other file
from smart_api_router import SmartApiRouter, API_PROVIDERS_CONFIG

# --- API Data Models ---
# Using Pydantic models ensures our API has strong data validation and good documentation.

class FlightSearchRequest(BaseModel):
    """Defines the structure for a flight search request from the app."""
    origin: str
    destination: str
    start_date: str
    end_date: str

class FlightDetails(BaseModel):
    """Defines the structure for a single flight result we send back."""
    price: float
    airline: str
    departure_time: str
    arrival_time: str

class FlightSearchResponse(BaseModel):
    """Defines the structure for the list of flights we return."""
    flights: Optional[List[FlightDetails]]


# --- FastAPI Application Setup ---

# Initialize the FastAPI application
app = FastAPI(
    title="Zenese API",
    description="API for fetching flight data and managing user travel.",
    version="1.0.0"
)

# Create a single, long-lived instance of our router.
# This ensures our API usage stats are maintained across requests.
smart_router = SmartApiRouter(API_PROVIDERS_CONFIG)


# --- API Endpoints ---

@app.get("/")
def read_root():
    """A simple root endpoint to confirm the server is running."""
    return {"status": "Zenese API is running!"}


@app.post("/search-flights", response_model=FlightSearchResponse)
def search_flights(request: FlightSearchRequest):
    """
    The primary endpoint for the iOS app to search for flights.
    It takes the user's search criteria, uses the Smart API Router to fetch
    the data, and returns it in a structured JSON format.
    """
    print(f"Received flight search request: {request.origin} to {request.destination}")
    
    flight_results = smart_router.get_flight_prices(
        origin=request.origin,
        destination=request.destination,
        start_date=request.start_date,
        end_date=request.end_date
    )

    if flight_results is None:
        # Return an empty list if no flights were found or an error occurred.
        return {"flights": []}
        
    return {"flights": flight_results}

# To run this server:
# 1. Make sure you have fastapi and uvicorn installed:
#    pip install fastapi "uvicorn[standard]"
# 2. In your terminal, navigate to the `backend` directory.
# 3. Run the command:
#    uvicorn main:app --reload