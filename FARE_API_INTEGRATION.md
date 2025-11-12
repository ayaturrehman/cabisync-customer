# Fare Calculation API Integration

## Overview
The app now calls real fare calculation APIs and displays live pricing information from the backend.

## Changes Made

### 1. API Service (`lib/api/api_service.dart`)
- Added `calculateFare()` method
- Endpoint: `POST /fare/calc`
- Includes authentication via Bearer token
- Handles timeout and error responses

### 2. Fare Service (`lib/services/fare_service.dart`)
- High-level service for fare calculations
- Two main methods:
  - `calculateFares()` - Basic fare calculation with pickup/dropoff
  - `calculateFaresWithMetrics()` - With pre-calculated distance/duration
- Automatically formats locations array for API

### 3. Fare Estimate Model (`lib/models/fare_estimate.dart`)
- Updated parser to handle API response format
- Parses string-based values like "28.23 miles" and "42 minutes"
- Helper methods for formatted display

### 4. Ride Booking Screen (`lib/screens/booking/ride_booking_screen.dart`)
**Complete rewrite to use real API:**
- Loads fare estimates on screen init
- Displays loading state while fetching
- Shows error state with retry button
- Lists all available ride options from API
- Dynamic pricing based on real data
- Supports scheduled rides (pass scheduledTime parameter)

**New required parameters:**
- `pickupLat`, `pickupLng` - Pickup coordinates
- `dropLat`, `dropLng` - Dropoff coordinates
- `scheduledTime` (optional) - For scheduled bookings

### 5. Route Editor Screen (`lib/screens/home/route_editor_screen.dart`)
- Updated navigation to pass coordinates and scheduled time
- Now provides all required data for fare calculation

## API Request Format

```json
{
  "booking_time": "2025-11-12T21:30:00.000Z",
  "schedule_type": "asap",
  "locations": [
    {
      "lat": 51.5074,
      "lng": -0.1278,
      "address": "London, UK",
      "type": "pickup"
    },
    {
      "lat": 51.5155,
      "lng": -0.0922,
      "address": "Shoreditch, London",
      "type": "dropoff"
    }
  ]
}
```

## API Response Format

```json
[
  {
    "fleet_id": "1",
    "fleet_type": "Economy",
    "base_fare": "5.00",
    "total_price": "12.50",
    "distance": "3.5 miles",
    "duration": "15 minutes"
  },
  {
    "fleet_id": "2",
    "fleet_type": "Comfort",
    "base_fare": "8.00",
    "total_price": "18.00",
    "distance": "3.5 miles",
    "duration": "12 minutes"
  }
]
```

## User Flow

1. User selects pickup and destination in Route Editor
2. User optionally schedules a time (or selects "ASAP")
3. User taps "Continue to Booking"
4. App navigates to Ride Booking Screen with coordinates and schedule
5. Screen automatically calls fare API on load
6. Loading spinner shows while fetching
7. Real fare options display with live pricing
8. User selects a ride option and books

## Error Handling

- Network errors show error message with retry button
- Authentication errors redirect to login
- Invalid locations show appropriate error messages
- No available rides displays helpful message

## Testing

To test the integration:
1. Ensure user is logged in (has auth token)
2. Select pickup and destination with valid coordinates
3. Continue to booking screen
4. Verify API call in network logs
5. Check that real pricing displays correctly
6. Test scheduled vs ASAP bookings
7. Test error scenarios (no network, invalid locations)

## Next Steps

- Add support for ride options filtering
- Implement surge pricing indicators
- Add estimated arrival time calculations
- Cache fare estimates for quick rebooking
- Add fare breakdown details view
