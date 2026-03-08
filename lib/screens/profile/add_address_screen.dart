import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/place_autocomplete_input.dart';
import '../../widgets/section_label.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  String _selectedType = 'home';
  final _addressController = TextEditingController();
  final _labelController = TextEditingController();
  final _focusNode = FocusNode();
  PlaceDetail? _selectedPlace;
  bool _isLoading = false;

  static const _types = [
    {'type': 'home', 'label': 'Home', 'icon': Icons.home_outlined},
    {'type': 'work', 'label': 'Work', 'icon': Icons.work_outline},
    {'type': 'other', 'label': 'Other', 'icon': Icons.location_on_outlined},
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _labelController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedPlace == null && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please search and select an address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList('saved_addresses') ?? [];

      final label = _selectedType == 'other' &&
              _labelController.text.trim().isNotEmpty
          ? _labelController.text.trim()
          : _types.firstWhere((t) => t['type'] == _selectedType)['label']!;

      final entry = jsonEncode({
        'type': _selectedType,
        'label': label,
        'address': _selectedPlace?.address ?? _addressController.text.trim(),
        'lat': _selectedPlace?.lat,
        'lng': _selectedPlace?.lng,
      });

      existing.add(entry);
      await prefs.setStringList('saved_addresses', existing);

      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const CustomAppBar(title: 'Add Address'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SectionLabel('ADDRESS TYPE'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: _types.asMap().entries.map((entry) {
              final t = entry.value;
              final isSelected = _selectedType == t['type'];
              final isLast = entry.key == _types.length - 1;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _selectedType = t['type'] as String),
                  child: Container(
                    margin: EdgeInsets.only(
                        right: isLast ? 0 : AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.black
                          : AppColors.white,
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.md),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.black
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          t['icon'] as IconData,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.accent,
                          size: 22,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          t['label'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedType == 'other') ...[
            const SizedBox(height: AppSpacing.md),
            SectionLabel('CUSTOM LABEL'),
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: TextField(
                controller: _labelController,
                style: AppTextStyles.body,
                decoration: const InputDecoration(
                  hintText: "e.g. Gym, Parent's House",
                  border: InputBorder.none,
                  hintStyle: AppTextStyles.hint,
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SectionLabel('SEARCH ADDRESS'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: PlaceAutocompleteInput(
              controller: _addressController,
              focusNode: _focusNode,
              label: 'Search address',
              hint: 'Street, city or postcode…',
              prefixIcon: Icons.search,
              onPlaceSelected: (place) =>
                  setState(() => _selectedPlace = place),
            ),
          ),
          if (_selectedPlace != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                    BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.black, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _selectedPlace!.address,
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
          child: CustomButton(
            text: 'Save Address',
            onPressed: _isLoading ? null : _save,
            isLoading: _isLoading,
            fullWidth: true,
          ),
        ),
      ),
    );
  }

}
