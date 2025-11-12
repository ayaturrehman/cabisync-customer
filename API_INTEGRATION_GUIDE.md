# 🚀 Backend API Integration - Complete Guide

## ✅ What's Been Created

Your CabiSync Customer App now has **complete backend integration** with your Laravel API!

---

## 📂 Project Structure

```
lib/
├── models/                          # Data Models
│   ├── user.dart                    # User model
│   ├── fleet.dart                   # Fleet & Fare Pricing models
│   ├── booking.dart                 # Booking model
│   ├── driver.dart                  # Driver, Vehicle, DriverLocation
│   └── location_model.dart          # LocationModel, SavedLocation
│
├── services/                        # API Services
│   ├── api_service.dart             # Base API client with Dio
│   ├── auth_service.dart            # Authentication
│   ├── booking_service.dart         # Booking/Ride operations
│   ├── location_service.dart        # Location & geocoding
│   ├── notification_service.dart    # Firebase notifications
│   └── websocket_service.dart       # Real-time WebSocket
│
└── providers/                       # State Management (to be created)
```

---

## 🎯 API Configuration

### Base URL
```dart
https://app.cabisync.com/api/rider/
```

### Authentication
- **Method**: Laravel Sanctum (Bearer Token)
- **Token Storage**: flutter_secure_storage (encrypted)
- **Auto-injection**: All requests automatically include token

---

## 📦 Installed Dependencies

```yaml
✅ dio: ^5.4.0                      # HTTP client
✅ flutter_secure_storage: ^9.0.0   # Secure token storage
✅ geolocator: ^14.0.2              # Location services
✅ geocoding: ^4.0.0                # Address geocoding
✅ web_socket_channel: ^3.0.3       # WebSocket
✅ firebase_core: ^3.8.1            # Firebase
✅ firebase_messaging: ^15.1.6      # Push notifications
```

---

## 🔐 1. Authentication Service

### Features
- ✅ Send OTP
- ✅ Verify OTP
- ✅ Get current user
- ✅ Update profile
- ✅ Logout
- ✅ Auto token management

### Usage Example

```dart
import 'package:cabisync_customer/services/api_service.dart';
import 'package:cabisync_customer/services/auth_service.dart';

final apiService = ApiService();
final authService = AuthService(apiService);

// Send OTP
await authService.sendOTP('+1234567890');

// Verify OTP
final user = await authService.verifyOTP('+1234567890', '1234');
print('Logged in: ${user.name}');

// Get current user
final currentUser = await authService.getCurrentUser();

// Update profile
final updatedUser = await authService.updateProfile(
  name: 'John Doe',
  email: 'john@example.com',
);

// Logout
await authService.logout();

// Check if authenticated
final isAuth = await authService.isAuthenticated();
```

---

## 🚗 2. Booking Service

### Features
- ✅ Calculate fare (POST /fare/calc)
- ✅ Create booking
- ✅ Get booking details
- ✅ Get current active booking
- ✅ Get booking history
- ✅ Cancel booking
- ✅ Rate booking
- ✅ Schedule rides
- ✅ Update booking
- ✅ Send SOS

### Usage Example

```dart
import 'package:cabisync_customer/services/booking_service.dart';
import 'package:cabisync_customer/models/location_model.dart';
import 'package:cabisync_customer/models/fleet.dart';

final bookingService = BookingService(apiService);

// 1. Calculate Fare
final locations = [
  LocationModel(
    lat: 37.7749,
    lng: -122.4194,
    address: '123 Main St',
    type: 'pickup',
  ),
  LocationModel(
    lat: 37.8049,
    lng: -122.4294,
    address: '456 Office Bldg',
    type: 'dropoff',
  ),
];

final fleets = await bookingService.calculateFare(
  locations: locations,
  scheduleType: 'asap', // or 'schedule'
  bookingTime: DateTime.now(), // for scheduled rides
  distanceMi: 5.2, // optional
  durationMin: 15, // optional
);

// Display fleet options
for (final fleet in fleets) {
  print('${fleet.fleetType}: \$${fleet.pricing?.totalPrice}');
  print('Base: \$${fleet.pricing?.baseFare}');
  print('Distance: \$${fleet.pricing?.distanceFare}');
  print('Time: \$${fleet.pricing?.timeFare}');
  print('Service Fee: \$${fleet.pricing?.serviceFee}');
  print('Tax: \$${fleet.pricing?.tax}');
  print('---');
}

// 2. Create Booking
final booking = await bookingService.createBooking(
  fleetId: fleets.first.fleetId,
  locations: locations,
  scheduleType: 'asap',
  paymentMethod: 'cash',
  notes: 'Please call when arrived',
);

print('Booking created: ${booking.bookingNumber}');

// 3. Get Current Active Booking
final activeBooking = await bookingService.getCurrentBooking();
if (activeBooking != null) {
  print('Active ride: ${activeBooking.status}');
}

// 4. Get Booking History
final history = await bookingService.getBookingHistory(
  page: 1,
  perPage: 10,
  status: 'completed',
);

// 5. Cancel Booking
await bookingService.cancelBooking(
  booking.id!,
  reason: 'Changed my mind',
);

// 6. Rate Booking
await bookingService.rateBooking(
  booking.id!,
  rating: 5.0,
  feedback: 'Great driver!',
  tags: ['polite', 'safe_driving'],
);

// 7. Schedule a Ride (for later)
final scheduledBooking = await bookingService.createBooking(
  fleetId: 1,
  locations: locations,
  scheduleType: 'schedule',
  bookingTime: DateTime.now().add(Duration(hours: 2)),
  paymentMethod: 'card',
);

// 8. Send SOS
await bookingService.sendSOS(
  booking.id!,
  type: 'emergency',
  message: 'Need help',
  lat: 37.7749,
  lng: -122.4194,
);
```

---

## 📍 3. Location Service

### Features
- ✅ Get current GPS position
- ✅ Convert coordinates to address
- ✅ Search places
- ✅ Saved locations (CRUD)
- ✅ Recent locations
- ✅ Calculate distance
- ✅ Track position stream

### Usage Example

```dart
import 'package:cabisync_customer/services/location_service.dart';

final locationService = LocationService(apiService);

// Get current position
final position = await locationService.getCurrentPosition();
print('Current: ${position.latitude}, ${position.longitude}');

// Get address from coordinates
final address = await locationService.getAddressFromCoordinates(
  37.7749,
  -122.4194,
);
print('Address: $address');

// Search places
final places = await locationService.searchPlaces('coffee shop');
for (final place in places) {
  print(place.address);
}

// Get saved locations
final savedLocations = await locationService.getSavedLocations();

// Add saved location
final home = await locationService.addSavedLocation(
  label: 'Home',
  lat: 37.7749,
  lng: -122.4194,
  address: '123 Home Street',
);

// Delete saved location
await locationService.deleteSavedLocation(home.id!);

// Get recent locations
final recent = await locationService.getRecentLocations();

// Calculate distance between two points
final distance = locationService.calculateDistance(
  37.7749, -122.4194, // point 1
  37.8049, -122.4294, // point 2
);
print('Distance: ${distance.toStringAsFixed(2)} km');

// Track position in real-time
locationService.trackPosition().listen((position) {
  print('Position updated: ${position.latitude}, ${position.longitude}');
});
```

---

## 🔔 4. Notification Service

### Features
- ✅ Initialize Firebase Messaging
- ✅ Request permissions
- ✅ Register FCM token with backend
- ✅ Handle foreground notifications
- ✅ Handle notification taps

### Usage Example

```dart
import 'package:cabisync_customer/services/notification_service.dart';

final notificationService = NotificationService(apiService);

// Initialize (call in main.dart)
await notificationService.initialize();

// Token is automatically registered with backend
// Notifications are handled automatically
```

---

## 🌐 5. WebSocket Service

### Features
- ✅ Connect/disconnect
- ✅ Auto-reconnect
- ✅ Listen to driver location updates
- ✅ Listen to booking status changes
- ✅ Listen to chat messages
- ✅ Subscribe/unsubscribe to channels

### Usage Example

```dart
import 'package:cabisync_customer/services/websocket_service.dart';

final wsService = WebSocketService();

// Connect (after authentication)
await wsService.connect(authToken);

// Listen to driver location updates
wsService.listenToDriverLocation(bookingId).listen((location) {
  print('Driver at: ${location.lat}, ${location.lng}');
  // Update map marker
});

// Listen to booking status changes
wsService.listenToBookingStatus(bookingId).listen((data) {
  final newStatus = data['status'];
  print('Booking status: $newStatus');
  // Update UI
});

// Listen to chat messages
wsService.listenToChatMessages(bookingId).listen((message) {
  print('New message: ${message['text']}');
  // Add to chat list
});

// Disconnect
wsService.disconnect();
```

---

## 🎯 6. Error Handling

All services throw `ApiException` with:
- `message`: Human-readable error
- `statusCode`: HTTP status code
- `errors`: Validation errors (if any)

### Usage Example

```dart
try {
  final user = await authService.verifyOTP(phone, otp);
  // Success
} on ApiException catch (e) {
  if (e.isUnauthorized) {
    // Show login screen
  } else if (e.isValidationError) {
    // Show validation errors
    print(e.errors);
  } else if (e.isServerError) {
    // Show server error message
  } else {
    // Show general error
    print(e.message);
  }
} catch (e) {
  // Network error or other
  print('Unexpected error: $e');
}
```

---

## 📊 Complete Integration Example

Here's a complete flow from login to booking:

```dart
// 1. Login
try {
  await authService.sendOTP('+1234567890');
  final user = await authService.verifyOTP('+1234567890', '1234');
  
  // 2. Initialize services
  await notificationService.initialize();
  final token = await apiService.getToken();
  await wsService.connect(token!);
  
  // 3. Get current location
  final position = await locationService.getCurrentPosition();
  final pickupAddress = await locationService.getAddressFromCoordinates(
    position.latitude,
    position.longitude,
  );
  
  // 4. Create locations
  final locations = [
    LocationModel(
      lat: position.latitude,
      lng: position.longitude,
      address: pickupAddress,
      type: 'pickup',
    ),
    LocationModel(
      lat: 37.8049,
      lng: -122.4294,
      address: '456 Destination',
      type: 'dropoff',
    ),
  ];
  
  // 5. Calculate fare
  final fleets = await bookingService.calculateFare(
    locations: locations,
    scheduleType: 'asap',
  );
  
  // 6. Create booking
  final booking = await bookingService.createBooking(
    fleetId: fleets.first.fleetId,
    locations: locations,
    scheduleType: 'asap',
    paymentMethod: 'cash',
  );
  
  // 7. Listen to driver updates
  wsService.listenToDriverLocation(booking.id!).listen((location) {
    // Update driver marker on map
  });
  
  wsService.listenToBookingStatus(booking.id!).listen((data) {
    // Update booking status in UI
  });
  
  print('✅ Booking created: ${booking.bookingNumber}');
  
} on ApiException catch (e) {
  print('❌ Error: ${e.message}');
}
```

---

## 🔧 Next Steps

### 1. **Create Provider Classes** (State Management)

```dart
lib/providers/
├── auth_provider.dart
├── booking_provider.dart
├── location_provider.dart
└── websocket_provider.dart
```

### 2. **Connect Screens to Services**

Update existing screens:
- `login_screen.dart` → Use AuthService
- `otp_verification_screen.dart` → Use AuthService
- `map_screen.dart` → Use LocationService
- `ride_booking_screen.dart` → Use BookingService
- `ride_tracking_screen.dart` → Use WebSocketService
- `ride_history_screen.dart` → Use BookingService

### 3. **Add Firebase Setup**

**Android** (`android/app/google-services.json`):
Download from Firebase Console

**iOS** (`ios/Runner/GoogleService-Info.plist`):
Download from Firebase Console

### 4. **Test All Endpoints**

Create a test screen to verify:
- ✅ OTP sending/verification
- ✅ Fare calculation
- ✅ Booking creation
- ✅ WebSocket connection
- ✅ Notifications

---

## 📝 API Endpoints Summary

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/send-otp` | POST | Send OTP to phone |
| `/auth/verify-otp` | POST | Verify OTP & get token |
| `/auth/logout` | POST | Logout user |
| `/profile` | GET | Get user profile |
| `/profile` | PUT | Update user profile |
| `/fare/calc` | POST | Calculate fare for routes |
| `/bookings` | POST | Create new booking |
| `/bookings/{id}` | GET | Get booking details |
| `/bookings/current` | GET | Get active booking |
| `/bookings/history` | GET | Get ride history |
| `/bookings/{id}/cancel` | POST | Cancel booking |
| `/bookings/{id}/rate` | POST | Rate completed ride |
| `/bookings/scheduled` | GET | Get scheduled rides |
| `/bookings/{id}` | PUT | Update booking |
| `/bookings/{id}/sos` | POST | Send SOS alert |
| `/locations/saved` | GET | Get saved locations |
| `/locations/saved` | POST | Add saved location |
| `/locations/saved/{id}` | DELETE | Delete saved location |
| `/locations/recent` | GET | Get recent locations |
| `/places/search` | GET | Search places |
| `/fcm-token` | POST | Register FCM token |

---

## ✅ What You Have Now

- ✅ Complete data models for all entities
- ✅ Full API service layer with error handling
- ✅ Authentication with secure token storage
- ✅ Booking/fare calculation system
- ✅ Location services with GPS & geocoding
- ✅ WebSocket for real-time updates
- ✅ Push notification setup
- ✅ Auto token injection in requests
- ✅ Auto retry on connection errors
- ✅ Type-safe models with JSON serialization

---

## 🚀 Ready to Integrate!

**Want me to:**
1. Create Provider classes for state management?
2. Update existing screens to use real API?
3. Create a demo/test screen?
4. Set up Firebase configuration?
5. Add loading states to all screens?

**Just let me know what you want next!** 🎉
