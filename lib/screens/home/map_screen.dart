import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import 'route_editor_screen.dart';
import '../booking/ride_history_screen.dart';
import '../profile/profile_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(51.5074, -0.1278), // London default
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() => _isLoadingLocation = false);
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _openRouteEditor() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RouteEditorScreen(currentPosition: _currentPosition),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Provider.of<AuthProvider>(context).user?.name ?? 'Guest',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          Provider.of<AuthProvider>(context).user?.email ?? '',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  ListTile(
                    leading: Icon(Icons.home, color: AppColors.black),
                    title: const Text('Home'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: Icon(Icons.history, color: AppColors.black),
                    title: const Text('Ride History'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      final nav = Navigator.of(context);
                      nav.pop();
                      nav.push(MaterialPageRoute(builder: (_) => const RideHistoryScreen()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person, color: AppColors.black),
                    title: const Text('Profile'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      final nav = Navigator.of(context);
                      nav.pop();
                      nav.push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.settings, color: AppColors.black),
                    title: const Text('Settings'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: Icon(Icons.help_outline, color: AppColors.black),
                    title: const Text('Help & Support'),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          // Google Map
          _isLoadingLocation
              ? Container(
                color: AppColors.surface,
                child: const Center(child: CircularProgressIndicator()),
              )
              : GoogleMap(
                initialCameraPosition: _defaultPosition,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                mapType: MapType.normal,
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (_currentPosition != null) {
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          zoom: 15,
                        ),
                      ),
                    );
                  } else {
                  }
                },
              ),

          // Top bar with menu and profile
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.md,
                            ),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.menu, color: AppColors.black),
                        ),
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
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.md,
                            ),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: AppColors.accent),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                "Hi, ${Provider.of<AuthProvider>(context).user?.name.split(' ').first ?? 'there'}!",
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
          ),

          // Destination input at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
                    margin: const EdgeInsets.all(AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: InkWell(
                      onTap: _openRouteEditor,
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.md,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: AppColors.accent),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              'Where are you going?',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: AppAnimations.medium)
                  .slideY(begin: 0.3, end: 0),
            ),
          ),

          // Current location button
          Positioned(
            right: AppSpacing.md,
            bottom: 140,
            child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    icon:
                        _isLoadingLocation
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(
                              Icons.my_location,
                              color: AppColors.black,
                            ),
                    onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms)
                .scale(begin: const Offset(0.8, 0.8)),
          ),
        ],
      ),
    );
  }
}
