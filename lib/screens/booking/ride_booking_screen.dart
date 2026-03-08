import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/ride_type_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/route_visualization.dart';
import '../../models/fare_estimate.dart';
import '../../services/fare_service.dart';
import '../../services/api_service.dart';
import '../../services/booking_service.dart';
import '../../models/location_model.dart';
import '../../providers/auth_provider.dart';
import 'ride_tracking_screen.dart';

class RideBookingScreen extends StatefulWidget {
  final String pickupLocation;
  final String destinationLocation;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final DateTime? scheduledTime;

  const RideBookingScreen({
    super.key,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    this.scheduledTime,
  });

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  int _selectedRideType = 0;
  bool _isBooking = false;
  bool _isLoadingFares = true;
  String? _errorMessage;
  List<FareEstimate> _fareEstimates = [];

  @override
  void initState() {
    super.initState();
    _loadFares();
  }

  Future<void> _loadFares() async {
    setState(() {
      _isLoadingFares = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        throw Exception('Authentication required');
      }

      final fares = await FareService.calculateFares(
        authToken: token,
        pickupLat: widget.pickupLat,
        pickupLng: widget.pickupLng,
        pickupAddress: widget.pickupLocation,
        dropoffLat: widget.dropLat,
        dropoffLng: widget.dropLng,
        dropoffAddress: widget.destinationLocation,
        bookingTime:
            widget.scheduledTime != null
                ? widget.scheduledTime!.toIso8601String()
                : null,
      );

      setState(() {
        _fareEstimates = fares;
        _isLoadingFares = false;
        // Reset selection if it's now out of bounds
        if (_selectedRideType >= fares.length) {
          _selectedRideType = 0;
        }
        if (fares.isEmpty) {
          _errorMessage = 'No rides available at this time';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingFares = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  IconData _getIconForFleetType(String fleetType) {
    switch (fleetType.toLowerCase()) {
      case 'economy':
        return Icons.directions_car;
      case 'comfort':
        return Icons.airport_shuttle;
      case 'premium':
      case 'luxury':
        return Icons.card_travel;
      default:
        return Icons.local_taxi;
    }
  }

  Future<String?> _getDefaultPaymentMethod() async {
    try {
      final apiService = ApiService();
      final response = await apiService.get('/list-saved-cards');
      final data = response.data as Map<String, dynamic>;
      final cards = data['cards'] as List<dynamic>? ?? [];
      if (cards.isEmpty) return null;
      // Use the default card, otherwise the first one
      final defaultCard = cards.firstWhere(
        (c) => c['is_default'] == true,
        orElse: () => cards.first,
      );
      return defaultCard['id'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _bookRide() async {
    if (_fareEstimates.isEmpty) return;

    setState(() {
      _isBooking = true;
      _errorMessage = null;
    });

    try {
      final selectedFare = _fareEstimates[_selectedRideType];
      final fleetId = selectedFare.fleetId ?? '';

      if (fleetId.isEmpty) {
        throw Exception('Invalid fleet selection. Please try again.');
      }

      final paymentMethodId = await _getDefaultPaymentMethod();
      if (paymentMethodId == null) {
        throw Exception('No payment method found. Please add a card before booking.');
      }

      final bookingService = BookingService(ApiService());
      final booking = await bookingService.createBooking(
        fleetId: fleetId,
        locations: [
          LocationModel(
            lat: widget.pickupLat,
            lng: widget.pickupLng,
            address: widget.pickupLocation,
            type: 'pickup',
          ),
          LocationModel(
            lat: widget.dropLat,
            lng: widget.dropLng,
            address: widget.destinationLocation,
            type: 'dropoff',
          ),
        ],
        bookingTime: widget.scheduledTime,
        scheduleType: widget.scheduledTime != null ? 'schedule' : 'asap',
        paymentMethodId: paymentMethodId,
      );

      if (mounted) {
        setState(() => _isBooking = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => RideTrackingScreen(
              pickupLocation: widget.pickupLocation,
              destinationLocation: widget.destinationLocation,
              rideType: selectedFare.fleetType ?? 'Economy',
              bookingId: booking.id,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBooking = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Booking failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(title: 'Choose Your Ride'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: RouteVisualization(
                          pickup: widget.pickupLocation,
                          dropoff: widget.destinationLocation,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: AppAnimations.fast)
                      .slideY(begin: -0.1, end: 0),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Available Rides',
                    style: AppTextStyles.heading3,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: AppSpacing.md),

                  // Loading state
                  if (_isLoadingFares)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  // Error state
                  if (_errorMessage != null && !_isLoadingFares)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 48,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _errorMessage!,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          CustomButton(
                            text: 'Retry',
                            icon: Icons.refresh,
                            variant: ButtonVariant.text,
                            onPressed: _loadFares,
                          ),
                        ],
                      ),
                    ),

                  // Fare options
                  if (!_isLoadingFares && _errorMessage == null)
                    ..._fareEstimates.asMap().entries.map((entry) {
                      final fare = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: RideTypeCard(
                              name: fare.fleetType ?? 'Standard',
                              capacity: '4 seats',
                              estimatedTime: fare.formattedDuration,
                              price: fare.formattedTotalFare,
                              icon: _getIconForFleetType(fare.fleetType ?? ''),
                              isSelected: _selectedRideType == entry.key,
                              onTap:
                                  () => setState(
                                    () => _selectedRideType = entry.key,
                                  ),
                            )
                            .animate()
                            .fadeIn(delay: ((entry.key + 2) * 100).ms)
                            .slideX(begin: 0.1, end: 0),
                      );
                    }),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: CustomButton(
                text:
                    _fareEstimates.isEmpty
                        ? 'Loading...'
                        : 'Book ${_fareEstimates[_selectedRideType].formattedTotalFare}',
                onPressed:
                    _fareEstimates.isEmpty || _isLoadingFares
                        ? null
                        : _bookRide,
                fullWidth: true,
                isLoading: _isBooking,
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
