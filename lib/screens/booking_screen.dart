import 'package:flutter/material.dart';
import '../widgets/place_autocomplete_input.dart';
import '../services/place_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _pickupController = TextEditingController(
    text: '124 Tickhill Road',
  );
  final TextEditingController _dropController = TextEditingController();

  // Focus nodes to track focus state
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _dropFocusNode = FocusNode();

  PlaceDetail? _pickupPlace;
  PlaceDetail? _dropPlace;

  List<PlaceSuggestion> _pickupSuggestions = [];
  List<PlaceSuggestion> _dropSuggestions = [];
  bool _loading = false;

  String _pickupChoice = 'Pick-up now';
  String _forWho = 'For me';

  // Track if dropdowns have focus
  bool _pickupDropdownFocused = false;
  bool _forWhoDropdownFocused = false;

  @override
  void initState() {
    super.initState();
    // Listen to focus changes
    _pickupFocusNode.addListener(_onPickupFocusChanged);
    _dropFocusNode.addListener(_onDropFocusChanged);
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    _pickupFocusNode.dispose();
    _dropFocusNode.dispose();
    super.dispose();
  }

  void _onPickupFocusChanged() {
    if (_pickupFocusNode.hasFocus && _pickupController.text.isNotEmpty) {
      _fetchSuggestions(_pickupController.text, true);
    }
  }

  void _onDropFocusChanged() {
    if (_dropFocusNode.hasFocus && _dropController.text.isNotEmpty) {
      _fetchSuggestions(_dropController.text, false);
    }
  }

  Future<void> _fetchSuggestions(String input, bool isPickup) async {
    if (input.length < 2) {
      setState(() {
        if (isPickup) {
          _pickupSuggestions = [];
        } else {
          _dropSuggestions = [];
        }
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final suggestions = await PlaceService.fetchPredictions(input);
      setState(() {
        if (isPickup) {
          _pickupSuggestions = suggestions;
        } else {
          _dropSuggestions = suggestions;
        }
      });
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _selectSuggestion(
    PlaceSuggestion suggestion,
    bool isPickup,
  ) async {
    try {
      final detail = await PlaceService.fetchPlaceDetail(suggestion);
      setState(() {
        if (isPickup) {
          _pickupPlace = detail;
          _pickupController.text = detail.address;
          _pickupSuggestions = []; // Clear suggestions after selection
        } else {
          _dropPlace = detail;
          _dropController.text = detail.address;
          _dropSuggestions = []; // Clear suggestions after selection
        }
      });

      // Remove focus after selection
      if (isPickup) {
        _pickupFocusNode.unfocus();
      } else {
        _dropFocusNode.unfocus();
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _checkAndFetchPrices() {
    if (_pickupPlace != null && _dropPlace != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fetching prices from ${_pickupPlace!.address} → ${_dropPlace!.address}',
          ),
        ),
      );
    }
  }

  // Helper method to determine if suggestions should be shown
  bool _shouldShowPickupSuggestions() {
    return _pickupSuggestions.isNotEmpty &&
        (_pickupFocusNode.hasFocus ||
            _pickupDropdownFocused ||
            _forWhoDropdownFocused);
  }

  bool _shouldShowDropSuggestions() {
    return _dropSuggestions.isNotEmpty &&
        (_dropFocusNode.hasFocus ||
            _pickupDropdownFocused ||
            _forWhoDropdownFocused);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('Plan your ride'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Top dropdowns
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        value: _pickupChoice,
                        items: const ['Pick-up now', 'Schedule'],
                        onChanged: (v) => setState(() => _pickupChoice = v),
                        onFocusChanged:
                            (focused) => setState(
                              () => _pickupDropdownFocused = focused,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        value: _forWho,
                        items: const ['For me', 'For someone'],
                        onChanged: (v) => setState(() => _forWho = v),
                        onFocusChanged:
                            (focused) => setState(
                              () => _forWhoDropdownFocused = focused,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pickup / Drop inputs
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.my_location, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PlaceAutocompleteInput(
                              label: 'Pickup',
                              controller: _pickupController,
                              focusNode: _pickupFocusNode,
                              onChanged:
                                  (value) => _fetchSuggestions(value, true),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PlaceAutocompleteInput(
                              label: 'Where to?',
                              controller: _dropController,
                              focusNode: _dropFocusNode,
                              onChanged:
                                  (value) => _fetchSuggestions(value, false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      (_pickupPlace != null && _dropPlace != null)
                          ? _checkAndFetchPrices
                          : null,
                  child: const Text("Get Prices"),
                ),
                if (_loading) const LinearProgressIndicator(),

                // Show suggestions after Get Prices button
                const SizedBox(height: 16),
                if (_shouldShowPickupSuggestions()) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Pickup Suggestions',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildSuggestionList(_pickupSuggestions, true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_shouldShowDropSuggestions()) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Destination Suggestions',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildSuggestionList(_dropSuggestions, false),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    required ValueChanged<bool> onFocusChanged,
  }) {
    return Focus(
      onFocusChange: onFocusChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            items:
                items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
            onChanged: (v) => onChanged(v ?? value),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionList(
    List<PlaceSuggestion> suggestions,
    bool isPickup,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: suggestions.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, i) {
        final s = suggestions[i];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(s.display),
          subtitle: Text(s.description),
          onTap: () => _selectSuggestion(s, isPickup),
        );
      },
    );
  }
}
