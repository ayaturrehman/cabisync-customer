# CabiSync Customer App

A modern Flutter taxi/ride-hailing customer application with a minimalistic **BLACK & WHITE** color scheme.

## 🎨 Design System

### Color Palette
- **Primary**: Pure Black (#000000)
- **Secondary**: Dark Gray (#333333)
- **Accent**: Medium Gray (#666666)
- **Background**: Pure White (#FFFFFF)
- **Surface**: Light Gray (#F5F5F5)
- **Border**: Light Gray (#E0E0E0)

### Typography
- **Heading 1**: 32px, Bold
- **Heading 2**: 24px, Bold
- **Heading 3**: 18px, Semi-bold
- **Body**: 16px, Regular
- **Caption**: 14px, Regular

### Spacing
- **XS**: 4px
- **SM**: 8px
- **MD**: 16px
- **LG**: 24px
- **XL**: 32px
- **XXL**: 48px

### Border Radius
- **SM**: 8px
- **MD**: 12px
- **LG**: 16px
- **XL**: 24px

## 📁 Project Structure

```
lib/
├── config/
│   └── theme.dart              # Complete design system (colors, text styles, spacing)
├── widgets/
│   ├── custom_button.dart      # Filled, outline, text variants
│   ├── custom_text_field.dart  # Input field with validation
│   ├── custom_card.dart        # Reusable card component
│   ├── custom_app_bar.dart     # Standard app bar
│   ├── loading_overlay.dart    # Loading state overlay
│   ├── bottom_sheet_modal.dart # Bottom sheet wrapper
│   ├── shimmer_loading.dart    # Shimmer loading states
│   ├── location_search_bar.dart # Location search input
│   ├── ride_type_card.dart     # Ride type selection card
│   └── driver_info_card.dart   # Driver information display
├── screens/
│   ├── splash_screen.dart      # App splash with fade animation
│   ├── onboarding_screen.dart  # 3-slide onboarding
│   ├── auth/
│   │   ├── login_screen.dart   # Phone number login
│   │   └── otp_verification_screen.dart # OTP verification
│   ├── home/
│   │   ├── home_screen.dart    # Main screen with bottom nav
│   │   └── map_screen.dart     # Map view (placeholder)
│   ├── booking/
│   │   ├── location_picker_screen.dart  # Location selection
│   │   ├── ride_booking_screen.dart     # Ride type selection
│   │   ├── ride_tracking_screen.dart    # Live ride tracking
│   │   └── ride_history_screen.dart     # Past rides
│   └── profile/
│       └── profile_screen.dart  # User profile & settings
├── services/               # API services (to be implemented)
├── models/                 # Data models (to be implemented)
└── main.dart              # App entry point
```

## ✨ Features

### Implemented
1. ✅ **Splash Screen** - Fade-in animation with app logo
2. ✅ **Onboarding** - 3 minimal slides with black & white illustrations
3. ✅ **Authentication**
   - Phone number login
   - OTP verification with 4-digit input
   - Auto-navigation on OTP entry
4. ✅ **Home Screen**
   - Bottom navigation (Home, Rides, Profile)
   - Map placeholder
   - Location search
5. ✅ **Location Picker**
   - Search functionality
   - Recent locations
   - Current location option
6. ✅ **Ride Booking**
   - Multiple ride types (Economy, Comfort, Premium)
   - Price display
   - Smooth selection animations
7. ✅ **Ride Tracking**
   - Driver finding state
   - Driver info card with call/message
   - Cancel ride option
8. ✅ **Ride History**
   - Past rides list
   - Empty state
   - Shimmer loading
9. ✅ **Profile**
   - User information
   - Settings sections
   - Logout functionality

## 🎯 UI/UX Principles

- **Minimalism**: Clean design with lots of white space
- **High Contrast**: Black text on white backgrounds for readability
- **Visual Hierarchy**: Clear typography and spacing
- **Fast Animations**: All transitions are 200-300ms
- **Consistent**: Reusable components throughout

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository
```bash
cd cabisync_customer
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## 📦 Dependencies

```yaml
dependencies:
  # State Management
  provider: ^6.1.5+1
  get: ^4.6.6
  
  # Location & Maps
  geolocator: ^14.0.2
  geocoding: ^4.0.0
  google_maps_flutter: ^2.5.3
  
  # Networking
  dio: ^5.4.0
  http: ^0.13.6
  
  # Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  
  # UI & Animations
  flutter_animate: ^4.5.0
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  
  # Utilities
  intl: ^0.19.0
```

## 🎭 Animations

All animations use the black & white color scheme:
- **Fade In/Out**: Smooth opacity transitions
- **Slide**: Horizontal and vertical slides
- **Scale**: Growth/shrink animations
- **Shimmer**: White to light gray gradient loading
- **Ripple**: Gray ripple effects on buttons

Duration: 200-300ms for optimal UX

## 🔐 Security

- Phone number validation
- OTP-based authentication
- Secure token storage (flutter_secure_storage)
- API request interceptors ready

## 📱 Screens

### Navigation Flow
```
Splash → Onboarding → Login → OTP → Home
                                    ├── Map → Location Picker → Ride Booking → Tracking
                                    ├── Ride History
                                    └── Profile → Settings
```

## 🎨 Reusable Components

### Buttons
- **Filled**: Black background, white text
- **Outline**: Black border, black text
- **Text**: No background, black text

### Text Fields
- White background, black border
- Thicker border on focus
- Validation support

### Cards
- White background
- Optional black border
- Subtle shadow

### Loading States
- Shimmer effect (white to gray)
- Progress indicators
- Overlay with message

## 🔄 State Management

Ready for Provider/GetX implementation:
- Authentication state
- Location state
- Booking state
- User profile state

## 📝 TODO

- [ ] Integrate Google Maps
- [ ] Connect to backend API
- [ ] Implement payment gateway
- [ ] Add push notifications
- [ ] Real-time location tracking
- [ ] In-app chat with driver
- [ ] Ride rating system
- [ ] Promo codes & discounts

## 🤝 Contributing

This is a customer-facing taxi booking app. Follow the black & white design system strictly for consistency.

## 📄 License

Private project - All rights reserved

---

**Built with Flutter 💙 | Designed with Black & White 🖤🤍**
