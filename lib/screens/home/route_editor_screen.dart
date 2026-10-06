import '../../widgets/route_stop_row.dart';
import '../../services/pickup_lookup_session.dart';
import '../../services/places_search_session.dart';
import '../../models/location_model.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/recent_places_store.dart';
import '../../services/booking_service.dart';
import '../../services/api_service.dart';
import '../../widgets/recent_places_list.dart';
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
  final PickupLookupSession? pickupLookup;

  const RouteEditorScreen({super.key, this.currentPosition, this.pickupLookup});

  @override
  State<RouteEditorScreen> createState() => _RouteEditorScreenState();
}

class _RouteEditorScreenState extends State<RouteEditorScreen> {
  late final _pickupLookup = widget.pickupLookup ?? PickupLookupSession();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  final _stopController = TextEditingController();
  final _stopFocusNode = FocusNode();
  LocationItem? _editingStop;
  LocationItem? _pickupLocation;
  LocationItem? _destinationLocation;
  List<LocationItem> _stops = [];
  DateTime? _scheduledDateTime;
  bool _isLoadingPickup = true;

  // For handling suggestions
  List<PlacePrediction> _suggestions = [];
  final _searchSessions = {
    'pickup': PlacesSearchSession(),
    'destination': PlacesSearchSession(),
    'stop': PlacesSearchSession(),
  };
  String _activeField = ''; // 'pickup' or 'destination'
  Timer? _debounce;
  final _recentStore = RecentPlacesStore();
  List<PlaceDetails> _recentPlaces = [];
  String? _historyUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _loadRecentPlaces();

    // Listen to text changes for suggestions
    _stopController.addListener(_onStopTextChanged);
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
    _stopController.dispose();
    _stopFocusNode.dispose();
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

  void _onStopTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted || !_stopFocusNode.hasFocus) return;
      _searchPlaces(_stopController.text, 'stop');
    });
  }

  Future<void> _searchPlaces(String query, String field) async {
    setState(() {
      _activeField = field;
    });

    try {
      final results = await _searchSessions[field]!.predictions(query);
      final controller =
          field == 'stop'
              ? _stopController
              : field == 'pickup'
              ? _pickupController
              : _destinationController;
      if (mounted && _activeField == field && controller.text == query) {
        setState(() => _suggestions = results);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
        });
      }
    }
  }

  Future<void> _loadRecentPlaces() async {
    final id = context.read<AuthProvider>().user?.id;
    if (id == null) return;
    _historyUserId = id.toString();
    try {
      var places = await _recentStore.load(_historyUserId!);
      if (places.isEmpty) {
        // Existing bookings supply genuine previous places, never sample data.
        final bookings = await BookingService(ApiService()).getBookingHistory();
        for (final booking
            in bookings.take(RecentPlacesStore.limit).toList().reversed) {
          for (final location in booking.locations) {
            if (location.type != 'dropoff') continue;
            places = await _recentStore.remember(
              _historyUserId!,
              PlaceDetails(
                placeId: 'trip_${booking.id}',
                name: location.address,
                formattedAddress: location.address,
                latitude: location.lat,
                longitude: location.lng,
              ),
            );
          }
        }
      }
      if (mounted) setState(() => _recentPlaces = places);
    } catch (_) {
      // Storage/network failure must not prevent manual address selection.
    }
  }

  Future<void> _selectSuggestion(PlacePrediction prediction) async {
    final field = _activeField;
    final editingStop = _editingStop;
    final place = await _searchSessions[field]!.select(prediction.placeId);
    if (!mounted || place == null || _activeField != field) return;
    if (field == 'stop' && !identical(editingStop, _editingStop)) return;
    _applyPlace(place, field);
  }

  void _applyPlace(PlaceDetails place, String field) {
    if (!RecentPlacesStore.usable(place)) return;
    if (field == 'stop' && _editingStop == null) return;
    final location = LocationItem(
      id: place.placeId,
      address: place.formattedAddress,
      lat: place.latitude,
      lng: place.longitude,
    );
    setState(() {
      if (field == 'pickup') {
        _pickupLocation = location;
        _pickupController.text =
            place.name.isEmpty ? place.formattedAddress : place.name;
      } else if (field == 'stop') {
        final index = _stops.indexOf(_editingStop!);
        if (index >= 0) _stops[index] = location;
        _editingStop = null;
      } else {
        _destinationLocation = location;
        _destinationController.text =
            place.name.isEmpty ? place.formattedAddress : place.name;
      }
      _suggestions = [];
      _activeField = '';
    });
    _debounce?.cancel();
    _searchSessions[field]?.reset();
    FocusScope.of(context).unfocus();
    _rememberPlace(place);
  }

  Future<void> _rememberPlace(PlaceDetails place) async {
    final userId = _historyUserId;
    if (userId == null) return;
    try {
      final places = await _recentStore.remember(userId, place);
      if (mounted) setState(() => _recentPlaces = places);
    } catch (_) {}
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
        final placeDetails = await _pickupLookup.lookup(
          position.latitude,
          position.longitude,
        );

        if (placeDetails != null && mounted && _pickupLocation == null) {
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

  void _addStop() {
    final unfinished = _stops.where((stop) => stop.lat == null);
    final stop =
        unfinished.isNotEmpty
            ? unfinished.first
            : LocationItem(
              id: 'stop_${DateTime.now().microsecondsSinceEpoch}',
              address: '',
            );
    if (!_stops.contains(stop)) setState(() => _stops.add(stop));
    _editStop(stop);
  }

  void _editStop(LocationItem stop) {
    _debounce?.cancel();
    _searchSessions['stop']!.reset();
    _stopController.text = stop.address;
    setState(() {
      _editingStop = stop;
      _activeField = 'stop';
      _suggestions = [];
    });
    _stopFocusNode.requestFocus();
  }

  void _moveStop(int index, int target) {
    if (target < 0 || target >= _stops.length) return;
    setState(() {
      final stop = _stops.removeAt(index);
      _stops.insert(target, stop);
    });
  }

  void _removeStop(int index) {
    setState(() {
      final removed = _stops.removeAt(index);
      if (identical(removed, _editingStop)) {
        _editingStop = null;
        _activeField = '';
        _suggestions = [];
        _debounce?.cancel();
        _stopFocusNode.unfocus();
      }
    });
  }

  Future<void> _findRoute() async {
    if (_pickupLocation == null || _destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup and destination')),
      );
      return;
    }

    final points = [_pickupLocation!, ..._stops, _destinationLocation!];
    if (points.any(
      (point) =>
          point.lat == null ||
          point.lng == null ||
          !point.lat!.isFinite ||
          !point.lng!.isFinite ||
          point.lat!.abs() > 90 ||
          point.lng!.abs() > 180 ||
          (point.lat == 0 && point.lng == 0),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a valid address for each stop')),
      );
      return;
    }

    final destination = _destinationLocation!.address;

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
              stops:
                  _stops
                      .map(
                        (stop) => LocationModel(
                          lat: stop.lat!,
                          lng: stop.lng!,
                          address: stop.address,
                          type: 'stop',
                        ),
                      )
                      .toList(),
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
          'Your route',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder:
            (context, constraints) => Column(
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
                                ? 'Now'
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
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.lg,
                            ),
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
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * .58,
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
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
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(color: AppColors.white),
        child: SafeArea(
          top: false,
          child: CustomButton(
            text: 'See rides',
            onPressed: _findRoute,
            fullWidth: true,
          ),
        ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFirst ? 'Pickup' : 'Destination',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 4),
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
                          if (controller.text.trim().isEmpty) _suggestions = [];
                        });
                      },
                    ),
              ],
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
    if (identical(stop, _editingStop)) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
        child: Row(
          children: [
            Text('${index + 1}'),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _stopController,
                focusNode: _stopFocusNode,
                decoration: InputDecoration(
                  labelText: 'Stop ${index + 1}',
                  hintText: 'Search address or place',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
                onTap: () => setState(() => _activeField = 'stop'),
              ),
            ),
            IconButton(
              tooltip: 'Remove stop ${index + 1}',
              onPressed: () => _removeStop(index),
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
      );
    }
    return InkWell(
      onTap: () => _editStop(stop),
      child: RouteStopRow(
        address: stop.address,
        number: index + 1,
        onMoveUp: index == 0 ? null : () => _moveStop(index, index - 1),
        onMoveDown:
            index == _stops.length - 1
                ? null
                : () => _moveStop(index, index + 1),
        onRemove: () => _removeStop(index),
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
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultContent() {
    final pickup = _pickupFocusNode.hasFocus;
    final stop = _stopFocusNode.hasFocus && _editingStop != null;
    final controller =
        stop
            ? _stopController
            : pickup
            ? _pickupController
            : _destinationController;
    if (controller.text.trim().isEmpty && _recentPlaces.isNotEmpty) {
      return RecentPlacesList(
        places: _recentPlaces,
        onSelected:
            (place) => _applyPlace(
              place,
              stop
                  ? 'stop'
                  : pickup
                  ? 'pickup'
                  : 'destination',
            ),
      );
    }
    return Container(
      color: AppColors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: const [
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose your destination', style: AppTextStyles.heading3),
                SizedBox(height: 8),
                Text(
                  'Search or choose a recent place.',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
        ],
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
