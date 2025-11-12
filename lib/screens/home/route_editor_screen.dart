import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/theme.dart';
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

  // For handling suggestions
  List<PlacePrediction> _suggestions = [];
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
      if (_pickupController.text.isNotEmpty && _pickupFocusNode.hasFocus) {
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
      if (_destinationController.text.isNotEmpty &&
          _destinationFocusNode.hasFocus) {
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
      _activeField = field;
    });

    try {
      final results = await GooglePlacesService.getPlacePredictions(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
        });
      }
    }
  }

  Future<void> _selectSuggestion(PlacePrediction prediction) async {
    // Fetch full place details with coordinates
    final placeDetails = await GooglePlacesService.getPlaceDetails(
      prediction.placeId,
    );

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
            _pickupController.text = placeDetails.name;
            _isLoadingPickup = false;
          });
        }
      } else {
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

  Future<void> _selectScheduleTime() async {
    // Show bottom sheet for date and time selection
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => _ScheduleTimeSheet(initialDateTime: _scheduledDateTime),
    );

    if (result != null && mounted) {
      setState(() {
        _scheduledDateTime = result;
      });
    }
  }

  Future<void> _addStop() async {
    // Show bottom sheet for adding a stop
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: _StopInputSheet(
                onStopAdded: (LocationItem stop) {
                  setState(() {
                    _stops.add(stop);
                  });
                },
              ),
            ),
          ),
    );
  }

  void _removeStop(int index) {
    setState(() {
      _stops.removeAt(index);
    });
  }

  Future<void> _findRoute() async {
    if (_pickupLocation == null || _destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup and destination')),
      );
      return;
    }

    String destination = _destinationLocation!.address;
    if (_stops.isNotEmpty) {
      destination += ' (${_stops.length} stop${_stops.length > 1 ? 's' : ''})';
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => RideBookingScreen(
              pickupLocation: _pickupLocation!.address,
              destinationLocation: destination,
              pickupLat: _pickupLocation!.lat ?? 0.0,
              pickupLng: _pickupLocation!.lng ?? 0.0,
              dropLat: _destinationLocation!.lat ?? 0.0,
              dropLng: _destinationLocation!.lng ?? 0.0,
              scheduledTime: _scheduledDateTime,
            ),
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

    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$dateStr at $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Plan your ride',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top action buttons
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                _buildTopButton(
                  icon: Icons.access_time,
                  label:
                      _scheduledDateTime == null
                          ? 'Pick-up now'
                          : _formatDateTime(_scheduledDateTime!),
                  onTap: _selectScheduleTime,
                ),
                const SizedBox(width: AppSpacing.sm),
                InkWell(
                  onTap: _addStop,
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    ),
                    child: const Text(
                      '+ Add stop',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Input fields container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              border: Border.all(color: AppColors.black, width: 2),
            ),
            child: Column(
              children: [
                _buildInputField(
                  controller: _pickupController,
                  focusNode: _pickupFocusNode,
                  icon: Icons.circle,
                  iconColor: AppColors.black,
                  isLoading: _isLoadingPickup,
                  isFirst: true,
                ),
                // Stops between pickup and destination
                if (_stops.isNotEmpty) ...[
                  ...List.generate(_stops.length, (index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 52),
                          child: Divider(
                            height: 1,
                            color: AppColors.border.withOpacity(0.3),
                          ),
                        ),
                        _buildStopInputField(_stops[index], index),
                      ],
                    );
                  }),
                ],
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Divider(
                    height: 1,
                    color: AppColors.border.withOpacity(0.3),
                  ),
                ),
                _buildInputField(
                  controller: _destinationController,
                  focusNode: _destinationFocusNode,
                  icon: Icons.location_on,
                  iconColor: AppColors.black,
                  isFirst: false,
                ),
              ],
            ),
          ),

          // Suggestions list or default content
          Expanded(
            child:
                _suggestions.isNotEmpty
                    ? _buildSuggestionsList()
                    : _buildDefaultContent(),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CustomButton(text: 'Find a Route', onPressed: _findRoute),
      ),
    );
  }

  Widget _buildTopButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.black),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required Color iconColor,
    bool isLoading = false,
    required bool isFirst,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child:
                isLoading
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
                    : TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            isFirst
                                ? controller.text.isEmpty
                                    ? 'Pickup location'
                                    : null
                                : 'Where to?',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: () {
                        setState(() {
                          _activeField = isFirst ? 'pickup' : 'destination';
                        });
                      },
                    ),
          ),
          if (controller.text.isNotEmpty)
            SizedBox(
              width: 24,
              height: 24,
              child: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  controller.clear();
                  setState(() {
                    if (isFirst) {
                      _pickupLocation = null;
                    } else {
                      _destinationLocation = null;
                    }
                    _suggestions = [];
                  });
                },
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStopInputField(LocationItem stop, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
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
                  fontSize: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              stop.address,
              style: AppTextStyles.body.copyWith(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.textSecondary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _removeStop(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      color: AppColors.white,
      child: ListView.builder(
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return _buildSuggestionItem(suggestion);
        },
      ),
    );
  }

  Widget _buildSuggestionItem(PlacePrediction suggestion) {
    final distance = '${(2.0 + (suggestion.placeId.hashCode % 10))} mi';

    return InkWell(
      onTap: () => _selectSuggestion(suggestion),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border.withOpacity(0.2)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.mainText,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (suggestion.secondaryText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      suggestion.secondaryText,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              distance,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultContent() {
    return Container(
      color: AppColors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: const [
          // Empty state or saved places can go here
        ],
      ),
    );
  }
}

// Bottom sheet for adding a stop
class _StopInputSheet extends StatefulWidget {
  final Function(LocationItem) onStopAdded;

  const _StopInputSheet({required this.onStopAdded});

  @override
  State<_StopInputSheet> createState() => _StopInputSheetState();
}

class _StopInputSheetState extends State<_StopInputSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<PlacePrediction> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_controller.text.isNotEmpty) {
        _searchPlaces(_controller.text);
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    });
  }

  Future<void> _searchPlaces(String query) async {
    try {
      final results = await GooglePlacesService.getPlacePredictions(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
        });
      }
    }
  }

  Future<void> _selectPlace(PlacePrediction prediction) async {
    final placeDetails = await GooglePlacesService.getPlaceDetails(
      prediction.placeId,
    );

    if (placeDetails != null) {
      widget.onStopAdded(
        LocationItem(
          id: placeDetails.placeId,
          address: placeDetails.formattedAddress,
          lat: placeDetails.latitude,
          lng: placeDetails.longitude,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Stop',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Enter stop location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(suggestion.mainText),
                      subtitle: Text(suggestion.secondaryText),
                      onTap: () => _selectPlace(suggestion),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScheduleTimeSheet extends StatefulWidget {
  final DateTime? initialDateTime;

  const _ScheduleTimeSheet({this.initialDateTime});

  @override
  State<_ScheduleTimeSheet> createState() => _ScheduleTimeSheetState();
}

class _ScheduleTimeSheetState extends State<_ScheduleTimeSheet> {
  late DateTime selectedDate;
  late int selectedHour;
  late int selectedMinute;
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  // Available minutes in 5-minute intervals
  final List<int> availableMinutes = [
    0,
    5,
    10,
    15,
    20,
    25,
    30,
    35,
    40,
    45,
    50,
    55,
  ];

  @override
  void initState() {
    super.initState();

    // Calculate minimum selectable time (current time + 30 minutes)
    final minimumTime = DateTime.now().add(const Duration(minutes: 30));

    // Round up to the next 5-minute interval
    final roundedMinute = ((minimumTime.minute / 5).ceil() * 5) % 60;
    final adjustedTime = DateTime(
      minimumTime.year,
      minimumTime.month,
      minimumTime.day,
      roundedMinute == 0 && minimumTime.minute > 0
          ? minimumTime.hour + 1
          : minimumTime.hour,
      roundedMinute,
    );

    // Initialize with adjusted time or provided initial time (whichever is later)
    final initialTime =
        widget.initialDateTime != null &&
                widget.initialDateTime!.isAfter(adjustedTime)
            ? widget.initialDateTime!
            : adjustedTime;

    selectedDate = DateTime(
      initialTime.year,
      initialTime.month,
      initialTime.day,
    );
    selectedHour = initialTime.hour;
    selectedMinute = initialTime.minute;

    // Ensure selected minute is in 5-minute intervals
    if (!availableMinutes.contains(selectedMinute)) {
      selectedMinute = availableMinutes.firstWhere(
        (m) => m >= selectedMinute,
        orElse: () => availableMinutes.first,
      );
    }

    hourController = FixedExtentScrollController(initialItem: selectedHour);
    minuteController = FixedExtentScrollController(
      initialItem: availableMinutes.indexOf(selectedMinute),
    );
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  DateTime get selectedDateTime => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedHour,
    selectedMinute,
  );

  bool isValidTime() {
    final minimumTime = DateTime.now().add(const Duration(minutes: 30));
    return selectedDateTime.isAfter(minimumTime) ||
        selectedDateTime.isAtSameMomentAs(minimumTime);
  }

  void _adjustTimeIfNeeded() {
    if (!isValidTime()) {
      final minimumTime = DateTime.now().add(const Duration(minutes: 30));
      final roundedMinute = ((minimumTime.minute / 5).ceil() * 5) % 60;

      setState(() {
        selectedHour =
            roundedMinute == 0 && minimumTime.minute > 0
                ? minimumTime.hour + 1
                : minimumTime.hour;
        selectedMinute = roundedMinute;
        hourController.jumpToItem(selectedHour);
        minuteController.jumpToItem(availableMinutes.indexOf(selectedMinute));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header with Cancel and Now buttons
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border.withOpacity(0.2)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
                const Text(
                  'Schedule Time',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Now', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),

          // Date selector (scrollable, up to 21 days)
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: 21, // 21 days advance booking
              itemBuilder: (context, index) {
                final date = today.add(Duration(days: index));
                final isSelected =
                    selectedDate.year == date.year &&
                    selectedDate.month == date.month &&
                    selectedDate.day == date.day;

                String label;
                if (index == 0) {
                  label = 'Today';
                } else if (index == 1) {
                  label = 'Tomorrow';
                } else {
                  final weekdays = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];
                  label = weekdays[date.weekday - 1];
                }

                final months = [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                  'Sep',
                  'Oct',
                  'Nov',
                  'Dec',
                ];

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = date;
                        _adjustTimeIfNeeded();
                      });
                    },
                    child: Container(
                      width: 70,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.background,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        border: Border.all(
                          color:
                              isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color:
                                  isSelected
                                      ? AppColors.white
                                      : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color:
                                  isSelected
                                      ? AppColors.white
                                      : AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            months[date.month - 1],
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color:
                                  isSelected
                                      ? AppColors.white
                                      : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Time picker wheels
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hour picker
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: hourController,
                    itemExtent: 50,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedHour = index;
                        _adjustTimeIfNeeded();
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        if (index < 0 || index > 23) return null;
                        return Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  index == selectedHour
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color:
                                  index == selectedHour
                                      ? AppColors.black
                                      : AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                      childCount: 24,
                    ),
                  ),
                ),
                const Text(
                  ':',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                // Minute picker
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: minuteController,
                    itemExtent: 50,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedMinute = availableMinutes[index];
                        _adjustTimeIfNeeded();
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        if (index < 0 || index >= availableMinutes.length)
                          return null;
                        final minute = availableMinutes[index];
                        return Center(
                          child: Text(
                            minute.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  minute == selectedMinute
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color:
                                  minute == selectedMinute
                                      ? AppColors.black
                                      : AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                      childCount: availableMinutes.length,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Confirm button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isValidTime()
                        ? () => Navigator.pop(context, selectedDateTime)
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  disabledBackgroundColor: AppColors.textSecondary.withOpacity(
                    0.3,
                  ),
                ),
                child: Text(
                  isValidTime() ? 'Confirm' : 'Select time',
                  style: const TextStyle(fontSize: 16, color: AppColors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
