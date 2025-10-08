# Zenese
# File: backend/smart_api_router.py
# Description: The core logic for the Smart API Router.

import datetime
import requests # Used for making HTTP requests to flight APIs.

# --- Configuration ---
# In a real application, this would be loaded from a secure config file or environment variables.
API_PROVIDERS_CONFIG = {
    "amadeus": {
        "api_key": "AMADEUS_API_KEY_HERE",
        "quota": 2000, # Free calls per month
        "priority": 1 # Lower number means higher priority
    },
    "duffel": {
        "api_key": "DUFFEL_API_KEY_HERE",
        "quota": 1500,
        "priority": 2
    },
    "skyscanner": {
        "api_key": "SKYSCANNER_API_KEY_HERE",
        "quota": 1000,
        "priority": 3
    }
}

class SmartApiRouter:
    """
    Manages and routes requests to multiple flight API providers.
    - Tracks monthly usage quotas for free tiers.
    - Intelligently selects the best available provider based on priority and quota.
    - Normalizes data from different providers into a consistent format.
    """
    def __init__(self, config):
        self.providers = sorted(config.keys(), key=lambda p: config[p]['priority'])
        self.config = config
        
        # In a production environment, this usage tracking would be stored in a
        # persistent, fast-access database like Redis, not in memory.
        self.usage_stats = self._load_initial_usage()

    def _load_initial_usage(self):
        """
        Loads the current month's usage. In a real app, this would query Redis.
        For this example, we'll just initialize it to zero.
        """
        print("Initializing usage stats for the month...")
        # The key includes the year and month to automatically reset each month.
        current_month_key = datetime.datetime.now().strftime("%Y-%m")
        return {
            "month": current_month_key,
            "counts": {provider: 0 for provider in self.providers}
        }

    def _check_monthly_reset(self):
        """Checks if a new month has started and resets usage if needed."""
        current_month_key = datetime.datetime.now().strftime("%Y-%m")
        if self.usage_stats["month"] != current_month_key:
            print("New month detected! Resetting all API usage quotas.")
            self.usage_stats = self._load_initial_usage()

    def _normalize_data(self, provider_name, raw_data):
        """
        Translates raw data from a specific provider into our standard format.
        This is a critical step for keeping our application logic clean.
        """
        print(f"Normalizing data from {provider_name}...")
        
        # Example of a standardized format we want to return
        normalized_flights = []
        
        # --- This is where provider-specific translation logic would go ---
        # For example, Amadeus might call it 'price.total' and Skyscanner 'cost'.
        # We translate them all to a consistent 'price'.
        if provider_name == "amadeus":
            for flight in raw_data.get("flights", []):
                normalized_flights.append({
                    "price": float(flight.get("price", 0)),
                    "airline": flight.get("airline_code", "N/A"),
                    "departure_time": flight.get("departure", ""),
                    "arrival_time": flight.get("arrival", "")
                })
        # Add similar logic for 'duffel', 'skyscanner', etc.
        
        return normalized_flights

    def get_flight_prices(self, origin, destination, start_date, end_date):
        """
        The main method to get flight prices. It iterates through providers
        based on priority and available quota.
        """
        self._check_monthly_reset()

        for provider in self.providers:
            current_count = self.usage_stats["counts"][provider]
            quota_limit = self.config[provider]["quota"]

            if current_count < quota_limit:
                print(f"'{provider}' has quota available ({current_count}/{quota_limit}). Trying this provider.")
                
                try:
                    # --- Simulate making the actual API call ---
                    # In a real implementation, each provider would have its own method.
                    # e.g., self._call_amadeus_api(...)
                    # For now, we'll use placeholder mock data.
                    
                    mock_response = {
                        "flights": [
                            {"price": 157.50, "airline_code": "UA", "departure": "2025-11-17T09:00:00", "arrival": "2025-11-17T10:15:00"},
                            {"price": 189.00, "airline_code": "AA", "departure": "2025-11-17T11:30:00", "arrival": "2025-11-17T12:45:00"},
                        ]
                    }

                    # Increment usage count AFTER a successful call
                    self.usage_stats["counts"][provider] += 1
                    print(f"Successfully fetched data from '{provider}'. New count: {self.usage_stats['counts'][provider]}")
                    
                    # Normalize and return the data
                    return self._normalize_data(provider, mock_response)
                
                except requests.exceptions.RequestException as e:
                    print(f"Error calling '{provider}': {e}. Trying next provider.")
                    continue # Try the next provider in the list
            else:
                print(f"'{provider}' has exceeded its free quota for the month. Skipping.")

        # If the loop finishes without returning, all providers have failed or are out of quota.
        print("Error: All flight API providers are unavailable or have exceeded their quotas.")
        return None

# --- Example of how to use the router ---
if __name__ == "__main__":
    print("--- Zenese: Smart API Router Test ---")
    
    # Initialize the router with our configuration
    router = SmartApiRouter(API_PROVIDERS_CONFIG)
    
    # Make a request for flight data
    print("\nRequesting flight prices for SFO to SBA...")
    flights = router.get_flight_prices("SFO", "SBA", "2025-11-17", "2025-11-20")

    if flights:
        print("\n--- Successfully retrieved and normalized flight data ---")
        for flight in flights:
            print(f"  - Price: ${flight['price']:.2f}, Airline: {flight['airline']}, Departure: {flight['departure_time']}")
    else:
        print("\n--- Failed to retrieve flight data ---")

    # Example of exhausting a provider's quota for demonstration
    print("\n--- Simulating exhausting Amadeus's quota ---")
    router.usage_stats["counts"]["amadeus"] = 2000
    flights_after_exhaustion = router.get_flight_prices("SFO", "SBA", "2025-11-17", "2025-11-20")
    if flights_after_exhaustion:
        print("\nRouter successfully failed over to the next provider!")