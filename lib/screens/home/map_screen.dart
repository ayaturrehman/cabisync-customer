import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../widgets/location_search_bar.dart';
import '../../widgets/custom_button.dart';
import '../booking/location_picker_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _pickupLocation;
  String? _destinationLocation;

  void _selectLocation(bool isPickup) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(isPickup: isPickup),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (isPickup) {
          _pickupLocation = result;
        } else {
          _destinationLocation = result;
        }
      });
    }
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
                    'Map View',
                    style: AppTextStyles.bodySecondary,
                  ),
                  Text(
                    '(Google Maps integration here)',
                    style: AppTextStyles.caption,
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
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.menu, color: AppColors.black),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppBorderRadius.md),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: AppColors.accent),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Welcome back!',
                                style: AppTextStyles.body,
                              ),
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
                Container(
                  margin: const EdgeInsets.all(AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Where to?',
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      LocationSearchBar(
                        hint: _pickupLocation ?? 'Pickup location',
                        prefixIcon: Icons.location_on,
                        readOnly: true,
                        onTap: () => _selectLocation(true),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      LocationSearchBar(
                        hint: _destinationLocation ?? 'Where are you going?',
                        prefixIcon: Icons.search,
                        readOnly: true,
                        onTap: () => _selectLocation(false),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CustomButton(
                        text: 'Find a Ride',
                        onPressed: (_pickupLocation != null &&
                                _destinationLocation != null)
                            ? () {
                                Navigator.of(context).pushNamed('/ride-booking');
                              }
                            : null,
                        fullWidth: true,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: AppAnimations.medium)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
