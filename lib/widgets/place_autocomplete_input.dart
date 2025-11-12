import 'dart:async';
import 'package:flutter/material.dart';
import '../services/google_places_service.dart';
import '../config/theme.dart';

class PlaceDetail {
  final String placeId;
  final String name;
  final String address;
  final double? lat;
  final double? lng;

  PlaceDetail({
    required this.placeId,
    required this.name,
    required this.address,
    this.lat,
    this.lng,
  });
}

typedef OnPlaceSelected = void Function(PlaceDetail place);

class PlaceAutocompleteInput extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final OnPlaceSelected? onPlaceSelected;
  final IconData? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const PlaceAutocompleteInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.label = 'Enter location',
    this.hint = 'Search for a place',
    this.onPlaceSelected,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<PlaceAutocompleteInput> createState() => _PlaceAutocompleteInputState();
}

class _PlaceAutocompleteInputState extends State<PlaceAutocompleteInput> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<PlacePrediction> _predictions = [];
  Timer? _debounceTimer;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.readOnly) return;

    final text = widget.controller.text;
    print('PlaceAutocomplete: Text changed to "$text"');

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (text.isNotEmpty) {
        print('PlaceAutocomplete: Searching for "$text"');
        _searchPlaces(text);
      } else {
        _removeOverlay();
      }
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) return;

    print('PlaceAutocomplete: Starting search for "$query"');
    setState(() => _isSearching = true);

    try {
      final predictions = await GooglePlacesService.getPlacePredictions(query);
      print('PlaceAutocomplete: Received ${predictions.length} predictions');

      if (mounted) {
        setState(() {
          _predictions = predictions;
          _isSearching = false;
        });
        if (predictions.isNotEmpty) {
          print(
            'PlaceAutocomplete: Showing overlay with ${predictions.length} results',
          );
          _showOverlay();
        } else {
          print('PlaceAutocomplete: No predictions, removing overlay');
          _removeOverlay();
        }
      }
    } catch (e) {
      print('PlaceAutocomplete: Error searching places: $e');
      if (mounted) {
        setState(() => _isSearching = false);
        _removeOverlay();
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();

    // Check if widget is still mounted and has context
    if (!mounted || context.findRenderObject() == null) {
      print(
        'PlaceAutocomplete: Cannot show overlay - widget not properly mounted',
      );
      return;
    }

    print('PlaceAutocomplete: Creating and showing overlay');
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder:
          (context) => Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 5),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _predictions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final prediction = _predictions[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: AppColors.accent,
                        ),
                        title: Text(
                          prediction.mainText,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          prediction.secondaryText,
                          style: AppTextStyles.caption,
                        ),
                        onTap: () => _selectPlace(prediction),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Future<void> _selectPlace(PlacePrediction prediction) async {
    _removeOverlay();
    widget.controller.text = prediction.description;
    widget.focusNode?.unfocus();

    // Fetch place details to get coordinates
    final details = await GooglePlacesService.getPlaceDetails(
      prediction.placeId,
    );
    if (details != null && widget.onPlaceSelected != null) {
      widget.onPlaceSelected!(
        PlaceDetail(
          placeId: details.placeId,
          name: details.name,
          address: details.formattedAddress,
          lat: details.latitude,
          lng: details.longitude,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          border: InputBorder.none,
          prefixIcon:
              widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: AppColors.accent)
                  : null,
          suffixIcon:
              _isSearching
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                  : widget.controller.text.isNotEmpty && !widget.readOnly
                  ? IconButton(
                    onPressed: () {
                      widget.controller.clear();
                      _removeOverlay();
                    },
                    icon: const Icon(Icons.clear),
                  )
                  : null,
        ),
      ),
    );
  }
}
