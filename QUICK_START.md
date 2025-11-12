# 🚀 Quick Start Guide - CabiSync Customer App

## Prerequisites

- Flutter SDK 3.7.2 or higher
- Dart SDK
- Android Studio / Xcode
- VS Code or Android Studio IDE

## Installation

### 1. Navigate to project
```bash
cd cabisync_customer
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run the app
```bash
# For development
flutter run

# For specific device
flutter run -d <device_id>

# For web
flutter run -d chrome
```

## 🎨 Testing the App Flow

### 1. Splash Screen (3 seconds)
- Animated logo with fade-in
- Auto-navigates to onboarding

### 2. Onboarding (Skip or swipe)
- 3 slides with black & white illustrations
- Page indicators
- "Skip" or "Next" → "Get Started"

### 3. Login
- Enter any 10-digit phone number
- Click "Send OTP"

### 4. OTP Verification
- Enter 4 digits (any numbers)
- Auto-submits on 4th digit
- Or click "Verify"

### 5. Home Screen
Bottom navigation with 3 tabs:

#### Tab 1: Home (Map)
- Click pickup location field
- Select a location from recent or search
- Click destination field
- Select destination
- Click "Find a Ride"

#### Tab 2: Rides (History)
- View past rides
- Click any ride for details

#### Tab 3: Profile
- View user info
- Access settings
- Logout

### 6. Ride Booking
- Choose ride type (Economy/Comfort/Premium)
- See price
- Click "Book [Type] - [Price]"

### 7. Ride Tracking
- See "Finding driver" animation
- After 3 seconds, driver appears
- View driver info card
- Call or message driver (mock)
- Cancel ride if needed

## 📱 Features to Try

### Animations
- All screen transitions are smooth (200-300ms)
- Shimmer loading on ride history
- Button ripple effects
- OTP input auto-focus
- Ride type selection animation

### Interactions
- Bottom sheet modals
- Location search
- Form validation on login
- OTP countdown timer
- Empty states

## 🎯 Black & White Design

Notice the consistent design:
- **Black**: Primary actions, active states
- **White**: Backgrounds, inactive states  
- **Gray**: Borders, secondary text
- **High contrast** for accessibility

## 📂 Key Files to Explore

### Design System
```
lib/config/theme.dart
```
All colors, text styles, spacing, and theme configuration.

### Reusable Components
```
lib/widgets/
- custom_button.dart      # Try all 3 variants
- custom_text_field.dart  # See validation in action
- ride_type_card.dart     # Notice selection animation
- driver_info_card.dart   # Check the circular avatar
```

### Screens
```
lib/screens/
- splash_screen.dart       # Fade animations
- onboarding_screen.dart   # Page view with dots
- auth/login_screen.dart   # Phone validation
- home/map_screen.dart     # Location pickers
- booking/ride_booking_screen.dart  # Ride selection
```

## 🔧 Customization

### Change Colors
Edit `lib/config/theme.dart`:
```dart
class AppColors {
  static const primary = Color(0xFF000000); // Change this
  // ...
}
```

### Add New Screen
1. Create in `lib/screens/your_screen.dart`
2. Import theme: `import '../config/theme.dart';`
3. Use widgets: `import '../widgets/custom_button.dart';`

### Add API Integration
1. Create service in `lib/services/`
2. Use Dio (already in dependencies)
3. Add models in `lib/models/`

## 📊 Performance

### Current Stats
- No compilation errors
- Clean Flutter analyze
- Fast animations (200-300ms)
- Optimized with const constructors

### Test Performance
```bash
# Profile mode
flutter run --profile

# Check performance
flutter run --trace-startup
```

## 🐛 Troubleshooting

### "Package not found"
```bash
flutter clean
flutter pub get
```

### "No device found"
```bash
# List devices
flutter devices

# Run emulator
flutter emulators --launch <emulator_id>
```

### Build issues
```bash
# Android
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
flutter run

# iOS
flutter clean
cd ios && pod install && cd ..
flutter run
```

## 🎨 Design Tokens Reference

### Colors
```dart
AppColors.primary     // #000000
AppColors.secondary   // #333333
AppColors.accent      // #666666
AppColors.background  // #FFFFFF
AppColors.surface     // #F5F5F5
AppColors.border      // #E0E0E0
```

### Spacing
```dart
AppSpacing.xs   // 4px
AppSpacing.sm   // 8px
AppSpacing.md   // 16px
AppSpacing.lg   // 24px
AppSpacing.xl   // 32px
AppSpacing.xxl  // 48px
```

### Text Styles
```dart
AppTextStyles.heading1      // 32px Bold
AppTextStyles.heading2      // 24px Bold
AppTextStyles.heading3      // 18px Semi-bold
AppTextStyles.body          // 16px Regular
AppTextStyles.bodySecondary // 16px Gray
AppTextStyles.caption       // 14px Gray
AppTextStyles.hint          // 14px Light gray
```

### Border Radius
```dart
AppBorderRadius.sm   // 8px
AppBorderRadius.md   // 12px
AppBorderRadius.lg   // 16px
AppBorderRadius.xl   // 24px
AppBorderRadius.full // 999px (circle)
```

## 🚀 Next Steps

1. **Run the app**: `flutter run`
2. **Explore all screens**: Go through the complete flow
3. **Check animations**: Notice the smooth transitions
4. **Review code**: See how components are reused
5. **Customize**: Try changing colors or adding features

## 📸 Screenshots

Run the app to see:
- ✅ Minimalist black & white UI
- ✅ Smooth animations
- ✅ Clean typography
- ✅ Professional design
- ✅ Intuitive navigation

## 🎯 Production Checklist

Before deploying:
- [ ] Add real Google Maps API key
- [ ] Connect to backend API
- [ ] Implement authentication service
- [ ] Add payment integration
- [ ] Set up push notifications
- [ ] Add error tracking (Sentry/Firebase)
- [ ] Run performance tests
- [ ] Test on multiple devices
- [ ] Add app icons and splash
- [ ] Configure build variants

## 📞 Support

For issues or questions:
1. Check `IMPLEMENTATION_SUMMARY.md` for details
2. Review `PROJECT_README.md` for architecture
3. Explore code comments in files

---

**Happy Coding! 🎉**

The app is fully functional with mock data. Just add your backend API and Google Maps to make it production-ready!
