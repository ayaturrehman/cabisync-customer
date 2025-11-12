import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/place_autocomplete_input.dart';

class LocationPickerScreen extends StatefulWidget {
  final bool isPickup;

  const LocationPickerScreen({
    super.key,
    required this.isPickup,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _recentLocations = [
    'Home - 123 Main Street',
    'Work - 456 Office Building',
    'Mall - Central Shopping Center',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectLocation(String location, {double? lat, double? lng}) {
    Navigator.of(context).pop({
      'address': location,
      'lat': lat,
      'lng': lng,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: widget.isPickup ? 'Pickup Location' : 'Destination',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: PlaceAutocompleteInput(
              controller: _searchController,
              label: widget.isPickup ? 'Pickup Location' : 'Destination',
              onPlaceSelected: (place) {
                _selectLocation(
                  place.address,
                  lat: place.lat,
                  lng: place.lng,
                );
              },
            ),
          )
              .animate()
              .fadeIn(duration: AppAnimations.fast)
              .slideY(begin: -0.1, end: 0),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: AppColors.accent),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Recent Locations',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ..._recentLocations
                    .map((location) => _buildLocationTile(
                          location,
                          Icons.access_time,
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile(String location, IconData icon,
      {bool isSpecial = false}) {
    return InkWell(
      onTap: () => _selectLocation(location),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSpecial ? AppColors.black : AppColors.surface,
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: Icon(
                icon,
                color: isSpecial ? AppColors.white : AppColors.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                location,
                style: isSpecial
                    ? AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)
                    : AppTextStyles.body,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}
