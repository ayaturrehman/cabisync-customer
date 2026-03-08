import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import 'add_address_screen.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('saved_addresses') ?? [];
    setState(() {
      _addresses =
          raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      _loading = false;
    });
  }

  Future<void> _deleteAddress(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('saved_addresses') ?? [];
    raw.removeAt(index);
    await prefs.setStringList('saved_addresses', raw);
    setState(() => _addresses.removeAt(index));
  }

  Future<void> _openAddAddress() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );
    if (added == true) _loadAddresses();
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const CustomAppBar(title: 'Saved Addresses'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? _buildEmptyState()
              : _buildList(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
          child: CustomButton(
            text: 'Add New Address',
            icon: Icons.add_location_alt_outlined,
            onPressed: _openAddAddress,
            fullWidth: true,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              ),
              child: const Icon(Icons.location_on_outlined,
                  color: AppColors.white, size: 44),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No saved addresses', style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Save your home, work or favourite places to book rides faster.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: _addresses.asMap().entries.map((entry) {
              final isLast = entry.key == _addresses.length - 1;
              final addr = entry.value;
              return _AddressTile(
                icon: _iconForType(addr['type'] as String? ?? 'other'),
                label: addr['label'] as String? ?? 'Address',
                address: addr['address'] as String? ?? '',
                isLast: isLast,
                onDelete: () => _deleteAddress(entry.key),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _AddressTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String address;
  final bool isLast;
  final VoidCallback onDelete;

  const _AddressTile({
    required this.icon,
    required this.label,
    required this.address,
    required this.isLast,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border, width: 0.8)),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Icon(icon, color: AppColors.white, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xs),
                Text(address,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.accent,
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints:
                const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
