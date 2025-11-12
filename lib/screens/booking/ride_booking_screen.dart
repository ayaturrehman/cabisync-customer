import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/ride_type_card.dart';
import '../../widgets/custom_button.dart';
import 'ride_tracking_screen.dart';

class RideBookingScreen extends StatefulWidget {
  final String pickupLocation;
  final String destinationLocation;

  const RideBookingScreen({
    super.key,
    required this.pickupLocation,
    required this.destinationLocation,
  });

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  int _selectedRideType = 0;
  bool _isBooking = false;

  final List<RideType> _rideTypes = [
    RideType(
      name: 'Economy',
      capacity: '4 seats',
      estimatedTime: '3 min',
      price: '\$12.50',
      icon: Icons.directions_car,
    ),
    RideType(
      name: 'Comfort',
      capacity: '4 seats',
      estimatedTime: '5 min',
      price: '\$18.00',
      icon: Icons.airport_shuttle,
    ),
    RideType(
      name: 'Premium',
      capacity: '4 seats',
      estimatedTime: '7 min',
      price: '\$25.00',
      icon: Icons.card_travel,
    ),
  ];

  Future<void> _bookRide() async {
    setState(() => _isBooking = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isBooking = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RideTrackingScreen(
            pickupLocation: widget.pickupLocation,
            destinationLocation: widget.destinationLocation,
            rideType: _rideTypes[_selectedRideType].name,
          ),
        ),
      );
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
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.black,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 30,
                              color: AppColors.border,
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.pickupLocation,
                                style: AppTextStyles.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                widget.destinationLocation,
                                style: AppTextStyles.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: AppAnimations.fast)
                      .slideY(begin: -0.1, end: 0),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Available Rides',
                    style: AppTextStyles.heading3,
                  )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: AppSpacing.md),
                  ..._rideTypes.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: RideTypeCard(
                        name: entry.value.name,
                        capacity: entry.value.capacity,
                        estimatedTime: entry.value.estimatedTime,
                        price: entry.value.price,
                        icon: entry.value.icon,
                        isSelected: _selectedRideType == entry.key,
                        onTap: () => setState(() => _selectedRideType = entry.key),
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
                text: 'Book ${_rideTypes[_selectedRideType].name} - ${_rideTypes[_selectedRideType].price}',
                onPressed: _bookRide,
                fullWidth: true,
                isLoading: _isBooking,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 600.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

class RideType {
  final String name;
  final String capacity;
  final String estimatedTime;
  final String price;
  final IconData icon;

  RideType({
    required this.name,
    required this.capacity,
    required this.estimatedTime,
    required this.price,
    required this.icon,
  });
}
