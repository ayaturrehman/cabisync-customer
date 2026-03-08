import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/section_label.dart';
import '../auth/login_screen.dart';
import 'personal_information_screen.dart';
import 'payment_methods_screen.dart';
import 'saved_addresses_screen.dart';
import 'notifications_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _ProfileHeader(
            name: user?.name ?? 'Guest',
            email: user?.email ?? '',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatsRow(user: user),
                  const SizedBox(height: AppSpacing.lg),
                  SectionLabel('Account'),
                  const SizedBox(height: AppSpacing.sm),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline,
                        title: 'Personal Information',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PersonalInformationScreen(),
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.credit_card_outlined,
                        title: 'Payment Methods',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentMethodsScreen(),
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.location_on_outlined,
                        title: 'Saved Addresses',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SavedAddressesScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionLabel('Preferences'),
                  const SizedBox(height: AppSpacing.sm),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.language,
                        title: 'Language',
                        subtitle: 'English',
                        onTap: () => _showComingSoon(context, 'Language'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionLabel('Support'),
                  const SizedBox(height: AppSpacing.sm),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpSupportScreen(),
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () => _showComingSoon(context, 'About'),
                      ),
                      _MenuItem(
                        icon: Icons.description_outlined,
                        title: 'Terms & Conditions',
                        onTap: () =>
                            _showComingSoon(context, 'Terms & Conditions'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _LogoutTile(
                    onTap: () async {
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Center(
                    child: Text(
                      'Version 1.0.0',
                      style: AppTextStyles.caption,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Header
// ──────────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.heading2.copyWith(
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        email,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PersonalInformationScreen(),
                    ),
                  );
                },
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.textPrimary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Stats row
// ──────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final dynamic user;

  const _StatsRow({this.user});

  @override
  Widget build(BuildContext context) {
    final memberYear =
        user?.createdAt != null ? user!.createdAt.year.toString() : '—';
    final rides = user?.totalRides?.toString() ?? '0';
    final rating =
        user?.rating != null ? user!.rating!.toStringAsFixed(1) : '5.0';

    return Row(
      children: [
        Expanded(child: _StatChip(label: 'Rides', value: rides)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatChip(label: 'Member', value: memberYear)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatChip(label: 'Rating', value: rating)),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Menu card
// ──────────────────────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return _MenuRow(item: entry.value, isLast: isLast);
        }).toList(),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final _MenuItem item;
  final bool isLast;

  const _MenuRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.vertical(
        bottom:
            isLast ? const Radius.circular(AppBorderRadius.lg) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.8),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                item.icon,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTextStyles.body),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.subtitle!,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Logout tile
// ──────────────────────────────────────────────────────────────────────────────

class _LogoutTile extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(color: AppColors.errorBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: const Icon(
                Icons.logout,
                color: AppColors.errorText,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Logout',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.errorText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.errorText,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Data model
// ──────────────────────────────────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
