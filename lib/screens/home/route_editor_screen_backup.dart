import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/place_autocomplete_input.dart';
import '../../widgets/custom_button.dart';
import '../../services/google_places_service.dart';
import '../booking/ride_booking_screen.dart';

class LocationItem {
  final String id;
  final String address;
  final double? lat;
  final double? lng;

  LocationItem({required this.id, required this.address, this.lat, this.lng});
}

class RouteEditorScreen extends StatefulWidget {
  final Position? currentPosition;

  const RouteEditorScreen({super.key, this.currentPosition});

  @override
  State<RouteEditorScreen> createState() => _RouteEditorScreenState();
}

class _RouteEditorScreenState extends State<RouteEditorScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  LocationItem? _pickupLocation;
  LocationItem? _destinationLocation;
  List<LocationItem> _stops = [];
  DateTime? _scheduledDateTime;
  bool _isLoadingPickup = true;
  bool _isCalculatingFare = false;
  
  // For handling suggestions
  List<PlacePrediction> _suggestions = [];
  bool _isSearching = false;
  String _activeField = ''; // 'pickup' or 'destination'
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    
    // Listen to text changes for suggestions
    _pickupController.addListener(_onPickupTextChanged);
    _destinationController.addListener(_onDestinationTextChanged);
    
    // Auto-focus destination field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _destinationFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pickupController.removeListener(_onPickupTextChanged);
    _destinationController.removeListener(_onDestinationTextChanged);
    _pickupController.dispose();
    _destinationController.dispose();
    _pickupFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }
  
  void _onPickupTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_pickupController.text.isNotEmpty) {
        _searchPlaces(_pickupController.text, 'pickup');
      } else {
        setState(() {
          _suggestions = [];
          _activeField = '';
        });
      }
    });
  }
  
  void _onDestinationTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_destinationController.text.isNotEmpty) {
        _searchPlaces(_destinationController.text, 'destination');
      } else {
        setState(() {
          _suggestions = [];
          _activeField = '';
        });
      }
    });
  }
  
  Future<void> _searchPlaces(String query, String field) async {
    setState(() {
      _isSearching = true;
      _activeField = field;
    });
    
    try {
      final results = await GooglePlacesService.getPlacePredictions(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
    }
  }
  
  Future<void> _selectSuggestion(PlacePrediction prediction) async {
    // Fetch full place details with coordinates
    final placeDetails = await GooglePlacesService.getPlaceDetails(prediction.placeId);
    
    if (placeDetails == null) return;
    
    if (_activeField == 'pickup') {
      setState(() {
        _pickupLocation = LocationItem(
          id: placeDetails.placeId,
          address: placeDetails.formattedAddress,
          lat: placeDetails.latitude,
          lng: placeDetails.longitude,
        );
        _pickupController.text = prediction.mainText;
        _suggestions = [];
        _activeField = '';
      });
      FocusScope.of(context).unfocus();
    } else if (_activeField == 'destination') {
      setState(() {
        _destinationLocation = LocationItem(
          id: placeDetails.placeId,
          address: placeDetails.formattedAddress,
          lat: placeDetails.latitude,
          lng: placeDetails.longitude,
        );
        _destinationController.text = prediction.mainText;
        _suggestions = [];
        _activeField = '';
      });
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _loadCurrentLocation() async {
    try {
      Position? position = widget.currentPosition;

      // If no position provided, try to get current location
      if (position == null) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          final permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse) {
            position = await Geolocator.getCurrentPosition();
          }
        }
      }

      if (position != null) {
        // Reverse geocode to get address
        final placeDetails = await GooglePlacesService.reverseGeocode(
          position.latitude,
          position.longitude,
        );

        if (placeDetails != null && mounted) {
          setState(() {
            _pickupLocation = LocationItem(
              id: 'current_location',
              address: placeDetails.formattedAddress,
              lat: position!.latitude,
              lng: position.longitude,
            );
            _pickupController.text = placeDetails.formattedAddress;
            _isLoadingPickup = false;
          });
        }
      } else {
        // Fallback if location not available
        setState(() {
          _pickupController.text = 'Current Location';
          _isLoadingPickup = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pickupController.text = 'Current Location';
          _isLoadingPickup = false;
        });
      }
    }
  }

  void _selectScheduleTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null && mounted) {
        setState(() {
          _scheduledDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _addStop() {
    if (_stops.length >= 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Maximum 4 stops allowed')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _StopInputSheet(
            onStopAdded: (address, lat, lng) {
              setState(() {
                _stops.add(
                  LocationItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    address: address,
                    lat: lat,
                    lng: lng,
                  ),
                );
              });
            },
          ),
    );
  }

  void _removeStop(int index) {
    setState(() {
      _stops.removeAt(index);
    });
  }

  void _reorderStop(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _stops.removeAt(oldIndex);
      _stops.insert(newIndex, item);
    });
  }

  Future<void> _findRoute() async {
    if (_pickupLocation == null || _destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup and destination')),
      );
      return;
    }

    // Build destination text with stops info
    String destination = _destinationLocation!.address;
    if (_stops.isNotEmpty) {
      destination += ' (${_stops.length} stop${_stops.length > 1 ? 's' : ''})';
    }

    // Navigate to ride booking screen with route details
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => RideBookingScreen(
              pickupLocation: _pickupLocation!.address,
              destinationLocation: destination,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(title: 'Plan Your Route'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pickup Location
                  _buildLocationCard(
                    title: 'Pickup Location',
                    controller: _pickupController,
                    icon: Icons.radio_button_checked,
                    iconColor: AppColors.black,
                    isLoading: _isLoadingPickup,
                    onPlaceSelected: (place) {
                      setState(() {
                        _pickupLocation = LocationItem(
                          id: place.placeId,
                          address: place.address,
                          lat: place.lat,
                          lng: place.lng,
                        );
                      });
                    },
                  ).animate().fadeIn(duration: AppAnimations.fast),

                  // Stops List (Reorderable) - Between pickup and destination
                  if (_stops.isNotEmpty)
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _stops.length,
                      onReorder: _reorderStop,
                      itemBuilder: (context, index) {
                        final stop = _stops[index];
                        return _buildStopCard(
                          stop,
                          index,
                          key: ValueKey(stop.id),
                        );
                      },
                    ),

                  // Add Stop Button (between pickup and destination)
                  if (_stops.length < 4)
                    InkWell(
                      onTap: _addStop,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.border.withOpacity(0.5),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.accent,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              'Add stop',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Destination
                  _buildLocationCard(
                    title: 'Destination',
                    controller: _destinationController,
                    focusNode: _destinationFocusNode,
                    icon: Icons.location_on,
                    iconColor: AppColors.primary,
                    onPlaceSelected: (place) {
                      setState(() {
                        _destinationLocation = LocationItem(
                          id: place.placeId,
                          address: place.address,
                          lat: place.lat,
                          lng: place.lng,
                        );
                      });
                    },
                  ).animate().fadeIn(
                    delay: 100.ms,
                    duration: AppAnimations.fast,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Schedule Button (smaller, below destination)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: _buildActionButton(
                      icon: Icons.access_time,
                      label: _scheduledDateTime == null
                          ? 'Schedule ride'
                          : _formatDateTime(_scheduledDateTime!),
                      onTap: _selectScheduleTime,
                      isActive: _scheduledDateTime != null,
                    ),
                  ).animate().fadeIn(
                    delay: 200.ms,
                    duration: AppAnimations.fast,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),

          // Find Route Button
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
                text: 'Find a Route',
                onPressed:
                    (_pickupLocation != null && _destinationLocation != null)
                        ? _findRoute
                        : null,
                fullWidth: true,
                isLoading: _isCalculatingFare,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required String title,
    required TextEditingController controller,
    FocusNode? focusNode,
    required IconData icon,
    required Color iconColor,
    bool isLoading = false,
    required Function(PlaceDetail) onPlaceSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: isLoading
                ? const SizedBox(
                  height: 20,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
                : PlaceAutocompleteInput(
                  controller: controller,
                  focusNode: focusNode,
                  label: '',
                  hint: title,
                  onPlaceSelected: onPlaceSelected,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color:
              isActive ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.accent,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopCard(LocationItem stop, int index, {required Key key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              stop.address,
              style: AppTextStyles.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _removeStop(index),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.drag_handle, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (date == today) {
      dateStr = 'Today';
    } else if (date == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}';
    }

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$dateStr $hour:$minute';
  }
}

// Bottom Sheet for Adding Stops
class _StopInputSheet extends StatefulWidget {
  final Function(String address, double? lat, double? lng) onStopAdded;

  const _StopInputSheet({required this.onStopAdded});

  @override
  State<_StopInputSheet> createState() => _StopInputSheetState();
}

class _StopInputSheetState extends State<_StopInputSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.lg),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Stop', style: AppTextStyles.heading3),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: PlaceAutocompleteInput(
                  controller: _controller,
                  focusNode: _focusNode,
                  label: '',
                  hint: 'Enter stop address',
                  prefixIcon: Icons.location_on,
                  onPlaceSelected: (place) {
                    widget.onStopAdded(place.address, place.lat, place.lng);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
