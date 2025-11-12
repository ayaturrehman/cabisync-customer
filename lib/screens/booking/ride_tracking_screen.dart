import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../widgets/driver_info_card.dart';
import '../../widgets/custom_button.dart';

class RideTrackingScreen extends StatefulWidget {
  final String pickupLocation;
  final String destinationLocation;
  final String rideType;

  const RideTrackingScreen({
    super.key,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.rideType,
  });

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  String _status = 'Finding your driver...';
  bool _driverFound = false;

  @override
  void initState() {
    super.initState();
    _findDriver();
  }

  Future<void> _findDriver() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _driverFound = true;
        _status = 'Driver is on the way';
      });
    }
  }

  void _cancelRide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride?'),
        content: const Text('Are you sure you want to cancel this ride?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Container(
            color: AppColors.surface,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppBorderRadius.full),
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      size: 48,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Live Tracking Map',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.black,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppBorderRadius.md),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _status,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_driverFound) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Arriving in 5 min',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: AppAnimations.medium)
                      .slideY(begin: -0.2, end: 0),
                ),
                const Spacer(),
                if (_driverFound)
                  Container(
                    margin: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        DriverInfoCard(
                          name: 'Michael Johnson',
                          vehicleInfo: 'Toyota Camry • ${widget.rideType}',
                          plateNumber: 'ABC 123',
                          rating: 4.9,
                          onCallTap: () {},
                          onMessageTap: () {},
                        )
                            .animate()
                            .fadeIn(duration: AppAnimations.medium)
                            .slideY(begin: 0.3, end: 0),
                        const SizedBox(height: AppSpacing.md),
                        CustomButton(
                          text: 'Cancel Ride',
                          onPressed: _cancelRide,
                          variant: ButtonVariant.outline,
                          fullWidth: true,
                        )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.all(AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Finding your driver...',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Please wait while we match you with a driver',
                          style: AppTextStyles.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: AppAnimations.medium)
                      .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
