import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/section_label.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Map<String, bool> _prefs = {
    'booking_confirmed': true,
    'driver_assigned': true,
    'ride_completed': true,
    'special_offers': false,
    'new_features': false,
    'security_alerts': true,
  };

  void _toggle(String key, bool value) {
    setState(() => _prefs[key] = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const CustomAppBar(title: 'Notifications'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SizedBox(height: AppSpacing.sm),
          _buildSection(
            label: 'RIDE UPDATES',
            items: [
              _NotifItem(
                title: 'Booking Confirmed',
                prefKey: 'booking_confirmed',
              ),
              _NotifItem(
                title: 'Driver Assigned',
                prefKey: 'driver_assigned',
              ),
              _NotifItem(
                title: 'Ride Completed',
                prefKey: 'ride_completed',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSection(
            label: 'PROMOTIONS',
            items: [
              _NotifItem(
                title: 'Special Offers',
                prefKey: 'special_offers',
              ),
              _NotifItem(
                title: 'New Features',
                prefKey: 'new_features',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSection(
            label: 'ACCOUNT',
            items: [
              _NotifItem(
                title: 'Security Alerts',
                prefKey: 'security_alerts',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required List<_NotifItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              final item = entry.value;
              return _NotifRow(
                title: item.title,
                value: _prefs[item.prefKey] ?? false,
                isLast: isLast,
                onChanged: (val) => _toggle(item.prefKey, val),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _NotifItem {
  final String title;
  final String prefKey;
  const _NotifItem({required this.title, required this.prefKey});
}

class _NotifRow extends StatelessWidget {
  final String title;
  final bool value;
  final bool isLast;
  final ValueChanged<bool> onChanged;

  const _NotifRow({
    required this.title,
    required this.value,
    required this.isLast,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border, width: 0.8),
              ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTextStyles.body),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.black,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }
}
